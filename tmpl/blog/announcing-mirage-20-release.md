<small>
  This work funded in part by the EU FP7 User-Centric Networking project, Grant
  No. 611001.
</small>

The [first release](http://openmirage.org/blog/announcing-mirage10) of Mirage back in December 2013 introduced the prototype
of the [unikernel concept](http://queue.acm.org/detail.cfm?id=2566628), which realised the promise of a safe,
flexible mechanism to build highly optimized software stacks purpose-built for deployment in the public cloud (more [background](http://openmirage.org/wiki/overview-of-mirage) on this).
Since then, we've been hard at work using and extending Mirage for real projects and the community has been
[steadily growing](http://openmirage.org/blog/welcome-to-our-summer-hackers).

We're thrilled to announce the release of Mirage OS v2.0 today!  Over the past
few weeks the [team][] has been [hard at work][blog-track] blogging about all
the new features in this latest release, coordinated by the tireless [Amir Chaudhry][amirmc]:

<img src="/graphics/cubieboard2.jpg" style="float:right; padding: 5px" width="250px" />

* **ARM device support**: While the first version of Mirage was specialised towards conventional x86 clouds, the code generation and boot libraries have now been made portable enough to operate on low-power embedded ARM devices such as the [Cubieboard 2][cubie2].  This is a key part of our efforts to build a safe, unified [mutiscale programming model][multiscale] for both cloud and mobile workloads as part of the [Nymote][nymote] project.  We also upstreamed the changes required to the Xen Project so that other unikernel efforts such as [HalVM](https://github.com/GaloisInc/HaLVM) or [ClickOS](https://www.usenix.org/system/files/conference/nsdi14/nsdi14-paper-martins.pdf) can benefit.
  - *"[Introducing an ARMy of unikernels](http://openmirage.org/blog/introducing-xen-minios-arm)"* by [Thomas Leonard][talex5] talks about the changes required and [instructions](http://openmirage.org/wiki/xen-on-cubieboard2) for trying this out for yourself on your own cheap Cubieboard.
* **Irmin distributed, branchable storage**: Unikernels usually execute in a distributed, disconnection-prone environment (particularly with the new mobile ARM support).  We therefore built the [Irmin][irmin] library to explicitly make synchronization easier via a Git-like persistence model that can be used to build and easily trace the operation of distributed applications across all of these diverse environments.
  - *"[Introducing Irmin: Git-like distributed, branchable storage](http://openmirage.org/blog/introducing-irmin)"* by [Thomas Gazagnaire][tg] describes the concepts and high-level architecture of the system.
  - *"[Using Irmin to add fault-tolerance to the Xenstore database](http://openmirage.org/blog/introducing-irmin-in-xenstore)"* by [Dave Scott][djs] shows how Irmin is used in a real-world application: the security-critical Xen toolstack that manages hosts full of virtual machines ([video](https://www.youtube.com/watch?v=DSzvFwIVm5s)).
* **OCaml TLS**: The philosophy of Mirage is to construct the entire operating system in a safe programming style, from the device drivers up.  This continues in this release with a comprehensive OCaml implementation of [Transport Level Security][tls], the most widely deployed end-to-end encryption protocol on the Internet (and one that is very prone to [bad security holes][heartbleed]).  The blog series is written by [Hannes Mehnert][hannes] and [David Kaloper][dkaloper].
  - *"[OCaml-TLS: Introducing transport layer security (TLS) in pure OCaml](http://openmirage.org/blog/introducing-ocaml-tls)"* presents the motivation and architecture behind our clean-slate implementation of the protocol.
  - *"[OCaml-TLS: building the nocrypto library core](http://openmirage.org/blog/introducing-nocrypto)"* talks about the cryptographic primitives that form the heart of TLS confidentiality guarantees, and how they expose safe interfaces to the rest of the stack.
  - *"[OCaml-TLS: adventures in X.509 certificate parsing and validation](http://openmirage.org/blog/introducing-x509)"* explains how authentication and chain-of-trust verification is implemented in our stack.
  - *"[OCaml-TLS: ASN.1 and notation embedding](http://openmirage.org/blog/introducing-asn1)"* introduces the libraries needed for handling ASN.1 grammars, the wire representation of messages in TLS.
  - *"[OCaml-TLS: the protocol implementation and mitigations to known attacks](http://openmirage.org/blog/ocaml-tls-api-internals-attacks-mitigation)"* concludes with the implementation of the core TLS protocol logic itself.
- **Modularity and communication**: Mirage is built on the concept of a [library operating system](http://anil.recoil.org/papers/2013-asplos-mirage.pdf), and this release provides many new libraries to flexibly extend applications with new functionality.
  - *"[Fitting the modular Mirage TCP/IP stack together](http://openmirage.org/blog/intro-tcpip)"* by [Mindy Preston][mindy] explains the rather unique modular architecture of our TCP/IP stack that lets you swap between the conventional Unix sockets API, or a complete implementation of TCP/IP in pure OCaml.
  - *"[Vchan: low-latency inter-VM communication channels](http://openmirage.org/blog/update-on-vchan)"* by [Jon Ludlam][jludlam] shows how unikernels can communicate efficiently with each other to form distributed clusters on a multicore Xen host, by establishing shared memory rings with each other.
  - *"[Modular foreign function bindings](http://openmirage.org/blog/modular-foreign-function-bindings)"* by [Jeremy Yallop][yallop] continues the march towards abstraction by expaining how to interface safely with code written in C, without having to write any unsafe C bindings!  This forms the basis for allowing Xen unikernels to communicate with existing libraries that they may want to keep at arm's length for security reasons.

All the libraries required for these new features are [regularly
released](/releases) into the [OPAM](http://opam.ocaml.org) package manager, so
just follow the [installation instructions](/wiki/install) to give them a spin.
A release this size probably introduces minor hiccups that may cause build
failures, so we very much encourage [bug
reports](https://github.com/mirage/mirage/issues) on our issue tracker or
[questions](/community) to our mailing lists.  Don't be shy: no question is too
basic, and we'd love to hear of any weird and wacky uses you put this new
release to!  And finally, the lifeblood of Mirage is about sharing and
[publishing libraries](http://opam.ocaml.org/doc/Packaging.html) that add new functionality to the framework, so do get
involved and open-source your own efforts.

*Breaking news*: [Richard Mortier][mort] and I will be speaking at [OSCON](http://www.oscon.com) this week on Thursday morning about the new features [in F150 in the Cloud Track](http://www.oscon.com/oscon2014/public/schedule/detail/35024). Come along if you are in rainy Portland at the moment!

[blog-track]: https://github.com/mirage/mirage/issues/257
[team]: http://openmirage.org/community
[nymote]: http://nymote.org
[irmin]: https://github.com/mirage/irmin
[tls]: https://en.wikipedia.org/wiki/Transport_Layer_Security
[heartbleed]: https://en.wikipedia.org/wiki/Heartbleed
[multiscale]: http://anil.recoil.org/papers/2010-bcs-visions.pdf
[cubie2]: http://cubieboard.org/
[talex5]: http://roscidus.com/blog/
[djs]: http://dave.recoil.org
[tg]: http://gazagnaire.org
[hannes]: https://github.com/hannesm
[dkaloper]: https://github.com/pqwy
[mindy]: http://somerandomidiot.com
[jludlam]: http://jon.recoil.org
[yallop]: https://github.com/yallop
[amirmc]: http://amirchaudhry.com
[mort]: http://mort.io
