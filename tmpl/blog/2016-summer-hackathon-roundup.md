<a href="https://www.flickr.com/photos/138528518@N02/sets/72157671241464475"><img src="/graphics/cambridge2016-hackathon.jpg" align="right" width="250px" /></a>
Our first Cambridge-based MirageOS hackathon took place yesterday - and what a fantastic day it was! The torrential rain may have halted our punting plans, but it didn't stop progress in the Old Library! Darwin College was a fantastic venue, complete with private islands linked by picturesque wooden bridges and an unwavering wifi connection.

People naturally formed groups to work on similar projects, and we had a handful of brand new users keen to get started with OCaml and Mirage.  The major tasks that emerged were:

- __new hypervisor target__: the integration of the Solo5 KVM-based hypervisor backend, bringing the number of officially supported targets up to 3 (Xen, Unix and KVM)
- __build system template__: establishing a new [topkg](TODO)  template for MirageOS libraries, to prepare us for building a unified API documentation bundle that works across all the entire project.
- __CPU portability__: improving ARM support via a better base OS image.
- __libraries breadth__: hacking on all the things to fill in the blanks, such as btree support for bare-metal [Irmin](https://github.com/mirage/irmin), or a peer-to-peer layer for the [DataKit](https://github.com/docker/datakit).

We'll write about all of this in more detail, but for now here are the hackathon notes hot off the press...

### Solo5/MirageOS integration (KVM-based backend)

Progress on the Solo5 project has been steaming ahead [since January](https://mirage.io/blog/introducing-solo5), and this was the perfect opportunity to get everyone together to plan its integration with MirageOS. [Dan Williams](http://researcher.ibm.com/researcher/view.php?person=us-djwillia) from IBM Research flew over to join us for the week, and [Martin Lucina](https://github.com/mato) headed to Cambridge to prepare for the upstreaming of the recent Solo5 work. This included deciding on naming and ownership of the repositories, detailing the relationships between repositories and getting ready to publish the mirage-solo5 packages to OPAM. [Mindy Preston](http://somerandomidiot.com), our MirageOS 3.0 release manager, and [Anil Madhavapeddy](http://anil.recoil.org) and [Thomas Gazagnaire](http://gazagnaire.org) (OPAM minions) were on hand to help plan this smoothly.

See their updates from the day on [Canopy](http://canopy.mirage.io/Posts/Solo5) and related blog posts:

* [Introducing Solo 5](https://mirage.io/blog/introducing-solo5)
* Unikernel Monitors HotCloud 2016 [paper](https://www.usenix.org/system/files/conference/hotcloud16/hotcloud16_williams.pdf) and [slides](https://www.usenix.org/sites/default/files/conference/protected-files/hotcloud16_slides_williams.pdf)
* [upstreaming GitHub issue](https://github.com/Solo5/solo5/issues/36) and [FreeBSD support tracking issue](https://github.com/Solo5/solo5/issues/61) from Hannes Mehnert.

### Onboarding new MirageOS/OCaml users

Our tutorials and onboarding guides _really_ needed a facelift and an update, so Gemma spent the morning with some of our new users to observe their installation process and tried to pinpoint blockers and areas of misunderstanding. Providing the simple, concise instructions needed in a guide together with alternatives for every possible system and version requirement is a tricky combination to get right, but we made some [changes](https://github.com/mirage/mirage-www/pull/468) to the [installation guide](https://mirage.io/wiki/install) that we hope will help. The next task is to do the same for our other popular tutorials, reconfigure the layout for easy reading and centralise the information as much as possible between the OPAM, MirageOS and OCaml guides. Thank you to Marwan Aljubeh for his insight into this process.

### Packaging

Thomas Gazagnaire was frenetically converting `functoria`, `mirage`, `mirage-types` and `mirage-console` to use [topkg](https://github.com/dbuenzli/topkg), and the feedback prompted fixes and a new release from Daniel Buenzli.

* [Functoria #64](https://github.com/mirage/functoria/pull/64)
* [Mirage #558](https://github.com/mirage/mirage/pull/558)
* [Mirage-console #41](https://github.com/mirage/mirage-console/pull/41)

### ARM and Cubieboards

Ian Campbell implemented a (slightly hacky) way to get Alpine Linux onto some Cubieboard2 boxes and [provided notes](https://gist.github.com/ijc25/612b8b7975e9461c3584b1402df2cb34) on his process, including how to tailor the base for KVM and Xen respectively.

Meanwhile, Qi Li worked on testing and adapting [simple-nat](https://github.com/yomimono/simple-nat) and [mirage-nat](https://github.com/yomimono/mirage-nat) to provide connectivity control for unikernels on ARM Cubieboards to act as network gateways.

* [Simple-NAT ethernet branch](https://github.com/yomimono/simple-nat/tree/ethernet-level-no-irmin)
* [Mirage NAT with optional Irmin branch](https://github.com/yomimono/mirage-nat/tree/depopt_irmin)

[Hannes Mehnert](https://www.cl.cam.ac.uk/~hm519/) recently published a purely functional [ARP package](https://github.com/hannesm/arp) and continued refining it (with code coverage via [bisect](http://bisect.x9c.fr)) during the hackathon.

### MirageOS 3.0 API changes
 
Our MirageOS release manager, Mindy Preston, was on hand to talk with everyone about their PRs in preparation for the 3.0 release along with some patches for deprecating out of date code.  There has been a lot of discussion on the [development list](https://lists.xenproject.org/archives/html/mirageos-devel/2016-07/msg00000.html).  One focus was to address time handling properly in the interfaces: Matthew Gray came up from London to finish up his extensive revision of the [CLOCK](https://github.com/mirage/mirage/issues/442) interface, and Hannes developed a new [duration](https://github.com/hannesm/duration) library to handle time unit conversions effiently and get rid of the need for floating point handling.  We are aiming to minimise the dependency on floating point handling in external interfaces to simplify compilation to very embedded hardware that only has soft floats (particularly for something as ubiquitous as time handling).

### Error logging

Thomas Leonard continued with the work he started in Marrakech by [updating the error reporting patches](https://github.com/mirage/functoria/pull/55) (also [here](https://github.com/mirage/mirage-dev/pull/107)) to work with the latest version of MirageOS (which has a different logging system based on Daniel Buenzlis [Logs](http://erratique.ch/software/logs)). See the [original post](http://canopy.mirage.io/Posts/Errors) for more details.

### Ctypes 0.7.0 release

Jeremy released the foreign function interface library [Ctypes 0.7.0](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.7.0) which, along with bug fixes, adds the following features:

* Support for bytecode-only architectures ([#410](https://github.com/ocamllabs/ocaml-ctypes/issues/410))
* A new `sint` type corresponding to a full-range C integer and updated errno support for its use ([#411](https://github.com/ocamllabs/ocaml-ctypes/issues/411))

See the full changelog [online](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md).

### P2P key-value store over DataKit

KC Sivaramakrishnan and Philip Dexter took on the challenge of grabbing the Docker [DataKit](https://github.com/docker/datakit) release and started building a distributed key-value store that features flexible JSON synching and merging.  Their raw notes are in a [Gist](https://gist.github.com/kayceesrk/d3edb2da0aa9a3d40e9e3f838b67bd1a) -- get in touch with them if you want to help hack on the sync system backed by Git.

### Developer experience improvements

The OCaml Labs undergraduate interns are spending their summers working on user improvements and CI logs with MirageOS, and used the time at the hackathon to focus on these issues.

Ciaran is working on an editor implementation, specifically getting the [IOcaml kernel](https://github.com/andrewray/iocaml) working with the [Hydrogen](https://github.com/nteract/hydrogen) plugin for the Atom editor. This will allow developers to run OCaml code directly in Atom, and eventually interactively build unikernels!

Joel used [Angstrom](https://github.com/inhabitedtype/angstrom) (a fast parser combinator library developed by Spiros Eliopoulos) to ANSI escape codes, usually displayed as colours and styles into HTML for use in viewing CI logs.

### Windows Support

Most of the Mirage libraries already work on Windows thanks to lots of work in the wider OCaml community, but other features don't have full support yet.

[Dave Scott](http://dave.recoil.org) from Docker worked on [ocaml-wpcap](https://github.com/djs55/ocaml-wpcap): a [ctypes](https://github.com/ocamllabs/ocaml-ctypes) binding to the Windows [winpcap.dll](http://www.winpcap.org) which lets OCaml programs send and receive ethernet frames on Windows. The ocaml-wpcap library will hopefully let us run the Mirage TCP/IP stack and all the networking applications too.

David Allsopp continued his OPAM-Windows support by fine-tuning the 80 native Windows OCaml versions - these will hopefully form part of OPAM 2.0. As it turns out, he's not the only person still interested in being able to run OCaml 3.07...if you are, get in touch!

### General Libraries and utilities

Olivier Nicole is working on an implementation of macros in OCaml and started working on the
HTML and XML templates using this system. The objective is to have the same
behaviour as the `Pa_tyxml` syntax extension, but in a type-safe and more
maintainable way without requiring PPX extensions. This project could be
contributed to the development of [Ocsigen](http://ocsigen.org) once implemented.

Nick Betteridge teamed up with Dave Scott to look at using
[ocaml-btree](https://github.com/djs55/ocaml-btree) as a backend for Irmin/xen
and spent the day looking at different approaches.

Anil Madhavapeddy built a Docker wrapper for the CI system and spun up a big cluster
to run OPAM bulk builds.  Several small utilities like [jsontee](https://github.com/avsm/jsontee) and
an immutable [log collection server](https://github.com/avsm/opam-log-server) and
[bulk build scripts](https://github.com/avsm/opam-bulk-builder) will be released in the
next few weeks once the builds are running stably, and be re-usable by other OPAM-based
projects to use for their own tests.

[Christophe Troestler](https://github.com/Chris00) is spending a month at
[OCaml Labs](https://ocaml.io) in Cambridge this summer, and spent the hack day
working on implementing a library to allow seamless application switching from
HTTP to FastCGI. Christophe has initiated work on a client and server for this
protocol using [CoHTTP](https://github.com/mirage/ocaml-cohttp) so that it is
unikernel-friendly.


