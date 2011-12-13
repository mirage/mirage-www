This post explains how the Mirage [source repository](http://github.com/avsm/mirage) is laid out for you to browse.  Note that building an operating system consists of a million little details. Mirage is still very much a work-in-progress, so don't be surprised if you run into `TODO` markers all over the source. Better still, fork it on [Github]("http://github.com/avsm/mirage") and send a pull request with your fix!

!!Build

Mirage uses [OCamlbuild](foo) to build the tools and libraries. We build three types of things, each with their own `myocamlbuild.ml` plugin to handle the build dependencies:
 * [tools/](http://github.com/avsm/mirage/tree/master/tools) that help with builds, using the host OCaml toolchain.
 * [syntax/](http://github.com/avsm/mirage/tree/master/syntax) extensions, which also use the host OCaml toolchain and are invoked when building Mirage applications, but are themselves never linked in to the output.
 * [lib/](http://github.com/avsm/mirage/tree/master/lib/) which holds the Mirage OCaml standard library and C/Javascript runtime files for the various backends.

OCamlbuild is a powerful build tool due to its support for dynamic dependency generation, but does take some learning. Please see the [users guide](http://nicolaspouillard.fr/ocamlbuild/ocamlbuild-user-guide.pdf) for more documentation or ask one of the Mirage team.

!!Toolchain

Mirage requires an OCaml 3.12.0 toolchain to be installed, and does not require patching it (instead, we supply a complete replacement standard library). There are a few tools we build as they are tightly coupled with the way Mirage works:

* [tools/mpl]("http://github.com/avsm/mirage/tree/master/tools/mpl/") is the Meta Packet Language (MPL) specification compiler, used to convert Internet packet formats into OCaml parsing and construction modules. It is described in this [EuroSys 2007 paper](http://anil.recoil.org/papers/2007-eurosys-melange.pdf).
* [tools/crunch]("http://github.com/avsm/mirage/tree/master/tools/crunch/") is a "poor man's type-safe memory filesystem". It is a command-line tool that reads in a directory of files, and outputs an OCaml module that serves those files directly as strings. Very useful when the storage sub-system isn't working yet, or (as with this website) everything can be served from RAM easily anyway.
* [tools/mir](http://github.com/avsm/mirage/tree/master/tools/mir/) has the build scripts that wrap ocamlbuild and set the right environment variables for the desired backends.

!!Syntax 

OCaml has a sophisticated syntax extension mechanism known as [camlp4](http://brion.inria.fr/gallium/index.php/Camlp4). Learn the basics by reading Jake Donham's superb [blog series]("http://ambassadortothecomputers.blogspot.com/search/label/camlp4") explaining its intricacies.

Mirage bundles a base set of extensions and bundles them into the [syntax/](http://github.com/avsm/mirage/tree/master/syntax/) directory. This simplifies life considerably from a build perspective and ensures all the extensions used play well together. The distribution currently includes the [LWT](http://ocsigen.org/lwt/doc/api/Pa_lwt.html) extension, the [type-conv](http://hg.ocaml.info/release/type-conv) extension for type-driven meta-programming, the dynamic typing [dyntype](http://github.com/mirage/dyntype) extension, and the [XML](/wiki/htcaml) and [COW](/wiki/cow) web programming helpers.

!!Libraries

The [lib/](http://github.com/avsm/mirage/tree/master/lib/) directory is where the Mirage standard library code lives.

!!!OCaml

We implement as much of Mirage in pure OCaml as possible, which can be found in:

* [lib/std/](http://github.com/avsm/mirage/tree/master/lib/std/) has the replacement standard library. This consists of the OCaml upstream standard library, but somewhat stripped down to remove OS-specific constructs (mainly the `Thread` module as Mirage does not have preemptive threading). For convenience, we also add the core of the [LWT](http://ocsigen.org/lwt/) co-operative threading library and the Ulex Unicode library by Alain Frisch.

* [lib/os/](http://github.com/avsm/mirage/tree/master/lib/os) contains backends for each operating system. This is the low-level code that drives the event loop and device drivers. [lib/os/xen/]("http://github.com/avsm/mirage/tree/master/lib/os/xen/") has the Xen micro-kernel code, [lib/os/unix/](http://github.com/avsm/mirage/tree/master/lib/os/unix) has the POSIX platform code, and [lib/os/node/](http://github.com/avsm/mirage/tree/master/lib/os/node) has the Node.JS code.  Each library maintains a common signature sub-set, so if the platform supports (for example) an Ethernet driver, then that module will have the same signature. At build-time, the relevant module is automatically copied into the standard library as the `OS` module, so the source code never sees the alternative implementations unless it is recompiled using a different backend.

* [lib/net/](http://github.com/avsm/mirage/tree/master/lib/net/) contains the low-level networking code. There are two versions, [lib/net/direct/](http://github.com/avsm/mirage/tree/master/lib/net/direct) which implements Ethernet, ARP, UDP, TCP/IP and DHCP, and [lib/net/socket/](http://github.com/avsm/mirage/tree/master/lib/net/socket) that maps onto UNIX sockets. As with the OS module, only one of these is chosen at build-time depending on the backend in use: e.g. `xen-direct` uses the direct library, and `unix-socket` the socket version.

* [lib/dns/](http://github.com/avsm/mirage/tree/master/lib/dns/) is a DNS server implementation. The data structures are described in Tim Deegan's PhD thesis on the "[Main Name System](http://www.tjd.phlegethon.org/words/thesis.pdf)".

* [lib/http/](http://github.com/avsm/mirage/tree/master/lib/http/) is a HTTP client and server, with support for HTTP/1.1, pipelining and chunked transfers. It is a fork of the [cohttp](http://github.com/avsm/ocaml-cohttp) library adapted for the Mirage namespace.

* [lib/cow/](http://github.com/avsm/mirage/tree/master/lib/cow/) is the Caml-on-the-Web library, with support for common Internet markup formats such as HTML, XML, CSS, Atom and Markdown. It uses the superb [Xmlm](http://erratique.ch/software/xmlm/doc/Xmlm) library by Daniel Bunzli, as well as a series of syntax extensions described more fully [here](/wiki/cow).

!!!Runtime

All of that nice OCaml code in `lib/` also calls a number of `external` functions that must be present in the final binary for the link phase to succeed. These runtimes are either compiled in directly (in the case of Xen), or linked to the host runtime (in the case of UNIX, where OCaml will be installed).

* [lib/os/runtime_xen/](http://github.com/avsm/mirage/tree/master/lib/os/runtime_xen) compiles into a full Xen OS, and so provides the minimal set of C libraries required to run the OCaml runtime directy in a VM. Note that this is currently fatter than it needs to be, as [dietlibc](http://www.fefe.de/dietlibc/) is present at the moment but is largely redundant and will be removed soon. The interesting bits to browse through are in [lib/os/runtime_xen/kernel/](http://github.com/avsm/mirage/tree/master/lib/os/runtime_xen/kernel) which is the mini-operating system core.

* [lib/os/runtime_unix/](http://github.com/avsm/mirage/tree/master/lib/os/runtime_unix) should be familiar to anyone who has built UNIX foreign-function bindings before. It links Mirage applications as native code ELF binaries. It uses [libev](http://software.schmorp.de/pkg/libev.html) to provide high-performance event support, and also provides bindings to both `tuntap` (for the Ethernet device driver) and sockets (for the Flow module).

* [lib/os/runtime_node/](http://github.com/avsm/mirage/tree/master/lib/os/runtime_node) maps an application onto Node.JS.  This one is an experimental, but very fun backend to play with (see [this discussion](https://github.com/dsheets/ocamljs/commit/7bb091f306c93f70bf6e70fe481a38efd71dda5b) for just how weird Javascript integers are).

