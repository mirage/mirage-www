---
updated: 2014-02-02
author:
  name: Dave Scott
  uri: http://dave.recoil.org/
  email: dave@recoil.org
subject: Synthesizing virtual disks for Xen
permalink: xen-synthesize-virtual-disk
---

[ updated 2014-02-01 for mirage.1.1.0 and xen-disk.1.2.1 ]

This page describes how to create a synthetic, high-performance
virtual disk implementation for Xen based on the MirageOS libraries.

## Disk devices under Xen

The protocols used by Xen disk and network devices are designed to
permit fast and efficient software implementations, avoiding the
inefficiencies inherent in emulating physical hardware in software.
The protocols are based on two primitives:

* *shared memory pages*: used for sharing both data and metadata
* *event channels*: similar to interrupts, these allow one side to signal the other

In the disk block protocol, the protocol starts with the client
("frontend" in Xen jargon) sharing a page with the server ("backend").
This single page will contain the request/response metadata, arranged
as a circular buffer or "ring". The client ("frontend") can then start
sharing pages containing disk blocks with the backend and pushing request
structures to the ring, updating shared pointers as it goes. The client
will give the server end a kick via an event channel signal and then both
ends start running simultaneously. There are no locks in the protocol so
updates to the shared metadata must be handled carefully, using write
memory barriers to ensure consistency.

### Xen disk devices in MirageOS

