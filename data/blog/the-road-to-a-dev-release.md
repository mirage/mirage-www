---
updated: 2013-05-20
authors:
- name: Anil Madhavapeddy
  uri: http://anil.recoil.org
  email: anil@recoil.org
subject: The road to a developer preview at OSCON 2013
permalink: the-road-to-a-dev-release
---

There's been a crazy stream of activity since the start of the year, but the most important news is that we have a release target for an integrated developer preview of the Mirage stack: a talk at [O'Reilly OSCon](http://www.oscon.com/oscon2013/public/schedule/detail/28956) in July!  Do turn up there and find [Dave Scott](http://dave.recoil.org) and [Anil Madhavapeddy](http://anil.recoil.org) showing off interactive demonstrations.

Meanwhile, another significant announcement has been that Xen is [joining the Linux Foundation](http://www.linuxfoundation.org/news-media/announcements/2013/04/xen-become-linux-foundation-collaborative-project) as a collaborative project.  This is great news for Mirage: as a library operating system, we can operate just as easily under other hypervisors, and even on bare-metal devices such as the [Raspberry Pi](http://raspberrypi.org).  We're very much looking forward to getting the Xen-based developer release done, and interacting with the wider Linux community (and FreeBSD, for that matter, thanks to Gabor Pali's [kFreeBSD](https://github.com/pgj/mirage-kfreebsd) backend).

Here's some other significant news from the past few months:

* [OPAM 1.0 was released](http://www.ocamlpro.com/blog/2013/03/14/opam-1.0.0.html), giving Mirage a solid package manager for handling the many libraries required to glue an application together.  [Vincent Bernardoff](https://github.com/vbmithr) joined the team at Citrix and has been building a Mirage build-frontend called [Mirari](https://github.com/mirage/mirari) to hide much of the system complexity from a user who isn't too familiar with either Xen or OCaml.

* A new group called the [OCaml Labs](http://ocaml.io) has started up in the [Cambridge Computer Laboratory](http://www.cl.cam.ac.uk), and is working on improving the OCaml toolchain and platform.  This gives Mirage a big boost, as we can re-use several of the documentation, build and test improvements in our own releases.  You can read up on the group's activities via the [monthly updates](http://ocaml.io/news), or browse through the various [projects](http://ocaml.io/tasks).  One of the more important projects is the [OCamlot](http://www.cl.cam.ac.uk/projects/ocamllabs/tasks/platform.html#OCamlot) continuous build infrastructure, which will also be testing Mirage kernels as one of the supported backends.

* As we head into release mode, we've started [weekly meetings](/wiki#Weekly-calls-and-release-notes) to coordinate all the activities.  We're keeping notes as we go along, so you should be able to skim the notes and [mailing list archives](https://lists.cam.ac.uk/pipermail/cl-mirage/) to get a feel for the overall activities.  Anil is maintaining a [release checklist](https://mirage.github.io/wiki/dev-preview-checklist) for the summer developer preview.

* Anil (along with Yaron Minsky and Jason Hickey) is finishing up an O'Reilly book on [Real World OCaml](http://realworldocaml.org), which will be a useful guide to using OCaml for systems and network programming. If you'd like to review an early copy, please get in touch.  The final book is anticipated to be released towards the end of the year, with a [Rough Cut](http://shop.oreilly.com/category/roughcuts.do) at the end of the summer.

* The core system was described in an [ASPLOS 2013](http://anil.recoil.org/papers/2013-asplos-mirage.pdf) paper, which should help you understand the background behind library operating systems. Some of the Mirage libraries are also currently being integrated into the next-generation [Windsor](http://blogs.citrix.com/2012/05/17/introducing-windsor-a-new-xen-based-virtualization-architecture/) release of the Xen Cloud Platform, which means that several of the libraries will be used in production and hence move beyond research-quality code.

In the next few months, the installation notes and getting started guides will
all be revamped to match the reality of the new tooling, so expect some flux
there.   If you want to take an early try of Mirage beforehand, don't forget to
hop on the `#mirage` IRC channel on Freenode and ping us with questions
directly.  We will also be migrating some of the project infrastructure to be fully
self-hosted on Mirage and Xen, and placing some of the services onto the new [xenproject.org](http://xenproject.org) infrastructure. 

