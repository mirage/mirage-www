As summer starts to shine over an obstinately rainy England, we are organising
the second MirageOS hackathon in Cambridge!  It will be held on **Weds 13th
July** at the lovely [Darwin College](https://www.darwin.cam.ac.uk) from
9am-11pm, with snacks, teas, coffees and a servery lunch provided (thanks to
sponsorship from [Docker](http://docker.com) and [OCaml Labs](https://ocaml.io)).

**Anyone is welcome at all skill levels**, but we'd appreciate you filling out the
[Doodle](http://doodle.com/poll/ngbbviwyb9e65uiw) so that we can plan
refreshments.  We will be working on a variety of projects from improving ARM
support, to continuous integration tests, the new Solo5 backend and improving
the suite of protocol libraries.  If you have something in particular that
interests you, please drop a note to the [mailing list](/community) or check
out the full list of [Pioneer Projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects).

Some other events of note recently:

* After several years of scribing awesome notes about our development, Amir has handed over the reigns to [Enguerrand](https://github.com/engil).
  Enguerrand joined OCaml Labs as an intern, and has built an IRC-to-Git logging bot which records our meetings over IRC and commits them
  directly to a [repository](https://github.com/hannesm/canopy-data) which is [available online](http://canopy.mirage.io/irclogs).  Thanks Amir
  and Enguerrand for all their hard work on recording the growing amount of development in MirageOS.  [Gemma Gordon](https://ocaml.io/w/User:GemmaG)
  has also joined the project and been coordinating the [meetings](https://github.com/mirage/mirage-www/wiki/Call-Agenda).  The next one is in a
  few hours, so please join us on `#mirage` on Freenode IRC at 4pm British time if you would like to participate or are just curious!

* Our participation in the [Outreachy](https://wiki.gnome.org/Outreachy/2016/MayAugust) program for 2016 has begun, and the irrepressible
  [Gina Marie Maini](http://www.gina.codes) (aka [wiredsister](http://twitter.com/wiredsis)) has been hacking on syslogd, mentored by [Mindy Preston](http://somerandomidiot.com).
  She has already started blogging ([about syslog](http://www.gina.codes/ocaml/2016/06/06/syslog-a-tale-of-specifications.html) and [OCaml love](http://www.gina.codes/ocaml/2016/02/14/dear-ocaml-i-love-you.html)), as well as [podcasting with the stars](http://hanselminutes.com/531/living-functional-programming-with-ocaml-and-gina-marie-maini).  Welcome to the crew, Gina!

* The new [Docker for Mac](https://docs.docker.com/engine/installation/mac/) and [Docker for Windows](https://docs.docker.com/engine/installation/windows/) products have entered open beta! They use a number of libraries from MirageOS (including most of the network stack) and provide a fast way of getting started with containers and unikernel builds on Mac and Windows.  You can find talks about it at the recent [JS London meetup](https://ocaml.io/w/Blog:News/FP_Meetup:_OCaml,_Facebook_and_Docker_at_Jane_Street) and my [slides](http://www.slideshare.net/AnilMadhavapeddy/advanced-docker-developer-workflows-on-macos-x-and-windows)  I also spoke at OSCON 2016 about it, but those videos aren't online yet.

There have also been a number of talks in the past couple of months about MirageOS and its libraries:

* [Amir Chaudhry](https://twitter.com/amirmc) has given several talks and demos recently: check out his slides and detailed
  writeups about [GlueCon 2016](http://amirchaudhry.com/gluecon2016) and [CraftConf 2016](http://amirchaudhry.com/craftconf2016) in particular,
  as they come with instructions on how to reproduce his Mirage/ARM on-stage demonstrations of unikernels.
* [Sean Grove](https://twitter.com/sgrove) is speaking at [Polyconf 2016](http://polyconf.com) next week in Poland.  If you are in the region, he would love to meet up with you as well -- his talk abstract is below
> With libraries like Mirage, `js_of_ocaml`, & ARM compiler output OCaml apps can operate at such a low level
> we don't even need operating systems on the backend anymore (removing 15 *million* lines of memory-unsafe code)
> - while at the same time, writing UI's is easier & more reliable than ever before, with lightweight type-checked
> code sharing between server, browser clients, & native mobile apps. We'll look at what's enabled by new tech
> like Unikernels, efficient JS/ARM output, & easy host interop.

