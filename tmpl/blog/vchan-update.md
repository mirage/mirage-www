Today's post is an update to [Vincent Bernardoff's](https://github.com/vbmithr)
[introducing vchan](http://openmirage.org/blog/introducing-vchan) blog
post, updated to use the new build system for Mirage. I thought I'd
also take the opportunity to describe the
[Ubuntu-Trusty](http://releases.ubuntu.com/14.04/) environment for
developing and running [Xen](http://www.xenproject.org/) unikernels.

### Installing Xen on Ubuntu

Ubuntu 14.04 has good support for running Xen 4.4, the most recent release (at time of writing).
For running VMs it's a good idea to install Ubuntu on an LVM volume rather than directly on a
partition, which allows the use of LVs as the virtual disks for your VMs. On my system I have
a 40 Gig partition for '/', an 8 Gig swap partition and the rest is free for my VMs:

```
    jludlam@st28:~$ sudo lvs
       LV     VG      Attr      LSize  Pool Origin Data%  Move Log Copy%  Convert
       root   st28-vg -wi-ao--- 37.25g
       swap_1 st28-vg -wi-ao---  7.99g
```

In this particular walkthough I won't be using disks, but later posts will.
Install Xen via the meta-package. This brings in all you will need to run VMs:

```
    jludlam@st28:~$ sudo apt-get install xen-system-amd64
```

It used to be necessary to reorder the grub entries to make sure Xen was started
by default, but this is no longer necessary. Once the machine has rebooted, you
should be able to verify you're running virtualized by invoking 'xl':

```
    jludlam@st28:~$ sudo xl list
	Name                                        ID   Mem VCPUs      State   Time(s)
    Domain-0                                     0  7958     6     r-----       9.7
```

My machine has 8 Gigs of memory, and this list shows that it's all being used by
my dom0, so I'll need to either balloon down dom0 or reboot with a lower maximum
memory. Ballooning is the most straightfoward:

```
    jludlam@st28:~$ sudo xenstore-write /local/domain/0/memory/target 4096000
    jludlam@st28:~$ sudo xl list
    Name                                        ID   Mem VCPUs      State   Time(s)
    Domain-0                                     0  4000     6     r-----      12.2
```

This is handy for quick testing, but is [discouraged](http://wiki.xenproject.org/wiki/Xen_Project_Best_Practices) by the Xen folks. So alternatively, change the xen command line by
editing `/etc/default/grub` and add the line:

```
    GRUB_CMDLINE_XEN_DEFAULT="dom0_mem=4096M,max:4096M"
```

Once again, update-grub and reboot.

### Mirage

Now lets get Mirage up and running. Install ocaml, opam and set up the opam environment:

```
    jludlam@st28:~$ sudo apt-get install ocaml opam ocaml-native-compilers
	...
	jludlam@st28:~$ opam init
	...
	jludlam@st28:~$ eval `opam config env`
```

Don't forget the `ocaml-native-compilers` - without this we can't
compile the unikernels. Now we are almost ready to install Mirage - we
need two more dependencies, and then we're good to go.

```
    jludlam@st28:~$ sudo apt-get install m4 libxen-dev
    jludlam@st28:~$ opam install mirage mirage-xen mirage-unix vchan
```

Where m4 is for ocamlfind, and libxen-dev is required to compile the
unix variants of the xen-evtchn and xen-gnt libraries. Without these
installing vchan will complain that there is no `xen-evtchn.lwt`
library installed.

This second line installs the various Mirage and vchan libraries, but
doesn't build the demo unikernel and unix cli, so to get them clone
the ocaml-vchan repository:

```
    jludlam@st28:~$ git clone http://github.com/mirage/ocaml-vchan
```

The demo unikernel is a very straightforward capitalizing echo server.
The [main function](https://github.com/mirage/ocaml-vchan/blob/master/test/echo.ml#L13) simply consists of

```
    let (>>=) = Lwt.bind

    let (>>|=) m f = m >>= function
    | `Ok x -> f x
    | `Eof -> Lwt.fail (Failure "End of file")
    | `Error (`Not_connected state) -> Lwt.fail (Failure (Printf.sprintf "Not in a connected state: %s" (Sexplib.Sexp.to_string (Node.V.sexp_of_state state))))

    let rec echo vch =
        Node.V.read vch >>|= fun input_line ->
        let line = String.uppercase (Cstruct.to_string input_line) in
        let buf = Cstruct.create (String.length line) in
        Cstruct.blit_from_string line 0 buf 0 (String.length line);
        Node.V.write vch buf >>|= fun () ->
        echo vch

```

where we've defined an error-handling monadic bind (```>>|=```) which
is then used to sequence the read and write operations.

Building the CLI is done simply via `make`.

```
    jludlam@st28:~/ocaml-vchan$ make
    ...
    jludlam@st28:~/ocaml-vchan$ ls -l node_cli.native
	lrwxrwxrwx 1 jludlam jludlam 52 Jul 14 14:56 node_cli.native -> /home/jludlam/ocaml-vchan/_build/cli/node_cli.native
	
```

Building the unikernel is done via the `mirage` tool:

```
    jludlam@st28:~/ocaml-vchan$ cd test
    jludlam@st28:~/ocaml-vchan$ mirage configure --xen
    ...
    jludlam@st28:~/ocaml-vchan$ make depend
    ...
    jludlam@st28:~/ocaml-vchan$ make
    ...
    jludlam@st28:~/ocaml-vchan/test$ ls -l mir-echo.xen echo.xl
    -rw-rw-r-- 1 jludlam jludlam     596 Jul 14 14:58 echo.xl
    -rwxrwxr-x 1 jludlam jludlam 3803982 Jul 14 14:59 mir-echo.xen
```

This make both the unikernel binary (the mir-echo.xen file) and a convenient
xl script to run it. To run, we use the xl tool, passing '-c' to connect
directly to the console so we can see what's going on:

```
    jludlam@st28:~/ocaml-vchan/test$ sudo xl create -c echo.xl
	Parsing config from echo.xl
	kernel.c: Mirage OS!
	kernel.c:   start_info: 0x11cd000(VA)
	kernel.c:     nr_pages: 0x10000
	kernel.c:   shared_inf: 0xdf2f6000(MA)
	kernel.c:      pt_base: 0x11d0000(VA)
	kernel.c: nr_pt_frames: 0xd
	kernel.c:     mfn_list: 0x114d000(VA)
	kernel.c:    mod_start: 0x0(VA)
	kernel.c:      mod_len: 0
	kernel.c:        flags: 0x0
	kernel.c:     cmd_line:
	x86_setup.c:   stack:      0x144f40-0x944f40
	mm.c: MM: Init
	x86_mm.c:       _text: 0x0(VA)
	x86_mm.c:      _etext: 0xb8eec(VA)
	x86_mm.c:    _erodata: 0xde000(VA)
	x86_mm.c:      _edata: 0x1336f0(VA)
	x86_mm.c: stack start: 0x144f40(VA)
	x86_mm.c:        _end: 0x114d000(VA)
	x86_mm.c:   start_pfn: 11e0
	x86_mm.c:     max_pfn: 10000
	x86_mm.c: Mapping memory range 0x1400000 - 0x10000000
	x86_mm.c: setting 0x0-0xde000 readonly
	x86_mm.c: skipped 0x1000
	mm.c: MM: Initialise page allocator for 0x1256000 -> 0x10000000
	mm.c: MM: done
	x86_mm.c: Pages to allocate for p2m map: 2
	x86_mm.c: Used 2 pages for map
	x86_mm.c: Demand map pfns at 10001000-2010001000.
	Initialising timer interface
	Initializing Server domid=0 xs_path=data/vchan
	gnttab_stubs.c: gnttab_table mapped at 0x10001000
	Server: right_order = 13, left_order = 13
	allocate_buffer_locations: gntref = 9
	allocate_buffer_locations: gntref = 10
	allocate_buffer_locations: gntref = 11
	allocate_buffer_locations: gntref = 12
	Writing config into the XenStore
	Shared page is:

    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0d 00 0d 00 02 01 01 00 09 00 00 00 0a 00 00 00
    0b 00 00 00 0c 00 00 00
    Initialization done!
```

Vchan is domain-to-domain communication, and relies on Xen's grant
tables to share the memory. The entries in the grant tables have
domain-level access control, so we need to know the domain ID of the
client and server in order to set up the communications. The test
unikernel server is hard-coded to talk to domain 0, so we only need to
know the domain ID of our echo server. In another terminal,

```
    jludlam@st28:~/ocaml-vchan/test$ sudo xl list
    Name                                        ID   Mem VCPUs      State   Time(s)
    Domain-0                                     0  4095     6     r-----    1602.9
    echo                                         2   256     1     -b----       0.0
```

In this case, the domain ID is 2, so we invoke the CLI as follows:

```
    jludlam@st28:~/ocaml-vchan$ sudo ./node_cli.native 2
	Client initializing: Received gntref = 8, evtchn = 4
	Mapped the ring shared page:

    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0d 00 0d 00 02 01 01 00 09 00 00 00 0a 00 00 00
    0b 00 00 00 0c 00 00 00
    Correctly bound evtchn number 71
```

We're now connected via vchan to the Mirage domain. The test server
is simply a capitalisation service:

```
    hello from dom0
	HELLO FROM DOM0
```

Ctrl-C to get out of the CLI, and destroy the domain with an `xl destroy`:

```
    jludlam@st28:~/ocaml-vchan$ sudo xl destroy test
```



