An action-packed year has flown by for Mirage, and it's time for a little recap of what's been happening and the plans for the new year.
We announced [Mirage 1.0](http://openmirage.org/blog/announcing-mirage10) just over a year ago, and 2014 also saw a major [2.0 summer release](http://openmirage.org/blog/announcing-mirage-20-release) and the growth of a developer community that have been building support for IPv6, Transport Layer Security, on-demand spawning, profiling and much more.  There have been 205 individual library [releases](http://openmirage.org/releases), 25 [presentations](http://decks.openmirage.org), and lots of [online chatter](http://openmirage.org/links) through the year, so here follows a summary of our major activities recently.

### Clean-Slate Transport Layer Security

<a href="http://media.ccc.de/browse/congress/2014/31c3_-_6443_-_en_-_saal_2_-_201412271245_-_trustworthy_secure_modular_operating_system_engineering_-_hannes_-_david_kaloper.html#video"><img src="/graphics/tls-31c3.png" style="float:right; padding: 5px" width="300px" /></a>

David Kaloper and Hannes Mehnert started 2014 with getting interested in writing a [safer and cleaner TLS stack](https://ocaml.org/meetings/ocaml/2014/ocaml2014_4.pdf) in OCaml, and ended the year with a complete demonstration and talk last week in [31C3](http://media.ccc.de/browse/congress/2014/31c3_-_6443_-_en_-_saal_2_-_201412271245_-_trustworthy_secure_modular_operating_system_engineering_-_hannes_-_david_kaloper.html#video), the premier hacker conference!  Their blog posts over the summer remain an excellent introduction to the new stack:

- *"[OCaml-TLS: Introducing transport layer security (TLS) in pure OCaml](http://openmirage.org/blog/introducing-ocaml-tls)"* presents the motivation and architecture behind our clean-slate implementation of the protocol.
- *"[OCaml-TLS: building the nocrypto library core](http://openmirage.org/blog/introducing-nocrypto)"* talks about the cryptographic primitives that form the heart of TLS confidentiality guarantees, and how they expose safe interfaces to the rest of the stack.
- *"[OCaml-TLS: adventures in X.509 certificate parsing and validation](http://openmirage.org/blog/introducing-x509)"* explains how authentication and chain-of-trust verification is implemented in our stack.
- *"[OCaml-TLS: ASN.1 and notation embedding](http://openmirage.org/blog/introducing-asn1)"* introduces the libraries needed for handling ASN.1 grammars, the wire representation of messages in TLS.
- *"[OCaml-TLS: the protocol implementation and mitigations to known attacks](http://openmirage.org/blog/ocaml-tls-api-internals-attacks-mitigation)"* concludes with the implementation of the core TLS protocol logic itself.

By summer, the stack was complete enough to connect to the majority of TLS 1.0+ sites on the Internet, and work progressed to integration with the remainder of the Mirage libraries.  By November, the [Conduit](https://github.com/mirage/ocaml-conduit) network library had Unix support for both the [OpenSSL/Lwt](https://github.com/savonet/ocaml-ssl) bindings and the pure OCaml stack, with the ability to dynamically select them.  You can now deploy and test the pure OCaml TLS stack on a webserver simply by:

    opam install lwt tls cohttp
    export CONDUIT_TLS=native
    cohttp-server-lwt -c <certfile> -p <port> <directory>

This will spin up an HTTPS server that serves the contents of `<directory>` to you over TLS.
At the same time, we were also working on integrating the TLS stack into the Xen unikernel backend, so we could run completely standalone.  This required some surgery:

- The [nocrypto](https://github.com/mirleft/ocaml-nocrypto) crypto core is written in C, so we had to improve support for linking in external C libraries.  Since the Xen unikernel is a single address-space custom kernel, we also need to be careful to compile it with the correct compilation flags or else risk [subtle bugs](https://github.com/mirage/mirage-tcpip/issues/80). Thomas Leonard completely rearranged the Mirage compilation pipeline to support [separation compilation of C stubs](https://github.com/mirage/mirage/pull/332), and we had the opportunity to remove lots of duplicated code within [mirage-platform](https://github.com/mirage/mirage-platform) as a result of this work.
- Meanwhile, the problem of gathering entropy in a virtual machine reared its head.  We created a [mirage-entropy](https://github.com/mirage/mirage-entropy) device driver, and an [active discussion](http://lists.xenproject.org/archives/html/mirageos-devel/2014-11/msg00146.html) ensued about how best to gather reliable randomness from Xen.  [Dave Scott](http://dave.recoil.org) built the best solution -- the [xenentropyd](https://github.com/mirage/xentropyd) that proxies entropy from dom0 to a unikernel VM.
- David Kaloper also ported the `nocrypto` library to use the [OCaml-Ctypes](https://github.com/ocamllabs/ocaml-ctypes) library, which increases the safety of the C bindings significantly.  This is described in more detail in the "[Modular foreign function bindings](http://openmirage.org/blog/modular-foreign-function-bindings)" blog post from the summer.  This forms the basis for allowing Xen unikernels to communicate with C code, and integration with the Mirage toolchain will continue to improve next year.

You can see [Hannes and David present OCaml-TLS](http://media.ccc.de/browse/congress/2014/31c3_-_6443_-_en_-_saal_2_-_201412271245_-_trustworthy_secure_modular_operating_system_engineering_-_hannes_-_david_kaloper.html#video) at CCC online.  It's been a real pleasure watching their work develop in the last 12 months with such precision and attention to detail!

### HTTP and JavaScript

[Rudi Grinberg](http://rgrinberg.com/) got sufficiently irked with the poor state of documentation for the [CoHTTP](https://github.com/mirage/ocaml-cohttp) library that he began gently contributing fixes towards the end of 2013, and rapidly became one of the maintainers.  He also began improving the ecosystem around the web stack by building a HTTP routing layer, described in his blog posts:

- *[Type Safe Routing - Baby Steps](http://rgrinberg.com/blog/2014/12/13/primitive-type-safe-routing/)*: type-safe routing of URLs to avoid dangling links
- *[Introducing Opium](http://rgrinberg.com/blog/2014/04/04/introducing-opium/)*: middleware for REST services
- *[Middleware in Opium](http://rgrinberg.com/blog/2014/04/11/middleware-intro/)*: a walkthrough the Opium HTTP middleware model
- *[Introducing Humane-Re](http://rgrinberg.com/blog/2014/05/23/humane-re-intro/)*: more friendly regular expression interfaces

Meanwhile, [Andy Ray](http://www.ujamjar.com/) started developing [HardCaml](http://www.ujamjar.com/hardcaml/) (a register transfer level hardware design system) in OCaml, and built the [iocamljs](https://andrewray.github.io/iocamljs/) interactive browser notebook.  This uses [js_of_ocaml](http://ocsigen.org/js_of_ocaml) to port the *entire* OCaml compilation toolstack to JavaScript, including `ocamlfind`, Lwt threading and dynamic loading support.  The results are browsable [online](https://andrewray.github.io/iocamljs/), and it is now easy to generate a JavaScript-driven interactive page for many Mirage libraries.

An interesting side effect of Andy's patches were the addition of a [JavaScript port](https://github.com/mirage/ocaml-cohttp/pull/172) to the CoHTTP library.  For those not familiar with the innards, CoHTTP uses the [OCaml module system](https://realworldocaml.org/v1/en/html/functors.html) to build a very portable HTTP implementation that can make mapped to different I/O models (Lwt or Async cooperative threading or POSIX blocking I/O), and to different operating systems (e.g. Unix or Mirage).  The JavaScript support mapped the high-level modules in CoHTTP to the XMLHTTPRequest native to JavaScript, allowing the same OCaml HTTP client code to run efficiently on Unix, Windows and now an IOCamlJS browser instance. 

Mirage uses a number of libraries developed by the [Ocsigen](http://ocsigen.org) team at [IRILL](http://irill.org) in Paris, and so I was thrilled to [deliver a talk](https://www.irill.org/videos/oups-december-2014/MirageOS) there in December.  Romain Calascibetta started integrating Ocsigen and Mirage over the summer, and the inevitable plotting over beer in Paris lead [Gabriel Radanne](https://github.com/Drup) to kick off an effort to integrate the complete Ocsigen web stack into Mirage. Head to [ocsigen/ocsigenserver#54](https://github.com/ocsigen/ocsigenserver/issues/54) if you're interested in seeing this happen in 2015!
I also expect the JavaScript and Mirage integration to continue to improve in 2015, thanks to large industrial users such as [Facebook](https://github.com/facebook) adopting `js_of_ocaml` in their open-source tools such as [Hack](https://github.com/facebook/hack) and [Flow](https://github.com/facebook/flow).

### IPv6

We've wanted IPv6 support in Mirage since its inception, and several people contributed to making this possible.  At the start of the year, [Hugo Heuzard](https://github.com/hhugo) and [David Sheets](https://github.com/dsheets) got [IPv6 parsing support](https://github.com/mirage/ocaml-ipaddr/pull/9) into the `ipaddr` library (with me watching bemusedly at how insanely complex parsing is versus IPv4).

Meanwhile, [Nicolas Ojeda Bar](https://www.dpmms.cam.ac.uk/~no263/) had been building OCaml networking libraries independently for some time, such as a [IMAP client](https://github.com/nojb/ocaml-imap), [Maildir](https://github.com/nojb/ocaml-maildir) handler, and a [Bittorrent](https://github.com/nojb/ocaml-bt) client.  He became interested in the networking layer of Mirage, and performed a [comprehensive cleanup](https://github.com/mirage/mirage-tcpip/pull/70)  that resulted in a more modular stack that now supports both IPv4 and IPv6!

The addition of IPv6 support also forced us to consider how to simplify the configuration frontend to Mirage unikernels that was [originally written](http://openmirage.org/blog/mirage-1.1-released) by Thomas Gazagnaire and [described here](http://openmirage.org/blog/intro-tcpip) by Mindy Preston.
Nicolas has [proposed](http://lists.xenproject.org/archives/html/mirageos-devel/2014-12/msg00001.html) a declarative extension to the configuration that allows applications to extend the `mirage` command-line more easily, thus unifying the "built-in" Mirage compilation modes (such as choosing between Xen or Unix) and protocol-specific choices (such as configuring IPv4 and IPv6).

The new approach opens up the possibility of writing more user-friendly configuration frontends that can render them as a text- or web-based selectors, which is really important as more real-world uses of Mirage are being created.  It should be possible in 2015 to solve common problems such as web or DNS serving without having to write a single line of OCaml code.

### Profiling

<a href="http://roscidus.com/blog/blog/2014/10/27/visualising-an-asynchronous-monad"><img src="http://roscidus.com/blog/images/mirage-profiling/block-reads-3-32.png" style="float:right; padding: 5px" width="300px" /></a>

One of the benefits touted by our CACM article on [unikernels](http://queue.acm.org/detail.cfm?id=2566628) at the start of the year was the improved tooling from the static linking of an entire application stack with an operating system layer.
[Thomas Leonard](http://roscidus.com) joined the project this year after publishing a widely read [blog series](http://roscidus.com/blog/blog/2014/06/06/python-to-ocaml-retrospective/) on his experiences from switching from Python to OCaml.
Aside from leading (and upstreaming to Xen) the port of [Mirage to ARM](http://openmirage.org/blog/introducing-xen-minios-arm), he also explored how to add profiling throughout the unikernel stack.

The support is now comprehensive and integrated into the Mirage trees: the [Lwt](http://ocsigen.org/lwt) cooperative threading engine has hooks for thread switching, most of the core libraries register named events, traces are dumped into shared memory buffers in the [CTF](http://wiki.eclipse.org/Linux_Tools_Project/TMF/CTF_guide) file format used by the Linux trace toolkit, and there are JavaScript and GTK+ [GUI frontends](https://github.com/talex5/mirage-trace-viewer) that can parse them.

You can find the latest instructions on [Tracing and Profiling](http://openmirage.org/wiki/profiling) on this website, and here are Thomas' original blog posts on the subject:

- [Optimising the Unikernel](http://roscidus.com/blog/blog/2014/08/15/optimising-the-unikernel/)
- [Visualising an Asynchronous Monad](http://roscidus.com/blog/blog/2014/10/27/visualising-an-asynchronous-monad/)

### Irmin

[Thomas Gazagnaire](https://gazagnaire.org) spent most of the year furiously hacking away at the storage layer in Irmin, which is a clean-slate storage stack that uses a Git-like branching model as the basis for distributed unikernel storage.  [Irmin 0.9.0](https://github.com/mirage/irmin/releases/tag/0.9.0) was released in December with efficiency improvements and a sufficiently portable set of dependencies to make JavaScript compilation practical.

  - *"[Introducing Irmin: Git-like distributed, branchable storage](http://openmirage.org/blog/introducing-irmin)"*  describes the concepts and high-level architecture of the system.
  - *"[Using Irmin to add fault-tolerance to the Xenstore database](http://openmirage.org/blog/introducing-irmin-in-xenstore)"* shows how Irmin is used in a real-world application: the security-critical Xen toolstack that manages hosts full of virtual machines ([video](https://www.youtube.com/watch?v=DSzvFwIVm5s)).
  - There have been several other early adopters of Irmin for their own projects (independent of Mirage).  One of the most exciting is by [Gregory Tsipenyuk](https://github.com/gregatcam), who has been developing a version-controlled [Irmin-based IMAP server](https://github.com/gregtatcam/imaplet-lwt) that offers a very different model for e-mail management.  Expect to see more of this in the new year!

We also had the pleasure of Benjamin Farinier and Matthieu Journault join us as summer interns.  Both of them did a great job improving the internals of Irmin, and Benjamin's work on *[Mergeable Persistent Datastructures](http://gazagnaire.org/pub/FGM15.pdf)* will be presented at JFLA 2015.

### Jitsu

<a href="http://decks.openmirage.org/irill14-seminar#/"><img src="/graphics/decks-on-arm.png" style="float:right; padding: 5px" width="250px" /></a>

[Magnus Skjegstad](http://www.skjegstad.com/) returned to Cambridge and got interested in the rapid dynamic provisioning of unikernels.  He built [Jitsu](https://github.com/MagnusS/jitsu), a DNS server that spawns unikernels in response to DNS requests and boots them in real-time with no perceptible lag to the end user.  The longer term goal behind this is to enable a community cloud of ARM-based [Cubieboard2](http://cubieboard.org/) boards that serve user content without requiring centralised data centers, but with the ease-of-use of existing systems.

Building Jitsu and hitting our goal of extremely low latency management of unikernels required a huge amount of effort from across the Mirage team.

- [Dave Scott](http://dave.recoil.org) and [Jon Ludlam](http://jon.recoil.org) (two of the Xen maintainers at Citrix) improved the Xen `xl` toolstack to deserialise the VM startup chain to shave 100s of milliseconds off every operation.
- [Thomas Leonard](http://roscidus.com/blog/) drove the removal of our forked [Xen MiniOS](http://wiki.xen.org/wiki/Mini-OS) with a library version that is being fed upstream (including ARM support).  This made the delta between Xen and Mirage much smaller and therefore made reducing end-to-end latency tractable.
- [David Sheets](https://github.com/dsheets) built a test harness to boot unikernel services and measure their latency under very different conditions, including contrasting boot timer versus [Docker](http://docker.com) containers.  In many instances, we ended up booting faster than containers due to not touching disk at all with a standalone unikernel.  [Ian Leslie](http://www.cl.cam.ac.uk/~iml1/) built us some custom power measurement hardware that came in handy to figure out how to drive down the energy cost of unikernels running on ARM boards.
- [Thomas Gazagnaire](http://gazagnaire.org), Balraj Singh, Magnus Skjegstad built the `synjitsu` proxy server that intercepts and proxies TCP connections to mask the couple of 100 milliseconds during unikernel boot time, ensuring that no TCP connections ever require retransmission from the client.
- [Dave Scott](http://dave.recoil.org) and I built out the [vchan](https://github.com/mirage/) shared memory transport that supports low-latency communiction between unikernels and/or Unix processes.  This is rapidly heading into a Plan9-like model, with the additional twist of using Git instead of a flat filesystem hierarchy as its coordination basis.
- [Amir Chaudhry](http://amirchaudhry.com/) and [Richard Mortier](http://mort.io) documented the Git-based (and eventually Irmin-based) workflow behind managing the unikernels themselves, so that they can easily be deployed to distance ARM devices simply by running `git pull`.  You can read more about this in his [From Jekyll to Unikernels](http://amirchaudhry.com/from-jekyll-to-unikernel-in-fifty-lines/) post.

All of this work was hastily crammed into a [USENIX NSDI 2015](https://www.usenix.org/conference/nsdi15/call-for-papers) paper that got submitted at 4am on a bright autumn morning.  We'll put the preprint available when it's ready in January, along with a blog post describing how you can deploy this infrastructure for yourself.

### Community

All of the above work was only possible due to the vastly improved tooling and infrastructure around the project.  Our community manager Amir Chaudhry led the [minuted](http://openmirage.org/docs/) calls every two weeks that tied the efforts together, and we established some [pioneer projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects) for newcomers to tackle.

<img src="/graphics/opam-packages-20141231.png" style="float:right; padding: 5px" width="250px" />

The [OPAM](https://opam.ocaml.org) package manager continued to be the frontend for all Mirage tools, with releases of libraries happening [regularly](http://openmirage.org/releases).  Because of the modular nature of Mirage code, most of the libraries can also be used as normal Unix-based libraries, meaning that we aren't just limited to Mirage users but can benefit from the entire OCaml community.  The graph to the right shows the growth of the total package database since the project started to give you a sense of how much activity there is.

The major [OPAM 1.2](http://opam.ocaml.org/blog/opam-1-2-0-release/) also added a number of new features that made Mirage code easier to develop, including a [Git-based library pinning workflow](http://opam.ocaml.org/blog/opam-1-2-pin/) that works superbly with GitHub, and [easier Travis integration](http://opam.ocaml.org/blog/opam-1-2-travisci/) for continuous integration.  [Nik Sultana](https://github.com/niksu) also improved the [is-mirage-broken](https://github.com/mirage/is-mirage-broken/tree/master/logs) to give us a cron-driven prod if a library update caused an end-to-end failure in building the Mirage website or other self-hosted infrastructure.

Our favourite [random idiot](http://www.somerandomidiot.com), Mindy Preston, wrote up a superb blog series about her experiences in the spring of 2014 with moving her homepage to be hosted on Mirage.  This was followed up by [Thomas Leonard](http://roscidus.com/blog/blog/2014/07/28/my-first-unikernel/), [Phil Tomson](http://philtomson.github.io/blog/2014/09/10/some-notes-on-building-and-running-mirage-unikernels-on-cubieboard2/), [Ian Wilkinson](https://github.com/iw/mirage-jekyll), [Toby Moore](http://ocaml.is-awesome.net/2014/11/building-a-blog-with-mirage-os), and many others that we've tried to record in our [link log](http://openmirage.org/links/).  We really appreciate the hundreds of bug reports filed by users and folk trying out Mirage; by taking the trouble to do this, you've  helped us refine and polish the frontend.  One challenge for 2015 that we could use help on is to pull together many of these distributed blogged instructions and merge them back into the main documentation (get in touch if interested!).  

OCaml has come a long way in the last year in terms of tooling, and another task my research group [OCaml Labs](http://ocaml.io) works on at Cambridge is the development of the [OCaml Platform](https://ocaml.org/meetings/ocaml/2014/ocaml2014_7.pdf).  I'll be blogging separately about our OCaml-specific activities in a few days, but all of this work has a direct impact on Mirage itself since it lets us establish a local feedback loop between Mirage and OCaml developers to rapidly iterate on large-scale development.  The regular [OCaml compiler hacking sessions](http://ocamllabs.github.io/compiler-hacking/) organised by Jeremy Yallop and Leo White have been a great success this year, with a wide variety of people from academic (Cambridge, London universities and Microsoft Research) and industrial (Jane Street, Citrix and Facebook among others) and locally interested folk.
One very important project that has had a lot of work put into it in 2014 (but isn't quite ready for a public release yet) is [Assemblage](https://github.com/samoht/assemblage), which will remove much of the boilerplate currently needed to build and release an OCaml library to OPAM.

We also had a great time working with open-source summer programs. Thanks to the Xen Foundation and GNOME for their support here, and we hope to do this again next summer!  The roundup posts were:

* *[OPW FIN](http://www.somerandomidiot.com/blog/2014/08/22/opw-fin/)* by Mindy Preston: on of her [FOSS Outreach Program](http://gnome.org/opw/) work.
* *[Amazon Adventures](http://1000hippos.wordpress.com/)* by Jyotsna Prakash: on her [Google Summer of Code](https://developers.google.com/open-source/soc/?csw=1) 2014 efforts on EC2 bindings.

### Upcoming features

So what's coming up for our unikernels in 2015?  Our focus heading into the new year is very much on improving the ease-of-use and deployability of Mirage and fleshing out the feature set for the early adopters such as the [XAPI](https://github.com/xapi-project) project, [Galois](http://events.linuxfoundation.org/sites/events/files/slides/XenStore_MAC_XenSummit_2014.pdf), and the [Nymote](http://nymote.org) personal data project.  Here are some of the highlights:

- **Dust Clouds**: The work on Jitsu is leading to the construction of what we term "[dust clouds](http://anil.recoil.org/papers/2010-iswp-dustclouds.pdf)": on-demand scaling of unikernel services within milliseconds of requests coming in, terminated right beside the user on local ARM devices.  The model supports existing clouds as well, and so we are improving support for cloud APIs such via Jyotsna Prakash's [EC2](https://github.com/moonlightdrive/ocaml-ec2) bindings, [XenAPI](https://github.com/djs55/xe-unikernel-upload), and (volunteers needed) OpenStack support.  If you're interested in tracking this work, head over to the [Nymote](http://nymote.org) site for updates.

- **Portability**: Beyond Xen, there are several efforts afoot to port Mirage to bare metal targets.  One promising effort is to use [Rump Kernels](http://rumpkernel.org) as the boot infrastructure and Mirage as the application stack.  We hope to have a Raspberry Pi and other ARM targets fairly soon.  Meanwhile at the end of the spectrum is mobile computing, which was part of the original [multiscale](http://anil.recoil.org/papers/2010-bcs-visions.pdf) vision for starting the project.  The JavaScript, iOS and Android ports are all progressing (mainly thanks to community contributions around OCaml support for this space, such as Jeff Psellos' hard work on [OCaml-IOS](http://psellos.com/ocaml/)).

- **Protocol Development**: There are a huge number of protocols being developed independently, and more are always welcome.  [Luke Dunstan](https://github.com/infidel) is hacking on [multicast DNS](https://github.com/mirage/ocaml-dns/pull/35#discussion_r22388447) support, we have an IMAP [client](https://github.com/nojb/ocaml-imap) and [server](https://github.com/gregtatcam/imaplet-lwt/), [Dominic Price](https://github.com/dominicjprice) has built a series of social network APIs for [Facebook](https://github.com/dominicjprice/sociaml-facebook-api) or [Tumblr](https://github.com/dominicjprice/sociaml-tumblr-api), and [Masoud Koleini](http://nottingham.ac.uk/horizon/people/masoud.koleini) has been extending Haris Rotsos' work to achieve a line-rate and type-safe [OpenFlow](https://github.com/mirage/ocaml-openflow) switch and controller based on the [Frenetic](https://github.com/frenetic-lang) project.  Hannes is also developing [Jackline](https://github.com/hannesm/jackline), which uses his Mirage to assemble a trustworthy communication client.  [Daniel Buenzli](http://erratique.ch/software) also continues to release a growing set of high-quality, modular libraries that we depend on throughout Mirage.

- **Storage**: All storage services from the unikernels will be Git-based (e.g. logging, command-and-control, key-value retrieval).  Expect to see Xen toolstack extensions that make this support seamless, so a single Linux VM will be able to control a large army of unikernels via persistent data structures.

### Want to get involved?

This is a really fun time to get involved with unikernels and the Mirage project. The year of 2014 has seen [lots of discussion](http://openmirage.org/links/) about the potential of unikernels and we'll see some of the first big deployments involving them in 2015.  For the ones among you who wish to learn more, then check out the [pioneer projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects), watch out for [Amir's meeting notes](http://openmirage.org/wiki) and join the voice calls if you want a more interactive discussion, and engage on the [mailing lists](http://openmirage.org/community/) with any questions you might have.

For me personally, it's been a real privilege to spend the year working with and learning from the friendly, intelligent and diverse community that is springing up around the project.  The progression from experiment to reality has been a lot of work, but the unikernel dream is finally coming together rath[er nicely thanks to everyone's hard work and enthusiasm.  I'd also like to thank all of our [funding bodies](http://openmirage.org/community/) and the [Linux Foundation](http://linuxfoundation.org) and the [Xen Project](http://xenproject.org) (especially Lars Kurth and Russell Pavlicek) for their support throughout the year that made all this work possible.  Happy new year, everyone!

