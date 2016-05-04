# Hackathon Trip Reports

We're looking forward to the next MirageOS hackathon already!  We've collected some reports from those who were present.  Thanks to the folks who put in the time and effort to organize the event and our wonderful hosts, and a huge thanks to everyone who documented their hackathon experience!

More information is also available at [the Canopy site developed and used for information sharing during the hackathon](http://canopy.mirage.io)!

## Trip Report
*by David Kaloper* 

![roof-flash](https://berlin.ccc.de/~hannes/marrakech2016/pic8.jpg)

Last month, the MirageOS community saw its first community-organized, international
[hackathon][hweb]. It took place between 11th and 16th March 2016. The venue?
[Rihad Priscilla][priscilla], Marrakech, Morocco.

The place turned out to be ideal for a community building exercise. A city
bursting with life, scents and colors, a relaxed and friendly hostel with plenty
of space, warm and sunny weather -- all the elements of a good get-together
were there. This is where some 25 hackers from all over the world convened, with
various backgrounds and specialties, all sharing an interest in MirageOS.

Not wanting to limit ourselves to breaking only those conventions, we added another layer: the
hackathon was set up as a classical anti-conference, with a bare minimum of
structure, no pre-defined program, and a strong focus on one-on-one work,
teaching, and collaboration.

As this was the first hackathon, this time the focus was on building up the nascent
community that already exists around MirageOS. Faces were put to online handles, stories were
exchanged, and connections were forged. Meeting in person helped bring a new
level of cohesion to the online community around the project, as witnessed by
the flurry of online conversations between people that were present, and have continued after
the event ended.

One particularly useful (however inglorious) activity proved to be introducing
people to the tool chain. Even though the MirageOS website has a
[documentation][mirage-docs] section with various documents on the architecture
of the project, technical blog posts and a series of examples to get newcomers
started, a number of people found it difficult to juggle all the concepts and
tools involved. Where is the line dividing `ocamlfind` from `opam` and what
exactly constitutes an OCaml library? What is the correct way to declare
dependencies not covered by the declarative configuration language? When should
one use `add_to_opam_packages`, and when `add_to_ocamlfind_libraries`? Will the
`mirage` tool take care of installing missing packages so declared?

Although these questions either have answers scattered throughout the docs, or
are almost obvious to an experienced MirageOS developer, such getting-started
issues proved to be an early obstacle for a number of hackathon participants.
While our project documentation certainly could -- and will! -- be improved with
the perspective of a new developer in mind, this was an opportunity to help
participants get a more comprehensive overview of the core tooling in an
efficient, one-to-one setting. As a result, we saw a number of developers go
from trying to get the examples to compile to making their own unikernels within
a day, something pretty awesome to witness!

Another fun thread was dogfooding the network stack. Network itself was provided
by our venue Priscilla, but we brought our own routers and access points. DHCP on site was
served by [Charrua][charrua], which stood up to the task admirably. We were able
to access arbitrary domains on the Internet, almost all of the time!

A group of hackers had a strong web background, and decided to focus their
efforts there. Perhaps the most interesting project to come out of this is
[Canopy][canopy]. Canopy is best described as the first dynamic offering in the
space of static web site generators! It combines [Irmin][irmin] with
[TyXML][tyxml], [COW][cow], and [Mirage HTTP][mirage-http], to create a simple,
one-stop solution for putting content on the web. A Canopy unikernel boots,
pulls a series of markdown files from a git repository, renders them, and serves
them via HTTP. Expect more to come in this space, as Canopy has already proved
to be a handy tool to simply put something on the web.

At the same time, the atmosphere was conducive for discussing how OCaml
in general, and MirageOS in particular, fits in the web development ecosystem.
As a language originally honed in different contexts, it's the opinion of a number
of practicing web developers that the current OCaml ecosystem is not as
conducive to supporting their day-to-day work as it could be. These brainstorming
sessions led to a [writeup][adoption-manifesto] which tries to summarize the
current state and plot the course forward.

Another group of hackers was more focused on security and privacy
technology. MirageOS boasts its own cryptographic core and a TLS stack,
providing a solid base for development of cryptographic protocols. We saw
coordinated work on improving the [cryptographic layer][nocrypto-pr];
implementations of a few key-derivation functions ([Scrypt][scrypt] and
[PBKDF][pbkdf]); and even a beginning of an [IKEv2][ikev2] implementation.

A further common topic was networking, which is not entirely surprising for a
network-centric unikernel platform. Amidst the enthusiasm, hackers in attendance
started several projects related to general networking. These include a
[SWIM][swim] membership protocol implementation, the beginnings of
[telnet][telnet] for Mirage, [SOCKS4][socks] packet handling,
[DNS wildcard][dns-wcard] matching, Charrua updates, and more. 

In between these threads of activity, people used the time to get general
MirageOS work done. This resulted in lots of progress including: making
[AFL][afl], already supported by OCaml, run against MirageOS unikernels; a
comprehensive update of error reporting across the stack; a concentrated push to
move away from Camlp4 and adopt PPX; and producing a prototype unikernel
displaying rich terminal output via telnet.

Partially motivated by the need to improve the experience of building and
running unikernels, a number of hackers worked on improvements to [error
reporting][syslog] and [logging][log-pr]. Improving the experience when things
go wrong will be an important part of helping folks make unikernels with
MirageOS.

For more, and less structured, details of what went on, check out the
[blog][event-blog] some of us kept, or the [meeting notes][meeting-notes] from
the few short morning meetings we had.

It seems that when surrounded by like-minded, skilled people, in a pleasant
atmosphere, and with absolutely nothing to do, people's curiosity will reliably
kick in. In between lieing in the sun (sunscreen was a hot commodity!), sinking
into the [midday heat][midday-heat], and talking to other hackers, not a single
person failed to learn, practice, or produce something new.

In this way, the first MirageOS hackathon was a resounding success. Friendships
were forged, skills shared, and courses plotted. And although the same venue has
already been booked for the next year's event, there is ongoing chit-chat about
cutting the downtime in half with a summer edition!

![heat](https://berlin.ccc.de/~hannes/marrakech2016/pic1.jpg)


[hweb]: http://marrakech2016.mirage.io/
[priscilla]: http://queenofthemedina.com/en/index.html
[mirage-docs]: https://mirage.io/docs
[charrua]: https://github.com/haesbaert/charrua-core
[canopy]: https://github.com/Engil/Canopy
[irmin]: https://github.com/mirage/irmin
[tyxml]: http://ocsigen.org/tyxml
[cow]: https://github.com/mirage/ocaml-cow
[mirage-http]: https://github.com/mirage/mirage-http
[adoption-manifesto]: https://github.com/fxfactorial/an-ocaml-adoption-manifesto
[nocrypto-pr]: https://github.com/mirleft/ocaml-nocrypto/pull/93
[scrypt]: https://github.com/abeaumont/ocaml-scrypt-kdf
[pbkdf]: https://github.com/abeaumont/ocaml-pbkdf
[ikev2]: https://github.com/isakmp/ike
[swim]: https://github.com/andreas/mirage-swim
[telnet]: https://github.com/hannesm/telnet
[socks]: https://github.com/cfcs/ocaml-socks
[dns-wcard]: https://github.com/cfcs/ocaml-wildcard
[afl]: http://lcamtuf.coredump.cx/afl/
[event-blog]: http://canopy.mirage.io/
[meeting-notes]: https://github.com/ocamllabs/activity/wiki/MirageOS-Hackathon
[midday-heat]: https://twitter.com/rudenoise/status/709453313553596416
[syslog]: https://github.com/verbosemode/syslogd-mirage
[log-pr]: https://github.com/mirage/mirage-dev/pull/107

-----

## MirageOS hackathon in Marrakech 
*Text and images by Enguerrand Decorne*

### Setting up and settling in

The first [MirageOS hackathon](https://mirage.io/) was held from March 11th-16th 2016, at [Priscilla, Queen of the Medina](http://queenofthemedina.com/en/index.html), Marrakech. It successfully gathered around 30 Mirage enthusiasts, some already familiar with the MirageOS ecosystem, and others new to the community. People travelled from Europe and further afield for a week of sun, tajine and hacking.

![Main room](http://i.imgur.com/uh6IaIm.jpg "The main room")

Getting to the guesthouse [was an adventure](https://www.youtube.com/watch?v=zgzwmyxlKBE), and once there we prepared by quickly setting up a nice internet hotspot then organised groups to head to the souk to meet new arrivals. 
Soon enough the guest house was filled with people, and various new projects and ideas began to emerge. Having a few books and experienced OCaml developers around helped the OCaml newcomers get stuck in, and it didn't take long to get their first unikernel or OCaml library up and running. Daily meetings were arranged at noon on the rooftop in order to allow the exchange of project ideas and questions, and we used the [hackathon notepad](http://canopy.mirage.io/Index) to loosely pair projects and people together. Our [DHCP server](https://mirage.io/blog/introducing-charrua-dhcp) enabled extensive dogfooding and successfully fulfilled our project-testing needs. 

Participants found a wide range of activities to keep themselves occupied during the event: contributing to the [MirageOS Pioneer Projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects), starting new projects and libraries, improving the MirageOS ecosystem and core components, discussing new ideas... or simply enjoying the sun, delicious tajine, or walking around Marrakech itself. Some expeditions were also (non)organised during the week, allowing sightseeing of the nicest local spots, or negotiating with local stallholders to get the best prices on souvenirs and fresh fruits to enjoy during hard hacking sessions.

![Food](http://i.imgur.com/yk2a2tc.jpg "Some more food")

### My week inside the camel's nest

A few days before heading up to Marrakech (in a very non-organised fashion, having been offered a hackathon place only two days before!) the idea of writing some kind of notebook using Mirage had been floating around - we wanted to be able to allow people inside the hackathon to exchange ideas, and those not physically present to be kept updated about progress. I decided to write a simple blog unikernel, [Canopy](https://github.com/Engil/Canopy/) which relies on [Irmin's](https://github.com/mirage/irmin) capabilities to synchronise remote git repositiories. By describing new pages in a format similar to Jekyll (and using Markdown) on a git repository, new content pushed there would be pulled to the website and displayed there nicely. This allowed every participant to report on their current projects, and see the content displayed on the notepad after a simple `git push`.

The project was well received and new ideas started to emerge in order to turn it into a CMS enabling users to easily describe new website with a simple git repository. A huge thank you to [Michele](https://github.com/mmaker) for his awesome contributions, as well as everyone involved with answering questions about the Mirage ecosystem along the way. This project also allowed me to dive a little further inside various libraries, report a few issues, discuss features and discover new concepts... A week well spent that I would be glad to repeat at the next MirageOS hackathon :)

### Conclusion

![Rooftop](http://i.imgur.com/zgP0400.jpg "Rooftop view")

This hackathon was a huge success and allowed the MirageOS community to combine sun and high productivity in a crazy yet very relaxing week. We hope (and plan) to see more events like this, so anyone interested in OCaml, Mirage - expert or not - is more than welcome to join us next time!

![Cats](http://i.imgur.com/Fe7iawE.jpg "And obviously… Marrakech's cats!")

---

## MirageOS + OCaml Newcomers
*by Alfredo and Sonia*

Our experience in Marrakesh was great. We really enjoyed the place,
the weather, the food, the people and the atmosphere! I think the
setting was a great win, there was lot of open space where you could
find a quiet spot for yourself to concentrate while programming,
as well as a place with lots of people coding, or a place where you
could be talking about anything while enjoying the sun, or just hang
out and get lost for a while in the nice Marrakesh's old city.

We had already learnt some OCaml, but we both are quite new to both
OCaml and MirageOS, so we decided to work on a project with low entry
barrier so we could get in the loop more easily. Nevertheless we had to
invest some time getting more familiar with the specifics of the OCaml
environment (libraries, packaging, testing frameworks, etc.). Hannes
kindly helped us getting started, showing us a library (`ocaml-hkdf`) we
could use to understand this all better, and from here we could start
writing some code. Having most of the authors (Thomas, David,
Hannes...) of the libraries we used (`nocrypto`, `cstruct`, `alcotest`,
`opam`...) there with us was also a win. Finally we managed to release a
pair of libraries with key derivation functions (`ocaml-pbkdf` and
`ocaml-scrypt-kdf`), so we are quite happy with the outcome.

The only downside of the hackathon we can think of, if any, is that we
didn't get too deep into the MirageOS specifics (something we are
surely willing to fix!), but we wanted to stay focused to keep
productive and had enough new things to learn.

---

## Hackathon Projects
*by Ximin Luo* 

Here's a list of things I did during the hackathon:

- Read into ocaml-tls and ocaml-otr implementations, as well as David's "nqsb" TLS paper
- Talked with David about developing a general pattern for implementing protocols, that allows one to compose components more easily and consistently. He pointed me to many resources that I could learn from and build on top of.
- Read documents on "Extensible Effects", "Freer Monads" and "Iteratee pattern" by Oleg Kiselyov.
- Read documents and source code of the Haskell Pipes library by Gabriel Gonzalez.
- Sent some PRs to Hannes' jackline IM client, for better usability under some graphical environments.
- Showed some people my ocaml-hello "minimal build scripts" example, and my ocaml emacs scripts.
- Tested the "solo5" system that runs mirageos on kvm as an alternative to xen.

I'm continuing with the following work in my spare time:

- Read documents and source code of the opam monadlib library with a view to extending this and unifying it with other libraries such as lwt.
- Using the approach of the Haskel Pipes library to develop a general protocol handler framework. I'm experimenting initially in Haskell but I'd also like to do it in OCaml when the ideas are more solid.

In terms of the event it was great - everything worked out very well, I don't have any suggestions for improvements :)
