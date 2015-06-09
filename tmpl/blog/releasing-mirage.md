
*First*: read the [overview](/wiki/overview-of-mirage) and
[technical background](/wiki/technical-background) behind the project.

When we started hacking on MirageOS back in 2009, it started off looking like a
conventional OS, except written in OCaml.   The [monolithic
repository](https://github.com/mirage/mirage/tree/old-master) contained all the
libraries and boot code, and exposed a big `OS` module for applications to use.
We used this to do several fun [tutorials](http://cufp.org/conference/sessions/2011/t3-building-functional-os) at conferences
such as ICFP/CUFP and get early feedback.

As development continued though, we started to understand what it is we were
building: a ["library operating system"](http://anil.recoil.org/papers/2013-asplos-mirage.pdf).  As the number of libraries grew,
putting everything into one repository just wasn't scaling, and it made it hard
to work with third-party code.  We spent some time developing tools to make
Mirage fit into the broader OCaml ecosystem.

Three key things have emerged from this effort:

* [OPAM](https://opam.ocaml.org), a source-based package manager for
  OCaml. It supports multiple simultaneous compiler installations, flexible
  package constraints, and a Git-friendly development workflow.  Since
  releasing 1.0 in March 2013 and 1.1 in October, the community has leapt
  in to contribute over 1800 packages in this short time.  All of the 
  Mirage libraries are now tracked using it, including the Xen libraries.
* The build system for embedded programming (such as the Xen target) is
  a difficult one to get right.  After several experiments, Mirage provides
  a single **[command-line tool](https://github.com/mirage/mirage)** that
  combines configuration directives (also written in OCaml) with OPAM to
  make building Xen unikernels as easy as Unix binaries.
* All of the Mirage-compatible libraries satisfy a set of module type
  signatures in a **[single file](https://github.com/mirage/mirage-types/blob/master/lib/v1.mli)**.
  This is where Mirage lives up to its name: we've gone from the early
  monolithic repository to a single, standalone interface file that
  describes the interfaces.  Of course, we also have libraries to go along
  with this signature, and they all live in the [MirageOS GitHub organization](https://github.com/mirage).

With these components, I'm excited to announce that MirageOS 1.0 is finally ready
to see the light of day!  Since it consists of so many libraries, we've decided
not to have a "big bang" release where we dump fifty complex libraries on the
open-source community.  Instead, we're going to spend the month of December
writing a series of blog posts that explain how the core components work,
leading up to several use cases:

* The development team have all decided to shift our personal homepages to be Mirage
  kernels running on Xen as a little Christmas present to ourselves, so we'll work through that step-by-step how to build 
  a dedicated unikernel and maintain and deploy it (**spoiler:** see [this repo](https://github.com/mirage/mirage-www-deployment)).  This will culminate in
  a webservice that our colleagues at [Horizon](http://horizon.ac.uk) have been
  building using Android apps and an HTTP backend.
* The [XenServer](http://xenserver.org) crew at Citrix are using Mirage to build custom middlebox VMs
  such as block device caches.
* For teaching purposes, the [Cambridge Computer Lab team](http://ocaml.io) want a JavaScript backend,
  so we'll explain how to port Mirage to this target (which is rather different
  from either Unix or Xen, and serves to illustrate the portability of our approach).

### How to get involved

Bear with us while we update all the documentation and start the blog posts off
today (the final libraries for the 1.0 release are all being merged into OPAM
while I write this, and the usually excellent [Travis](http://travis-ci.org) continuous integration system is down due to a [bug](https://github.com/travis-ci/travis-ci/issues/1727) on their side).  I'll edit this post to contain links to the future posts
as they happen.

Since we're now also a proud Xen and Linux Foundation incubator project, our mailing
list is shifting to [mirageos-devel@lists.xenproject.org](http://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel), and we very much
welcome comments and feedback on our efforts over there.
The `#mirage` channel on FreeNode IRC is also growing increasingly popular, as
is simply reporting issues on the main [Mirage GitHub](http://github.com/mirage/mirage) repository.

Several people have also commented that they want to learn OCaml properly to
start using Mirage.  I've just co-published an O'Reilly book called
[Real World OCaml](https://realworldocaml.org) that's available for free online
and also as hardcopy/ebook.  Our Cambridge colleague John Whittington has
also written an excellent [introductory text](http://ocaml-book.com/), and
you can generally find more resources [online](http://ocaml.org/docs/).
Feel free to ask beginner OCaml questions on our mailing lists and we'll help
as best we can!
