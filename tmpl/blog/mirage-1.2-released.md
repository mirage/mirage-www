Summer is in full swing here in Mirage HQ with torrential rainstorms, searing
sunshine, and our [OSCON 2014](http://www.oscon.com/oscon2014/public/schedule/detail/35024) talk
rapidly approaching in just a few weeks.  We've been steadily releasing point releases
since the [first release](/blog/mirage-1.1-released) back in December, and today's [Mirage
1.2.0](https://github.com/mirage/mirage/releases/tag/v1.2.0) is the last of the `1.x` series.
The main improvements are usability-oriented:

* The Mirage frontend tool now generates a `Makefile` with a `make depend`
  target, instead of directly invoking OPAM as part of `mirage configure`.
  This greatly improves usability on slow platforms such as ARM, since the
  output of OPAM as it builds can be inspected more easily. Users will now
  need to run `make depend` to ensure they have the latest package set
  before building their unikernel.

* Improve formatting of the `mirage` output, including pretty colours!
  This makes it easier to distinguish complex unikernel configurations
  that have lots of deployment options.  The generated files are built
  more verbosely by default to facilitate debugging, and with debug
  symbols and backtraces enabled by default.

* Added several [device module types](https://github.com/mirage/mirage/tree/master/types), including `ENTROPY` for random
  noise, `FLOW` for stream-oriented connections, and exposed the `IPV4`
  device in the `STACKV4` TCP/IP stack type.

* Significant bugfixes in supporting libraries such as the TCP/IP
  stack (primarily thanks to [Mindy Preston](http://www.somerandomidiot.com/) fuzz testing
  and finding some good [zingers](https://github.com/mirage/mirage-tcpip/issues/56)).  There are too many
  library releases to list individually here, but you can [browse the changelog](/releases) for more details.

#### Towards Mirage OS 2.0

We've also been working hard on the **Mirage OS 2.x series**, which introduces
a number of new features and usability improvements that emerged from actually
using the tools in practical projects.  Since there have been so many [new
contributors](/blog/welcome-to-our-summer-hackers) recently,
[Amir Chaudhry](http://amirchaudhry.com) is coordinating a [series of blog
posts](https://github.com/mirage/mirage/issues/257) in the runup to
[OSCON](http://www.oscon.com/oscon2014/public/schedule/detail/35024) that
explains the new work in depth.  Once the release rush has subsided, we'll
be working on integrating these posts into our [documentation](/docs)
properly.

The new 2.0 features include the [Irmin](https://github.com/mirage/irmin) branch-consistent distributed storage
library, the pure OCaml [TLS stack](https://github.com/mirleft/), [Xen/ARM support](https://github.com/mirage/mirage-platform/pull/93) and the Conduit I/O
subsystem for [mapping names to connections](http://anil.recoil.org/papers/2012-resolve-fable.pdf).  Also included in the blog series
are some sample usecases on how these tie together for real applications (as a
teaser, here's a video of [Xen VMs booting using
Irmin](https://www.youtube.com/watch?v=DSzvFwIVm5s) thanks to [Dave
Scott](http://dave.recoil.org) and [Thomas Gazagnaire](http://gazagnaire.org)!)

#### Upcoming talks and tutorials

[Richard Mortier](http://mort.io) and myself will be galavanting around the world
to deliver a few talks this summer: 

* The week of [OSCON](http://www.oscon.com/oscon2014) on July 20th-24th.  Please get in touch via the conference website or a direct e-mail, or [attend our talk](http://www.oscon.com/oscon2014/public/schedule/detail/35024) on Thursday morning.
There's a [Real World OCaml](https://realworldocaml.org) book signing on Tuesday morning for the super keen as well.
* The [ECOOP summer school](http://ecoop14.it.uu.se/programme/ecoop-school.php) in beautiful Uppsala in Sweden on Weds 30th July. 
* I'll be presenting the Irmin and Xen integration at [Xen Project Developer Summit](http://events.linuxfoundation.org/events/xen-project-developer-summit) in
  Chicago on Aug 18th (as part of LinuxCon North America).

As always, if there are any particular topics you would like to see more
on, then please comment on the [tracking issue](https://github.com/mirage/mirage/issues/257)
or [get in touch directly](/community).  There will be a lot of releases coming out
in the next few weeks (including a beta of the new version of [OPAM](http://opam.ocaml.org),
so [bug reports](https://github.com/mirage/mirage/issues) are very much appreciated for those
things that slip past [Travis CI](http://travis-ci.org)!


