Now that Mirage OS is rapidly converging on a
[Developer Preview Release 1](http://github.com/avsm/mirage/issues/102), we
took it for a first public outing at
[OSCON'13](http://www.oscon.com/oscon2013/), the O'Reilly Open Source
Conference. OSCON is in its 15th year now, and is a meeting place for
developers, business people and investors. It was a great opportunity to show
MirageOS off to some of the movers and shakers in the OSS world.

Partly because MirageOS is about synthesising extremely specialised guest
kernels from high-level code, and partly because both Anil and I are
constitutionally incapable of taking the easy way out, we self-hosted the
slide deck on Mirage: after some last-minute hacking -- on content not Mirage
I should add! -- we built a self-contained unikernel of the talk.

This was what you might call a "full stack" presentation: the custom
unikernel (flawlessly!) ran a type-safe
[network device driver](https://github.com/mirage/mirage-platform/blob/master/xen/lib/netif.ml),
OCaml [TCP/IP stack](http://github.com/mirage/mirage-net) supporting an OCaml
[HTTP](http://github.com/mirage/ocaml-cohttp) framework that served slides
rendered using [reveal.js](http://lab.hakim.se/reveal-js/). The slide deck,
including the turbo-boosted
[screencast](http://www.youtube.com/watch?v=2Mx8Bd5JYyo) of the slide deck
compilation, is hosted as another MirageOS virtual machine at
[decks.openmirage.org](http://decks.openmirage.org/). We hope to add more
slide decks there soon, including resurrecting the tutorial! The source code
for all this is in the [mirage-decks](http://github.com/mirage/mirage-decks)
GitHub repo.

### The Talk

The talk went down pretty well -- given we were in a graveyard slot on Friday
after many people had left, attendance was fairly high (around 30-40), and the
[feedback scores](http://www.oscon.com/oscon2013/public/schedule/detail/28956)
have been positive (averaging 4.7/5) with comments including "excellent
content and well done" and "one of the most excited projects I heard about"
(though we are suspicious that just refers to Anil's usual high-energy
presentation style...).

<iframe align="right" style="margin-left: 10px;" width="420" height="235" src="//www.youtube-nocookie.com/embed/2Mx8Bd5JYyo" frameborder="0" allowfullscreen="1"> &nbsp; </iframe>

Probably the most interesting chat after the talk was with the Rust authors
at Mozilla ([@pcwalton](http://twitter.com/pcwalton) and
[@brson](https://github.com/brson)) about combining the Mirage
[unikernel](http://anil.recoil.org/papers/2013-asplos-mirage.pdf) techniques
with the [Rust](http://www.rust-lang.org) runtime. But perhaps the most
surprising feedback was when Anil and I were stopped in the street while
walking back from some well-earned sushi, by a cyclist who loudly declared
that he'd really enjoyed the talk and thought it was a really exciting project
-- never done something that achieved public acclaim from the streets before
:)

### Book Signing and Xen.org

Anil also took some time to sit in a book signing for his forthcoming
[Real World OCaml](http://realworldocaml.org) O'Reilly book.  This is
really important to making OCaml easier to learn, especially given that
all the Mirage libraries are using it.  Most of the dev team (and especially
thanks to [Heidi Howard](https://twitter.com/heidiann360) who bravely worked
through really early alpha revisions) have been giving
us feedback as the book is written, using the online commenting system.

The Xen.org booth was also huge, and we spent quite a while plotting the
forthcoming Mirage/Xen/ARM backend. We're pretty much just waiting for the
[Cubieboard2](http://cubieboard.org) kernel patches to be upstreamed (keep an
eye [here](http://linux-sunxi.org/Main_Page)) so that we can boot Xen/ARM VMs
on tiny ARM devices.  There's a full report about this on the
[xen.org](http://blog.xen.org/index.php/2013/07/31/the-xen-project-at-oscon/)
blog post about OSCon.

### Galois and HalVM

We also stopped by the [Galois](http://galois.com) to chat with [Adam
Wick](https://twitter.com/acwpdx), who is the leader of the
[HalVM](https://galois.com/project/halvm/) project at Galois. This is a similar
project to Mirage, but, since it's written in Haskell, has more of a focus
on elegant compositional semantics rather than the more brutal performance
and predictability that Mirage currently has at its lower levels.

The future of all this ultimately lies in making it easier for these
multi-lingual unikernels to be managed and for all of them to communicate more
easily, so we chatted about code sharing and common protocols (such as
[vchan](https://github.com/vbmithr/ocaml-vchan)) to help interoperability.
Expect to see more of this once our respective implementations get more
stable.

All-in-all OSCON'13 was a fun event and definitely one that we look forward
returning to with a more mature version of MirageOS, to build on the momentum
begun this year!  Portland was an amazing host city too, but what happens in
Portland, stays in Portland...
