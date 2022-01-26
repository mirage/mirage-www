---
updated: 2014-02-11 16:00
authors:
- name: Anil Madhavapeddy
  uri: http://anil.recoil.org
  email: anil@recoil.org
subject: 'MirageOS 1.1.0: the eat-your-own-dogfood release'
permalink: mirage-1.1-released
---

We've just released [MirageOS 1.1.0](https://github.com/ocaml/opam-repository/pull/1655) into OPAM.  Once the
live site updates, you should be able to run `opam update -u` and get the latest
version.  This release is the "[eat our own
dogfood](http://en.wikipedia.org/wiki/Eating_your_own_dog_food)" release; as I
mentioned earlier in January, a number of the MirageOS developers have decided to
shift our own personal homepages onto MirageOS.  There's nothing better than
using our own tools to find all the little annoyances and shortcomings, and so
MirageOS 1.1.0 contains some significant usability and structural improvements
for building unikernels.

#### Functional combinators to build device drivers

MirageOS separates the
application logic from the concrete backend in use by writing the application
as an [OCaml functor](https://realworldocaml.org/v1/en/html/functors.html)
that is parameterized over module types that represent the device driver
signature.  All of the module types used in MirageOS can be browsed in [one
source file](https://github.com/mirage/mirage/blob/1.1.0/types/V1.mli).

In MirageOS 1.1.0, [Thomas Gazagnaire](http://gazagnaire.org/) implemented a
a [combinator library](https://github.com/mirage/mirage/blob/1.1.0/lib/mirage.mli#L28)
that makes it easy to separate the definition of application logic from the details
of the device drivers that actually execute the code (be it a Unix binary or a
dedicated Xen kernel).  It lets us write code of this form
(taken from [mirage-skeleton/block](https://github.com/mirage/mirage-skeleton/tree/master/block)):

```
let () =
  let main = foreign "Unikernel.Block_test" (console @-> block @-> job) in
  let img = block_of_file "disk.img" in
  register "block_test" [main $ default_console $ img]
```

In this configuration fragment, our unikernel is defined as a functor over a
console and a block device by using `console @-> block @-> job`.  We then
define a concrete version of this job by applying the functor (using the `$`
combinator) to a default console and a file-backed disk image.

The combinator approach lets us express complex assemblies of device driver
graphs by writing normal OCaml code, and the `mirage` command line tool
parses this at build-time and generates a `main.ml` file that has all the
functors applied to the right device drivers. Any mismatches in module signatures
will result in a build error, thus helping to spot nonsensical combinations
(such as using a Unix network socket in a Xen unikernel).

This new feature is walked through in the [tutorial](/docs/hello-world), which
now walks you through several skeleton examples to explain all the different
deployment scenarios.  It's also followed by the [website tutorial](/docs/mirage-www)
that explains how this website works, and how our [Travis autodeployment](/docs/deploying-via-ci)
throws the result onto the public Internet.

Who will win the race to get our website up and running first?  Sadly for Anil,
[Mort](http://www.cs.nott.ac.uk/~rmm/) is currently [in the
lead](https://github.com/mor1/mort-www) with an all-singing, all-dancing shiny
new website.  Will he finish in the lead though? Stay tuned!

#### Less magic in the build

Something that's more behind-the-scenes, but important for easier development,
is a simplication in how we build libraries.  In MirageOS 1.0, we had several
packages that couldn't be simultaneously installed, as they had to be compiled 
in just the right order to ensure dependencies.

With MirageOS 1.1.0, this is all a thing of the past.  All the libraries can
be installed fully in parallel, including the network stack.  The 1.1.0
[TCP/IP stack](https://github.com/mirage/mirage-tcpip) is now built in the
style of the venerable [FoxNet](http://www.cs.cmu.edu/~fox/foxnet.html) network
stack, and is parameterized across its network dependencies.  This means
that once can quickly assemble a custom network stack from modular components,
such as this little fragment below from [mirage-skeleton/ethifv4/](https://github.com/mirage/mirage-skeleton/blob/master/ethifv4/unikernel.ml):

```
module Main (C: CONSOLE) (N: NETWORK) = struct

  module E = Ethif.Make(N)
  module I = Ipv4.Make(E)
  module U = Udpv4.Make(I)
  module T = Tcpv4.Flow.Make(I)(OS.Time)(Clock)(Random)
  module D = Dhcp_clientv4.Make(C)(OS.Time)(Random)(E)(I)(U)
  
```

This functor stack starts with a `NETWORK` (i.e. Ethernet) device, and then applies
functors until it ends up with a UDPv4, TCPv4 and DHCPv4 client.  See the [full
file](https://github.com/mirage/mirage-skeleton/blob/master/ethifv4/unikernel.ml)
to see how the rest of the logic works, but this serves to illustrate how
MirageOS makes it possible to build custom network stacks out of modular
components.  The functors also make it easier to embed the network stack in
non-MirageOS applications, and the `tcpip` OPAM package installs pre-applied Unix
versions for your toplevel convenience.

To show just how powerful the functor approach is, the same stack can also
be mapped onto a version that uses kernel sockets simply by abstracting the
lower-level components into an equivalent that uses the Unix kernel to provide
the same functionality.  We explain how to swap between these variants in
the [tutorials](/wiki/hello-world).

#### Lots of library releases

While doing the 1.1.0 release in January, we've also released quite a few libraries
into [OPAM](https://opam.ocaml.org).  Here are some of the highlights.

Low-level libraries:

* [mstruct](https://github.com/samoht/ocaml-mstruct/) is a streaming layer for handling lists of memory buffers with a simpler read/write interface.
* [nbd](https://github.com/xapi-project/nbd/) is an implementation of the [Network Block Device](http://en.wikipedia.org/wiki/Network_block_device) protocol for block drivers.

Networking and web libraries:

* [ipaddr](https://github.com/mirage/ocaml-ipaddr) now has IPv6 parsing support thanks to [Hugo Heuzard](https://github.com/hhugo/) and David Sheets.  This is probably the hardest bit of adding IPv6 support to our network stack!
* [cowabloga](https://github.com/mirage/cowabloga) is slowly emerging as a library to handle the details of rendering Zurb Foundation websites.  It's still in active development, but being used for a few of our [personal websites](https://github.com/mor1/mort-www) as well as this website.
* [cohttp](https://github.com/avsm/ocaml-cohttp) has had several releases thanks to external contributions, particular from [Rudy Grinberg](https://github.com/rgrinberg) who added s-expression support and several [other improvements](https://github.com/avsm/ocaml-cohttp/blob/master/CHANGES).
* [uri](https://github.com/avsm/ocaml-uri) features performance improvements and the elimination of Scanf (considered [rather slow](http://www.lexifi.com/blog/note-about-performance-printf-and-format) by OCaml standards).
* [cow](https://github.com/mirage/ocaml-cow) continues its impossible push to make coding HTML and CSS a pleasant experience, with better support for Markdown now.
* The [github](https://github.com/avsm/ocaml-github) bindings are now also in use as part of an experiment to make [upstream OCaml development](http://gallium.inria.fr/blog/patch-review-on-github/) easier for newcomers, thanks to Gabriel Scherer.

[Dave Scott](http://dave.recoil.org) led the splitting up of several low-level Xen libraries as part of the build simplication.  These now compile on both Xen (using the direct hypercall interface) and Unix (using the dom0 `/dev` devices) where possible.
* [xen-evtchn](https://github.com/xapi-project/ocaml-evtchn) for the event notification mechanism. There are a couple of wiki posts that explain how [event channels](/wiki/xen-events) and [suspend/resume](/wiki/xen-suspend) work in MirageOS/Xen guests.
* [xen-gnt](https://github.com/xapi-project/ocaml-gnt) for the grant table mechanism that controls inter-process memory.
* The [io-page](https://github.com/mirage/io-page) library no longer needs Unix and Xen variants, as the interface has been standardized to work in both.

All of Dave's hacking on Xen device drivers is showcased in this [xen-disk wiki post](https://mirage.io/wiki/xen-synthesize-virtual-disk) that 
explains how you can synthesize your own virtual disk backends using MirageOS.  Xen uses a [split device](https://www.usenix.org/legacy/event/usenix05/tech/general/full_papers/short_papers/warfield/warfield.pdf) model,
and now MirageOS lets us build *backend* device drivers that service VMs as well as the frontends!

Last, but not least, [Thomas Gazagnaire](http://gazagnaire.org) has been building a brand new storage system for MirageOS guests that uses git-style branches under the hood to help coordinate clusters of unikernels.  We'll talk about how this works in a future update, but there are some cool libraries and prototypes available on OPAM for the curious.

* [lazy-trie](https://github.com/samoht/ocaml-lazy-trie/) is a lazy version of the Trie data structure, useful for exposing Git graphs.
* [git](https://github.com/samoht/ocaml-git) is a now-fairly complete implementation of the Git protocol in pure OCaml, which can interoperate with normal Git servers via the `ogit` command-line tool that it installs.
* [irmin](https://github.com/mirage/irmin) is the main library that abstracts Git DAGs into an OCaml programming API.  The homepage has [instructions](https://github.com/mirage/irmin/wiki/Getting-Started) on how to play with the command-line frontend to experiment with the database.
* [git2fat](https://github.com/samoht/git2fat) converts a Git checkout into a FAT block image, useful when bundling up unikernels.

We'd also like to thank several conference organizers for giving us the opportunity to demonstrate MirageOS.  The talk video from [QCon SF](http://www.infoq.com/presentations/mirage-os) is now live, and we also had a *great* time at [FOSDEM](http://fosdem.org) recently (summarized by Amir [here](http://nymote.org/blog/2014/fosdem-summary/)). 
So lots of activities, and no doubt little bugs lurking in places (particularly around installation).  As always, please do let us know of any problem by [reporting bugs](https://github.com/mirage/mirage/issues), or feel free to [contact us](/community) via our e-mail lists or IRC.  Next stop: our unikernel homepages!


