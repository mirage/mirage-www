## MirageOS Hackathon in Cambridge

Our first Cambridge-based MirageOS hackathon took place yesterday - and what a fantastic day it was! The torrential rain may have halted our punting plans, but it didn't stop progress in the Old Library! Darwin College was a fantastic venue, complete with private islands linked by picturesque wooden bridges and an unwavering wifi connection.

People naturally formed groups to work on similar projects, and we had a handful of brand new users keen to get started with OCaml and Mirage.

### Solo5/Mirage integration

Progress on Solo5 project has been steaming ahead since January, and this was the perfect opportunity to get everyone together to plan its integration with Mirage. Dan Williams from IBM Research in NY flew over to join us for the week, and Martin Lucina headed to Cambridge to prepare for the upstreaming of the recent Solo5 work. This included deciding on naming and ownership of the repositories, detailing the relationships between repositories and getting ready to publish the mirage-solo5 packages to OPAM. Mindy, our Mirage 3.0 release manager, was on hand to help plan this smoothly.

See their updates from the day on Canopy http://canopy.mirage.io/Posts/Solo5 and follow the progress of the project so far:

* Introducing Solo 5 https://mirage.io/blog/introducing-solo5
* Unikernel Monitors Paper https://www.usenix.org/system/files/conference/hotcloud16/hotcloud16_williams.pdf and slides https://www.usenix.org/sites/default/files/conference/protected-files/hotcloud16_slides_williams.pdf

### Onboarding new Mirage/OCaml users

Our tutorials and onboarding guides needed a facelift and an update, so Gemma spent the morning with some of our new users to observe their installation process and tried to pinpoint blockers and areas of misunderstanding. Providing the simple, concise instructions needed in a guide together with alternatives for every possible system and version requirement is a tricky combination to get right, but we made some changes to the installation guide https://mirage.io/wiki/install that we hope will help. The next task is to do the same for our other popular tutorials, reconfigure the layout for easy reading and centralise the information as much as possible between the OPAM, Mirage and OCaml guides. Thank you to Marwan Aljubeh for his insight into this process.

### FastCGI

Christophe Troestler is spending a month with us in Cambridge this summer, and spent the hack day working on implementing a library to allow seamless application switching from HTTP to FastCGI. Progress is exploratory at the moment, but Christophe has initiated work on a client and server for this protocol.

### Packaging

Thomas Gazagnaire was frenetically converting `functoria`, `mirage`, `mirage-types` and `mirage-console` to use `topkg`, who's feedback prompted fixes and a new release from Daniel Buenzli

* https://github.com/mirage/functoria/pull/64
* https://github.com/mirage/mirage/pull/558
* https://github.com/mirage/mirage-console/pull/41

### Cubieboards

Ian Campbell implemented a (slightly hacky) way to get Alpine Linux onto some Cubieboard2's and provided notes on his process, including how to tailor the base for KVM and Xen respectively. **** Is the gist he sent over secret? **** https://gist.github.com/ijc25/612b8b7975e9461c3584b1402df2cb34

Qi Li worked on testing and adapting `simple-nat` and `mirage-nat` to provide connectivity control for unikernels on Cubieboard.

* https://github.com/yomimono/simple-nat/tree/ethernet-level-no-irmin
* https://github.com/yomimono/mirage-nat/tree/depopt_irmin

### Mirage 3.0 API changes

Our Mirage release manager, Mindy was on hand to talk with everyone about their PRs in preparation for the 3.0 release along with some patches for deprecating out of date code.

### Error logging

Thomas Leonard continued with the work he started in Marrakech by updating the error reporting patches https://github.com/mirage/functoria/pull/55 and https://github.com/mirage/mirage-dev/pull/107 to work with the latest version of Mirage (which has a different logging system). See the original post for more details http://canopy.mirage.io/Posts/Errors.

### Ctypes 0.7.0 release

Jeremy released Ctypes 0.7.0 which, along with bug fixes, adds the following features:

* Support for bytecode-only architectures https://github.com/ocamllabs/ocaml-ctypes/issues/410
* A new sint type corresponding to a full-range C integer and updated errno support for its use https://github.com/ocamllabs/ocaml-ctypes/issues/411

See the full changelog here: https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md

### P2P key-value store over DataKit

KC Sivaramakrishnan and Philip Dexter focussed on building a distributed key value store on top of DataKit https://github.com/docker/datakit. Their detailed notes are below:

Data Model
----------
Key -> File
Value -> Json

The value is possibly JSON automatically generated for OCaml type definitions using ppx_deriving_yojson library. Merge function must be explicitly specified:

```val merge : coancestor:Yojson.Safe.json
         -> theirs:Yojson.Safe.json
         -> mine:Yojson.Safe.json
         -> Yojson.Safe.json
```

Merge must always be defined, and any error state explicitly encoded in the resultant type to be handled by the application.

Network model
-------------
The current design is that each peer will run a datakit 9p server, which exposes a 9p fs interface. Each peer also mounts its own datakit 9p volume and also the ​*desired set*​ of peer’s 9p volumes. This allows the programmer to describe the network explicitly.

Peer info stored in a separate branch. Questions: Can peer info also be managed the same way as usual kv info? Would the peers watch for updates to the peer info table and reorganise the n/w dynamically?

Execution model
---------------
The peers can update their local snapshot of kv store, explicitly fetch changes from peers (which fetches updates in the mounted 9p volume and merges using the user-defined merge function), or watch a subset of peers & keys for updates (and automatic merges).

Status
------
* Modelling the network by hand. WIP dockerfile: https://github.com/philipdexter/datakit-ssh
* Filed a bunch of issues:
 + size: https://github.com/docker/datakit/issues/183
 + fetch: https://github.com/docker/datakit/issues/180
 + watching: https://github.com/docker/datakit/issues/178

### Developer experience improvements

Our UROP undergraduate interns are spending their summers working on user improvements and CI logs with MirageOS, and used the time at the hackathon to focus on these issues.

Ciaran is working on an editor implementation, specifically getting the IOcaml kernel working with the Hydrogen plugin for Atom - this will allow developers to run OCaml code directly in Atom.

Joel used Angstrom (a fast parser combinator library developed by Spiros Eliopoulos) https://github.com/inhabitedtype/angstrom to convert the ANSI escape codes, usually displayed as colours and styles into HTML for use in viewing CI logs.

### Windows Support

Most of the Mirage libraries already work on Windows thanks to lots of work in the wider OCaml community, but other features don't have full support yet

Dave Scott worked on [ocaml-wpcap](https://github.com/djs55/ocaml-wpcap): a [ctypes](https://github.com/ocamllabs/ocaml-ctypes) binding to the Windows [winpcap.dll](http://www.winpcap.org) which lets OCaml programs send and receive ethernet frames on Windows. The ocaml-wpcap library will hopefully let us run the Mirage TCP/IP stack and all the networking applications too.

David Allsopp continued his OPAM-Windows support by fine-tuning the 80 native Windows OCaml versions - these will hopefully form part of OPAM 2.0. As it turns out, he's not the only person still interested in being able to run OCaml 3.07...

----

Not sure where these go....

Olivier is working on the macros project at OCL, and started working on the HTML and XML templates using this system. The objective is to have the same behaviour as the `Pa_tyxml` syntax extension, but in a type-safe and more maintainable way. This project could contribute to the development of Ocsigen once implemented.

Nick Betteridge is looking at using ocaml-btree as a backend for irmin/xen and spent the day looking at different approaches such as the key/value.