Like everything else in MirageOS, Xen disk devices are implemented as
libraries. The following libraries are used:
* [io-page](https://github.com/mirage/io-page):
  for representing raw memory pages
* [xen-gnt](https://github.com/xapi-project/ocaml-gnt):
  APIs for "granting" pages to other domains and "mapping" pages granted to us
* [xen-evtchn](https://github.com/xapi-project/ocaml-evtchn):
  APIs for signalling other VMs
* [shared-memory-ring](https://github.com/mirage/shared-memory-ring):
  manipulates shared memory request/response queues
  used for paravirtualised disk and network devices. This library is a mix of
  99.9% OCaml and 0.1% asm, where the asm is only needed to invoke memory
  barriers, to ensure that metadata writes issued by one CPU core appear
  in the same order when viewed by another CPU core.
* [mirage-block-xen](https://github.com/mirage/mirage-block-xen):
  frontend ("blkfront") and backend ("blkback") implementations

Note that all these libraries work equally well in userspace (for development
and debug) and kernelspace (for production): the target is chosen at
link-time.

## Userspace disk implementations

Userspace MirageOS apps are ideal for development, since they have access to
the full suite of Unix debug and profiling tools. Once written, the exact
same code can be relinked and run directly in kernelspace for maximum
performance.

The [xen-disk](https://github.com/mirage/xen-disk) demonstrates how to
create a synthetic Xen virtual disk. To compile it, first, install
[Xen](http://www.xen.org/) (including the -dev, or -devel packages),
[OCaml](http://www.ocaml.org/) and [OPAM](http://opam.ocamlpro.com/).

Second initialise your system:

```
  opam init
  eval `opam config env`
```

Third install the unmodified `xen-disk` package, this will ensure all the build
dependencies are installed:

```
  opam install xen-disk
```

When this completes it will have installed a command-line tool called
`xen-disk`. If you start a VM using your Xen toolstack of choice
("xl create ..." or "xe vm-install ..." or "virsh create ...") then you
should be able to run:

```
  xen-disk connect <vmname>
```

which will hotplug a fresh block device into the VM "vmname" using the
"discard" backend, which returns "success" to all read and write requests,
but actually throws all data away. Obviously this backend should only be
used for basic testing!

Assuming that worked ok, clone and build the source for `xen-disk` yourself:

```
  git clone git://github.com/mirage/xen-disk
  cd xen-disk
  make
```

## Making a custom virtual disk implementation

The `xen-disk` program can use any MirageOS disk implementation satisfying
Mirage
[BLOCK signature](https://github.com/mirage/mirage/blob/master/types/V1.mli#L134).
The key functions are:

* [connect](https://github.com/mirage/mirage/blob/master/types/V1.mli#L40):
  to open a connection to a named device
* [read](https://github.com/mirage/mirage/blob/master/types/V1.mli#L164):
  to fill application buffers with block device data
* [write](https://github.com/mirage/mirage/blob/master/types/V1.mli#L170):
  to write application buffers to the block device

By default `xen-disk` uses the following disk implementations:

* [mirage-block-unix](https://github.com/mirage/mirage-block-unix): reads and writes
  to/from an existing Unix file or block device
* [vhd-format](https://github.com/djs55/ocaml-vhd): reads and writes data encoded
  in the .vhd file format (as used by XenServer and Hyper-V)
* [DISCARD](https://github.com/mirage/xen-disk/blob/master/src/backend.ml#L45):
  returns `Ok ()` to all requests without doing any work (typically used for
  performance testing the ring code)

Let's make a virtual disk implementation which uses an existing disk
image file as a "gold image", but uses copy-on-write so that no writes
persist.
This is a common configuration in Virtual Desktop Infrastructure deployments
and is generally handy when you want to test a change quickly, and
revert it cleanly afterwards.
A useful Unix technique for file I/O is to "memory map" an existing file:
this associates the file contents with a range of virtual memory addresses
so that reading and writing within this address range will actually
read or write the file contents.
The "mmap" C function has a number of flags, which can be used to request
"copy on write" behaviour. Reading the
[OCaml manual Bigarray.map_file](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Bigarray.Genarray.html)
it says:

> If shared is true, all modifications performed on the array are reflected
> in the file. This requires that fd be opened with write permissions. If
> shared is false, modifications performed on the array are done in memory
> only, using copy-on-write of the modified pages; the underlying file is
> not affected.

So we should be able to make a virtual disk implementation which memory
maps the image file and achieves copy-on-write by setting "shared" to false.
For extra safety we can also open the file read-only.

Luckily there is already an
["mmap" implementation](https://github.com/mirage/xen-disk/blob/master/src/backend.ml#L72)
in `xen-disk`; all we need to do is tweak it slightly.
In the "connect" function we simply need to set "shared" to "false" to
achieve the behaviour we want i.e.

```
let connect id =
  let fd = Unix.openfile (filename_of_id id) [ Unix.O_RDONLY ] 0o0 in
  let stats = Unix.LargeFile.fstat fd in
  let mmap = Cstruct.of_bigarray (Lwt_bytes.map_file ~fd ~shared:false ()) in
  Unix.close fd;
  let size = stats.Unix.LargeFile.st_size in
  return (`Ok { id; size; mmap })
```

The read and write functions can be left as they are:

```
let forall offset bufs f =
  let rec loop offset = function
  | [] -> ()
  | b :: bs ->
    f offset b;
    loop (offset + (Cstruct.len b)) bs in
  loop (Int64.to_int offset * 512) bufs;
  return (`Ok ())

let read t offset bufs =
  forall offset bufs
    (fun offset buf ->
      Cstruct.blit t.mmap offset buf 0 (Cstruct.len buf)
    )

let write t offset bufs =
  forall offset bufs
    (fun offset buf ->
      Cstruct.blit buf 0 t.mmap offset (Cstruct.len buf)
    )
```

Now if we rebuild and run something like:

```
  dd if=/dev/zero of=disk.raw bs=1M seek=1024 count=1

  dist/build/xen-disk/xen-disk connect <myvm> --path disk.raw --backend mmap
```

Inside the VM we should be able to do some basic speed testing:

```
  djs@ubuntu1310:~$ sudo dd if=/dev/xvdg of=/dev/null bs=1M
  16+0 records in
  16+0 records out
  16777216 bytes (17 MB) copied, 0.0276625 s, 606 MB/s
```

Plus we should be able to mount the filesystem inside the VM, make changes and
then disconnect (send SIGINT to xen-disk by hitting Control+C on your terminal)
without disturbing the underlying disk contents.


