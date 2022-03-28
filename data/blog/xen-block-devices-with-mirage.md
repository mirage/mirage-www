---
updated: 2013-07-18
authors:
- name: Dave Scott
  uri: http://dave.recoil.org/
  email: dave@recoil.org
subject: Creating Xen block devices with MirageOS
permalink: xen-block-devices-with-mirage
---

[MirageOS](https://mirage.io/) is a
[unikernel](http://anil.recoil.org/papers/2013-asplos-mirage.pdf)
or "library operating system" that allows us to build applications
which can be compiled to very diverse environments: the same code can be linked
to run as a regular Unix app, relinked to run as a [FreeBSD kernel module](https://github.com/pgj/mirage-kfreebsd),
and even linked into a
self-contained kernel which can run on the [Xen
hypervisor](http://www.xenproject.org/).

Mirage has access to an extensive suite of pure OCaml [libraries](https://github.com/mirage),
covering everything from Xen [block](https://github.com/mirage/ocaml-xen-block-driver) and [network](https://github.com/mirage/mirage-platform/blob/master/xen/lib/netif.ml) virtual device drivers,
a [TCP/IP stack](https://github.com/mirage/mirage-net), OpenFlow learning switches and controllers, to
SSH and [HTTP](https://github.com/mirage/ocaml-cohttp) server implementations.

I normally use Mirage to deploy applications as kernels on top of
a [XenServer](http://www.xenserver.org/) hypervisor. I start by
first using the Mirage libraries within a normal Unix userspace
application -- where I have access to excellent debugging tools --
and then finally link my app as a high-performance Xen kernel for
production.

However Mirage is great for more than simply building Xen kernels.
In this post I'll describe how I've been using Mirage to create
experimental virtual disk devices for existing Xen VMs (which may
themselves be Linux, *BSD, Windows or even Mirage kernels).
The Mirage libraries let me easily
experiment with different backend file formats and protocols, all while
writing only type-safe OCaml code thats runs in userspace in a normal
Linux domain 0.

*Disk devices under Xen*

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

*Xen disk devices in MirageOS*

Like everything else in Mirage, Xen disk devices are implemented as
libraries. The ocamlfind library called "xenctrl" provides support for
manipulating blocks of raw memory pages, "granting" access to them to
other domains and signalling event channels. There are two implementations
of "xenctrl":
[one that invokes Xen "hypercalls" directly](https://github.com/mirage/mirage-platform/tree/master/xen/lib)
 and one which uses the [Xen userspace library libxc](https://github.com/xapi-project/ocaml-xen-lowlevel-libs).
Both implementations satisfy a common signature, so it's easy to write
code which will work in both userspace and kernelspace.

The ocamlfind library
[shared-memory-ring](https://github.com/mirage/shared-memory-ring)
provides functions to create and manipulate request/response rings in shared
memory as used by the disk and network protocols. This library is a mix of
99.9% OCaml and 0.1% asm, where the asm is only needed to invoke memory
barrier operations to ensure that metadata writes issued by one CPU core
appear in the same order when viewed from another CPU core.

Finally the ocamlfind library
[xenblock](https://github.com/mirage/ocaml-xen-block-driver)
provides functions to hotplug and hotunplug disk devices, together with an
implementation of the disk block protocol itself.

*Making custom virtual disk servers with MirageOS*

Let's experiment with making our own virtual disk server based on
the Mirage example program, [xen-disk](https://github.com/mirage/xen-disk).

First, install [Xen](http://www.xen.org/), [OCaml](http://www.ocaml.org/)
and [OPAM](http://opam.ocamlpro.com/). Second initialise your system:

```
  opam init
  eval `opam config env`
```

At the time of writing, not all the libraries were released as upstream
OPAM packages, so it was necessary to add some extra repositories. This
should not be necessary after the Mirage developer preview at
[OSCON 2013](http://www.oscon.com/oscon2013/public/schedule/detail/28956).

```
  opam remote add mirage-dev git://github.com/mirage/opam-repo-dev
  opam remote add xapi-dev git://github.com/xapi-project/opam-repo-dev
```

Install the unmodified `xen-disk` package, this will ensure all the build
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

which will hotplug a fresh block device into the VM "`<vmname>`" using the
"discard" backend, which returns "success" to all read and write requests,
but actually throws all data away. Obviously this backend should only be
used for basic testing!

Assuming that worked ok, clone and build the source for `xen-disk` yourself:

```
  git clone git://github.com/mirage/xen-disk
  cd xen-disk
  make
```

*Making a custom virtual disk implementation*

The `xen-disk` program has a set of simple built-in virtual disk implementations.
Each one satisifies a simple signature, contained in
[src/storage.mli](https://github.com/mirage/xen-disk/blob/master/src/storage.mli):

```
type configuration = {
  filename: string;      (** path where the data will be stored *)
  format: string option; (** format of physical data *)
}
(** Information needed to "open" a disk *)

module type S = sig
  (** A concrete mechanism to access and update a virtual disk. *)

  type t
  (** An open virtual disk *)

  val open_disk: configuration -> t option Lwt.t
  (** Given a configuration, attempt to open a virtual disk *)

  val size: t -> int64
  (** [size t] is the size of the virtual disk in bytes. The actual
      number of bytes stored on media may be different. *)

  val read: t -> Cstruct.t -> int64 -> int -> unit Lwt.t
  (** [read t buf offset_sectors len_sectors] copies [len_sectors]
      sectors beginning at sector [offset_sectors] from [t] into [buf] *)

  val write: t -> Cstruct.t -> int64 -> int -> unit Lwt.t
  (** [write t buf offset_sectors len_sectors] copies [len_sectors]
      sectors from [buf] into [t] beginning at sector [offset_sectors]. *)
end
```

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
["mmap" implementation](https://github.com/mirage/xen-disk/blob/master/src/backend.ml#L63)
in `xen-disk`; all we need to do is tweak it slightly.
Note that the `xen-disk` program uses a co-operative threading library called
[lwt](http://ocsigen.org/lwt/)
which replaces functions from the OCaml standard library which might block
with non-blocking variants. In
particular `lwt` uses `Lwt_bytes.map_file` as a wrapper for the
`Bigarray.Array1.map_file` function.
In the "open-disk" function we simply need to set "shared" to "false" to
achieve the behaviour we want i.e.

```
  let open_disk configuration =
    let fd = Unix.openfile configuration.filename [ Unix.O_RDONLY ] 0o0 in
    let stats = Unix.LargeFile.fstat fd in
    let mmap = Lwt_bytes.map_file ~fd ~shared:false () in
    Unix.close fd;
    return (Some (stats.Unix.LargeFile.st_size, Cstruct.of_bigarray mmap))
```

The read and write functions can be left as they are:

```
  let read (_, mmap) buf offset_sectors len_sectors =
    let offset_sectors = Int64.to_int offset_sectors in
    let len_bytes = len_sectors * sector_size in
    let offset_bytes = offset_sectors * sector_size in
    Cstruct.blit mmap offset_bytes buf 0 len_bytes;
    return ()

  let write (_, mmap) buf offset_sectors len_sectors =
    let offset_sectors = Int64.to_int offset_sectors in
    let offset_bytes = offset_sectors * sector_size in
    let len_bytes = len_sectors * sector_size in
    Cstruct.blit buf 0 mmap offset_bytes len_bytes;
    return () 
```

Now if we rebuild and run something like:

```
  dd if=/dev/zero of=disk.raw bs=1M seek=1024 count=1
  losetup /dev/loop0 disk.raw
  mkfs.ext3 /dev/loop0
  losetup -d /dev/loop0

  dist/build/xen-disk/xen-disk connect <myvm> --path disk.raw
```

Inside the VM we should be able to do some basic speed testing:

```
  # dd if=/dev/xvdb of=/dev/null bs=1M iflag=direct count=100
  100+0 records in
  100+0 records out
  104857600 bytes (105 MB) copied, 0.125296 s, 837 MB/s
```

Plus we should be able to mount the filesystem inside the VM, make changes and
then disconnect (send SIGINT to xen-disk by hitting Control+C on your terminal)
without disturbing the underlying disk contents.

*So what else can we do?*

Thanks to Mirage it's now really easy to experiment with custom storage types
for your existing VMs. If you have a cunning scheme where you want to hash block contents,
and use the hashes as keys in some distributed datastructure -- go ahead, it's
all easy to do. If you have ideas for improving the low-level block access protocol
then Mirage makes those experiments very easy too.

If you come up with a cool example with Mirage, then send us a
[pull request](https://github.com/mirage) or send us an email to the
[Mirage mailing list](https://mirage.io/about/) -- we'd
love to hear about it!

