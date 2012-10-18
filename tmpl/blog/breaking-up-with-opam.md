When we first started developing Mirage in 2009, we were rewriting huge chunks of operating system and runtime code in OCaml. This ranged from low-level device drivers to higher-level networking protocols such as TCP/IP or HTTP.  The changes weren't just straight rewrites of C code either, but also involved experimenting with interfaces such as iteratees and [lightweight threading](/wiki/tutorial-lwt) to take advantage of OCaml's static type system.  To make all of this easy to work with, we decided to lump everything into a [single Git repository](http://github.com/avsm/mirage) that would bootstrap the entire system with a single `make` invocation.

Nowadays though, Mirage is self-hosting, the interfaces are settling down, the number of libraries are growing every day, and portions of it are being used in [the Xen Cloud Platform](/blog/xenstore-stub-domain). So for the first developer release, we wanted to split up the monolithic repository into more manageable chunks, but still make it as easy as possible for the average OCaml developer to try out Mirage.

Thanks to much hard work from [Thomas](http://gazagnaire.org) and his colleagues at [OCamlPro](http://ocamlpro.com), we now have [OPAM](http://opam.ocamlpro.com): a fully-fledged package manager for Mirage!  OPAM is a source-based package manager that supports a growing number of community OCaml libraries.  More importantly for Mirage, it can also switch between multiple compiler installations, and so support cross-compiled runtimes and modified standard libraries.

OPAM includes compiler variants for Mirage-friendly environments for Xen and the UNIX `tuntap` backends.  The [installation instructions](/wiki/install) now give you instructions on how to use OPAM, and the old monolithic repository is considered deprecated.  We're still working on full documentation for the first beta release, but all the repositories are on the [Mirage organisation](http://github.com/mirage) on Github, with some of the important ones being:

* [mirage-platform](http://github.com/mirage/mirage-platform) has the core runtime for Xen and UNIX, implemented as the `OS` module.
* [mirage-net](http://github.com/mirage/mirage-net) has the TCP/IP networking stack.
* [ocaml-cstruct](http://github.com/mirage/ocaml-cstruct) has the camlp4 extension to manipulate memory like C `struct`s, but with type-safe accessors in OCaml.
* [ocaml-xenstore](http://github.com/mirage/ocaml-xenstore) has a portable implementation of the Xenstore protocol to communicate with the Xen management stack from a VM (or even act as a [server in a stub domain](/blog/xenstore-stub-domain)).
* [ocaml-dns](http://github.com/mirage/ocaml-dns) is a pure OCaml implementation of the DNS protocol, including a server and stub resolver.
* [ocaml-re](http://github.com/mirage/ocaml-re) is a pure OCaml version of several regular expression engines, including Perl compatibility.
* [ocaml-uri](http://github.com/mirage/ocaml-uri) handles parsing the surprisingly complex URI strings.
* [ocaml-cohttp](http://github.com/mirage/ocaml-cohttp) is a portable HTTP parser, with backends for Mirage, Lwt and Core/Async. This is a good example of how to factor out OS-specific concerns using the OCaml type system (and I plan to blog more about this soon).
* [ocaml-cow](http://github.com/mirage/ocaml-cow) is a set of syntax extensions for JSON, CSS, XML and XHTML, which are explained [here](/wiki/cow), and used by this site.
* [ocaml-dyntype](http://github.com/mirage/dyntype) uses camlp4 to [generate dynamic types](http://anil.recoil.org/papers/2011-dynamics-ml.pdf) and values from OCaml type declarations.
* [ocaml-orm](http://github.com/mirage/orm) auto-generates SQL scheme from OCaml types via Dyntype, and currently supports SQLite.
* [ocaml-openflow](http://github.com/mirage/ocaml-openflow) implements an OCaml switch and controller for the Openflow protocol.

There are quite a few more that are still being hacked for release by the team, but we're getting there very fast now. We also have the Mirage ports of [SSH](http://github.com/avsm/ocaml-ssh) to integrate before the first release this year, and Haris has got some [interesting DNSSEC](http://github.com/mirage/ocaml-crypto-keys) code!  If you want to get involved, join the [mailing list](/about) or IRC channel!
