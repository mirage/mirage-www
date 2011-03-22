The Mirage [source code]("http://github.com/avsm/mirage") consists of quite a few major pieces, and I've had several questions asking about its layout. This post explains how the repository is laid out if you want to browse.

*Caveat*: building an operating system consists of a million little details. Mirage is still very much a work-in-progress, so don't be surprised if you run into `TODO` markers all over the source. Better still, fork it on [Github]("http://github.com/avsm/mirage") and send a pull request with your fix!

!!Toolchain

There are quite a few diverse backends available, from operating system microkernel to running in a web browser. Mirage bundles all of the necessary toolchain in the `tools/` directory. This also makes it easy to apply local patches to specialise them for our use.  Right now the compilers included are:

* [`tools/ocaml`]("http://github.com/avsm/mirage/tree/master/tools/ocaml/") has the main OCaml bytecode and native code compiler.
* [`tools/ocamljs`]("http://github.com/avsm/mirage/tree/master/tools/ocamljs/") is the OCaml to Javascript compiler written by [Jake Donham](https://github.com/jaked/ocamljs).
* [`tools/ocaml-libs`]("http://github.com/avsm/mirage/tree/master/tools/ocaml-libs/") has a collection of useful libraries used by the host-toolchain (for example in the `camlp4` syntax extensions to parse Unicode or XML).
* [`tools/ocamldsort`]("http://github.com/avsm/mirage/tree/master/tools/ocamldsort/") is a dependency sorter for OCaml source files, written by [Dimitri Ara](http://dimitri.mutu.net/ocaml.html).
* [`tools/mpl`]("http://github.com/avsm/mirage/tree/master/tools/mpl/") is the Meta Packet Language (MPL) specification compiler, used to convert Internet packet formats into OCaml parsing and construction modules. It is described in this [EuroSys 2007 paper](http://anil.recoil.org/papers/2007-eurosys-melange.pdf).

There are also a few glorious hacks in that directory which may or may not continue to exist as things stabilise:

* [`tools/ocamlpack`]("http://github.com/avsm/mirage/tree/master/tools/ocamlpack/") takes multiple source OCaml files and outputs a single module file with them all included as sub-modules. This is needed due to limitations in the built-in binary `-pack` option; it doesn't work with `ocamljs` or `ocamldoc`.
* [`tools/crunch`]("http://github.com/avsm/mirage/tree/master/tools/crunch/") is a "poor man's type-safe memory filesystem". It is a command-line tool that reads in a directory of files, and outputs an OCaml module that serves those files directly as strings. Very useful when the storage sub-system isn't working yet, or (as with this website) everything can be served from RAM easily anyway.

Finally, [`tools/mir`]("http://github.com/avsm/mirage/tree/master/tools/mir/") has the actual build utility for Mirage that hides away all the complexity of building across the various backends. I'll blog about how to use this in a separate post.

!!Libraries

The [`lib/`]("http://github.com/avsm/mirage/tree/master/lib/") directory is where all the pure OCaml code lives. There is no C code here at all.

* [`lib/std`]("http://github.com/avsm/mirage/tree/master/lib/std/") has the standard library infrastructure. This consists of the OCaml upstream standard library in [`lib/std/native`]("http://github.com/avsm/mirage/tree/master/lib/std/native"), but somewhat stripped down to remove OS-specific constructs (mainly the `Thread` module as Mirage does not have preemptive threading). The equivalent Javascript standard library from `ocamljs` is present in [`lib/std/js`]("http://github.com/avsm/mirage/tree/master/lib/std/js"), again stripped down and with support for Javascript quotations.  Finally, a modified version of the [LWT](http://ocsigen.org/lwt/) co-operative threading library is present in [`lib/std/lwt`]("http://github.com/avsm/mirage/tree/master/lib/std/lwt"). Although it is currently a separate library, we plan to integrate it with the stndard library to make it available by default to Mirage modules (as the `Pervasives` library is).

* [`lib/os`]("http://github.com/avsm/mirage/tree/master/lib/std/os") has the backends for each operating system. This is the low-level code that drives the event loop and device drivers. [`lib/os/xen`]("http://github.com/avsm/mirage/tree/master/lib/os/xen/") has all the Xen micro-kernel code, [`lib/os/unix`]("http://github.com/avsm/mirage/tree/master/lib/os/unix") has the POSIX platform code, and [`lib/os/browser`]("http://github.com/avsm/mirage/tree/master/lib/os/browser") has the Javascript implementations.  Each library maintains a common signature, so if the platform supports (for example) an Ethernet driver, then that module will have the same signature.

* [`lib/net`]("http://github.com/avsm/mirage/tree/master/lib/net/") contains all the networking code. This starts from low-level Ethernet, ARP, and TCP/IP in [`lib/net/ether`]("http://github.com/avsm/mirage/tree/master/lib/net/ether"), to DHCP in [`lib/net/dhcp`]("http://github.com/avsm/mirage/tree/master/lib/net/dhcp/"), to DNS in [`lib/net/dns`]("http://github.com/avsm/mirage/tree/master/lib/net/dns") and HTTP in [`lib/net/http`]("http://github.com/avsm/mirage/tree/master/lib/net/http"). All of this code runs either against the [`netfront`]("http://wiki.xensource.com/xenwiki/XenNetFrontBackInterface") driver in Xen, or on the user-level `tuntap` interface under Linux or MacOS X. There is also an alternative higher-level implementation which uses the POSIX socket API in [`lib/net/flow`]("http://github.com/avsm/mirage/tree/master/lib/net/flow"). As the OCaml implementation of TCP/IP matures, it will have the same interface as the `Flow` module, so the same code will interoperate.

* [`lib/misc`]("http://github.com/avsm/mirage/tree/master/lib/misc/") is a catch-all for the other library code, such as text processing. In there, you will find the superb [Xmlm](http://erratique.ch/software/xmlm/doc/Xmlm) library by Daniel Bunzli, and an [Atom](http://tools.ietf.org/html/rfc4287) library that generates the feed on this website. Code here will be promoted to a separate directory (probably `textproc`) as it stabilises.

!!Syntax 

OCaml has a sophisticated syntax extension mechanism known as [`camlp4`]("http://brion.inria.fr/gallium/index.php/Camlp4"). Learn the basics by reading Jake Donham's superb [blog series]("http://ambassadortothecomputers.blogspot.com/search/label/camlp4") explaining its intricacies.

Mirage blesses a standard set of extensions, bundles them into the [`syntax/`]("http://github.com/avsm/mirage/tree/master/syntax/") directory, and builds a single library that is applied by default to all Mirage applications. This simplifies life considerably from a build perspective and ensures that all the extensions used play well together. The distribution currently includes the [LWT](http://ocsigen.org/lwt/doc/api/Pa_lwt.html) extension in [`syntax/lwt`]("http://github.com/avsm/mirage/tree/master/syntax/lwt"), the `type-conv` extension in [`syntax/type-conv`]("http://github.com/avsm/mirage/tree/master/syntax/type-conv") to help with type-driven meta-programming, the dynamic typing [`dyntype`]("http://github.com/mirage/dyntype") dynamic typing extension in [`dyntype`]("http://github.com/avsm/mirage/tree/master/syntax/dyntype"), and an [XML]("/wiki/htcaml") syntax extension.

!!Runtime

All of that nice OCaml code in `lib/` also calls a number of `external` functions that must be present in the final binary for the link phase to succeed. These are provided by the [`runtime/`]("http://github.com/avsm/mirage/tree/master/runtime") for the chosen target backend.

* [`runtime/xen`]("http://github.com/avsm/mirage/tree/master/runtime/xen") compiles into a full Xen OS, and so provides the minimal set of C libraries required to run the OCaml runtime on the bare virtual metal. Note that this is currently fatter than it needs to be, as [`dietlibc`]("http://www.fefe.de/dietlibc/") is present at the moment but is largely redundant and will be removed soon. The interesting bits to browse through are in [`runtime/xen/kernel`]("http://github.com/avsm/mirage/tree/master/runtime/xen/kernel") which has a small MiniOS along with the OCaml runtime integration.

* [`runtime/unix`]("http://github.com/avsm/mirage/tree/master/runtime/unix") should be familiar to anyone who has built UNIX foreign-function bindings before. It permits Mirage applications to run as native code ELF binaries. It uses [`libev`]("http://software.schmorp.de/pkg/libev.html") to provide high-performance event support, and also provides bindings to both `tuntap` (for the Ethernet device driver) and sockets (for the Flow module).

* [`runtime/browser`]("http://github.com/avsm/mirage/tree/master/runtime/browser") maps the OS signature onto Javascript. The LWT event system maps onto DOM timer callbacks, the Console maps onto a `div` tag, and so forth. This one is an experimental, but very fun backend to play with (see [this discussion](https://github.com/dsheets/ocamljs/commit/7bb091f306c93f70bf6e70fe481a38efd71dda5b) for just how weird Javascript integers are).

This was a whirlwind tour through the source repository. Expect more writeups on the individual topics shortly...
