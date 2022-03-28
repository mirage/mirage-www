---
updated: 2017-4-15
authors:
- name: Hannes Mehnert
  uri: https://github.com/hannesm
  email: hm519@cam.ac.uk
- name: Gemma Gordon
  uri: https://github.com/GemmaG
  email: gg417@cl.cam.ac.uk
- name: Anil Madhavapeddy
  uri: http://anil.recoil.org
  email: anil@recoil.org
subject: MirageOS March 2017 hack retreat roundup
permalink: 2017-march-hackathon-roundup
---

This March, 34 people from around the world gathered in Marrakech for a spring Mirage hack retreat. This is fast becoming a [MirageOS tradition](/blog/2016-spring-hackathon), and we're a little sad that it's over already! We've collected some trip reports from those who attended the 2017 Hack Retreat, and we'd like to thank our amazing hosts, organisers and everyone who took the time to write up their experiences. Props go especially to Hannes Mehnert who initiated the event and took care of many of the logistics, and to Gemma Gordon for designing and printing [limited edition t-shirts](http://reynard.io/2017/03/10/OCamlCollection.html) especially for the occasion!
<img src="/graphics/medina-2017.jpg" style="float:right; padding: 15px" />

In addition to the reports below, you can find other information online:
- the daily [tweets about the event](http://ocamllabs.io/events/2017/03/06/MirageHackUpdates.html), including sophisticated "paper slides"
- [Olle Jonsson](http://ollehost.dk/blog/2017/03/17/travel-report-mirageos-hack-retreat-in-marrakesh-2017/) and [Reynir Björnsson](https://reynir.dk/posts/2017-03-20-11-27-Marrakech%202017.html) wrote up their experiences on their personal sites.

## Hannes Mehnert

At the retreat, 34 people from all around the world (mainly Western
Europe) interested in MirageOS gathered for a week in Marrakech.

Numerous social contacts, political discussions, technical challenges
were discussed in smaller and bigger groups. Lots of pull requests were
opened and merged - we kept the DSL line busy with git pushes and pulls
:) - sometimes overly busy.

In contrast to [last year](/blog/2016-spring-hackathon), we organised several events:

- Body self-awareness workshop (by the resident dancers)
- Hiking to waterfalls on Sunday
- Hamam visit on Monday
- Herbalist visit on Tuesday
- Talk by the resident dancers on Tuesday
- A [public talk](https://www.dropbox.com/s/w5wnlbxujf7pk5w/Marrakech.pdf?dl=0) led by Amir on Saturday (highly appreciated, it
was announced rather late, only ~10 external people showed up)
<img src="/graphics/spiros-camel.jpg" style="float:right; padding: 15px" />

Several voluntary presentations on topics of interest to several people:

- "Reverse engineering MirageOS with radare2 (and IDA pro)" by Alfredo
(Alfredo and Chris tried afterwards the link-time optimization branch of
OCaml, which does not seem to have any effect at all (there may be
something missing from the 4.04.0+trunk+forced_lto switch))
- "Introduction to base" by Spiros
- "Solo5" (or rather: what is below the OCaml runtime, xen vs solo5) by
Mato https://pbs.twimg.com/media/C6VQffoWMAAtbot.jpg
- "Angstrom intro" by Spiros

After the week in Marrakech, I was sad to leave the place and all the nice people. Fortunately we can interact via the Internet (on IRC,
GitHub, Mail, ...) on projects which we started or continued to work on at the retreat.

It was a very nice week, I met lots of new faces. These were real people with interesting stories, and I could finally match email addresses to faces. I was delighted to share knowledge about software I know to other people, and learned about other pieces of software.

My personal goal is to grow a nice and diverse community around MirageOS, and so far I have the feeling that this is coming along smoothly.

Thanks again to everybody for participating (on-site and remote) and special thanks to [OCaml Labs](http://ocamllabs.io) for support, and Gemma Gordon for the limited edition [t-shirts](http://reynard.io/2017/03/10/OCamlCollection.html) (design and logistics)!
----

## Ximin Luo

Good people, good food, good weather, what more could you ask for? This year's MirageOS hackathon was a blast, like last year.

I started off the week by giving a monad tutorial to a few people - introducing the terminology around it, the motivation behind it, giving a few concrete examples and exercises, and relating it to some basic category theory.

Since last year, I've been working on-and-off on a group messaging protocol. One of its aims is to completely separate the transport and application layers, by sticking an end-to-end secure session layer in between them. This could help to unify [all the messaging protocols that exist today](https://xkcd.com/1810/) or it could [make the problem worse](https://xkcd.com/927/), time will tell how this works out in the end. :)

Another of my interests is to write more code that is obviously-more-secure, using strong type systems that provide compile-time guarantees about what your code can or can't do. As part of bringing these two concepts together, I've been working on writing a pure library for doing scheduled (timed) computations - i.e., to express "do this in X time in the future" then actually do it. This is very important in real world security systems, where you can't wait for too long for certain events to happen, otherwise you'll be susceptible to attacks.

To give the game away, the utility is just a state monad transformer where the state is a schedule data structure that records the tasks to be performed in the future, together with a pure monadic runner that executes these tasks but is triggered by impure code that knows the "real" time. However, implementing the specifics so that user code is composable and still looks (relatively) nice, has taken quite some effort to figure out. There are various other nice properties I added, such as being able to serialise the schedule to disk, so the behaviour is preserved across program shutdowns.

Using this pure lower-level control-flow utility, we can build slightly higher-level utilities, such as a "monitor" (something that runs a task repeatedly, e.g. useful for resending algorithms) or an "expectation" (a promise/future that can time out, and also runs a monitor to repeatedly "try" to succeed, while it is not yet succeeded or failed, which is useful for *deferring* high-level security properties but not forgetting about them, a very common pattern). I spent much of the week building these things and testing them, and using this practical experience to refine the APIs for the low-level scheduled computations.

I also did some more short-term work to spread type-safe languages to more audiences, packaging OCaml 4.04 for Debian, and also reporting and working around some test failures for rustc 1.15.1 on Debian, earning me the label of "traitor" for a while. :p

I wrote more documentation for my in-progress contribution to the ocaml-lens library, to bring traverse-once "van Laarhoven" lens to OCaml, similar to the ones in Haskell. I had some very interesting discussions with Jens and Rudi on Rust, Haskell, OCaml and various other "cutting-edge" FP research topics. Rudi also gave some useful feedback on my ocaml-lens code as well as some other pure functional utilities that I've been developing for the messaging protocol mentioned above, thanks Rudi!

Viktor and Luk taught us how to play [Cambio](https://web.archive.org/web/20161026135837/http://joshaguirre.com/cambio-card-game-rules-and-cheatsheet/) and we in turn taught that to probably 10 more people around the hostel, including some non-mirage guests of the hostel! It was very enjoyable playing this into the early hours of the morning.

On one of the evenings Jurre and I got drunk and did some very diverse and uncensored karaoke and eventually embarassed^H^H^H^H^H^H^H persuaded a lot of the others to join us in the fun and celebrations. We'll be back next year with more, don't worry!
----

## Michele Orrù

Last summer I started, while being an intern in Paris, a [let's encrypt](https://letsencrypt.org/) (or rather
[ACME](https://www.ietf.org/id/draft-ietf-acme-acme-06.txt).

Let's encrypt is a certificate authority which issues signed certificates via an automated service (using the ACME protocol). Even though it is still in the process of being standardized, the first eCA already launched in April 2016, as a low-cost alternative to commercial CAs (where you usually need to provide identity information (passport) for verification).

If you want to run a secure service on your domain, such as HTTPS, STARTTLS in SMTP, IMAPS, ..., you have to generate a private key and a certificate signing request (CSR).  You then upload this CSR via HTTP to the let's encrypt server and solve a some "challenge" proposed by the server in order to certify you *own* the requested domain. 

At the time of the hack retreat, the following challenges were supported:

- TLS (using the SNI extension),
- DNS (setting a TXT record), or
- HTTP (replying to a particular request at some ".well_known" url),

In order to reach a working implementation, I had to implement myself a JSON web signature, and a JSON web key [library in OCaml](https://github.com/mmaker/ocaml-letsencrypt/).

My goal for the hack retreat was to polish this library, get it up to date with the new internet standards, and present this library to the Mirage community, as I do believe it could be the cornerstone for bootstrapping a unikernel on the internet having encryption by default. I was impressed by the overwhelming interest of the participants and their interest in helping out polishing this library. I spent a lot of time reviewing pull requests and coding with people I had just met. For instance, [Reynir](https://github.com/reynir) ported it to the [topkg](http://erratique.ch/software/topkg) packager, cleaned up the dependencies and made it possible to have a certificate for multiple domains. [Viktor](https://github.com/vbaluch) and [Luk](https://github.com/realfake) helped out implementing the DNS challenge. [Aaron](https://github.com/azet) helped out adding the new internet draft.

While busy reviewing and merging the pull requests, and extending [Canopy](https://github.com/Engil/Canopy) to automatically renew its certificates ([WIP on this feature branch](https://github.com/Engil/Canopy/tree/feature/letsencrypt)). My library is still not released, but I will likely do an initial release before the end of the month, after some more tests.

This was the second time I attended the hack retreat, and it's been quite different: last year I was mostly helping out people, uncovering bugs and reporting documentation. This time it was other people helping me out and uncovering bugs on my code. The atmosphere and cooperation between the participants was amazing: everybody seemed to have different skills and be pleased to explain their own area of expertise, even at the cost of interrupting their own work. (I'd have to say sorry to Mindy and Thomas for interrupting too often, but they were sooo precious!) I particularly enjoyed the self-organized sessions: some of them, like Ximin's one on monads, even occurred spontaneously!
----

## Mindy Preston

Update 2017: Morocco, Marrakesh, the medina, and Priscilla are still sublime. Thank you very much to Hannes Mehnert for organizing and to the wonderful Queens at Priscilla for creating an excellent space and inviting us to inhabit it.

I tried to spend some time talking with people about getting started with the project and with OCaml. There's still a thirst for good-first-bug which isn't met by "please implement this protocol". People are also eager for intermediate-level contributions; people are less resistant to "please clean up this mess" than I would have expected. I think that figuring out how to make cross-cutting changes in Mirage is still not very accessible, and would be a welcome documentation effort; relatedly, surfacing the set of work we have to do in more self-contained packages would go a long way to filling that void and is probably easier.

People were excited about, and did, documentation work!! And test implementation!! I was so excited to merge all of the PRs improving READMEs, blog entries, docstrings, and all of the other important bits of non-code that we haven't done a good job of keeping up with. It was *amazing* to see test contributions to our existing repositories, too -- we have our first unit test touching ipv6 in tcpip since the ipv6 modules were added in 2014. :D Related to the previous bullet point, it would be great to point at a few repositories which particularly need testing and documentation attention -- I found doing that kind of work for mirage-tcpip very helpful when I was first getting started, and there's certainly more of it to do there and in other places as well.

I spent a lot less time on install problems this year than last year, and a lot more time doing things like reviewing code, seeing cats, merging PRs, exploring the medina, cutting releases, climbing mountains, and pairing with people on building and testing stuff. \o/

Presentations from folks were a great addition! We got introductions to Angstrom and Base from Spiros, a tour through reversing unikernels with radare2 from Alfredo, and a solo5 walkthrough from Martin. Amir gave a great description of MirageOS, OCaml, and use cases like Nymote and Databox for some of our fellow guests and friends of the hostel.  My perception is that we had more folks from the non-Mirage OCaml community this year, and I think that was a great change; talking about jbuilder, Base, Logs, and Conduit from new perspectives was illuminating. I don't have much experience of writing OCaml outside of Mirage and it's surprisingly easy (for me, anyway) to get siloed into the tools we already use and the ways we already use them. Like last year, we had several attendees who don't write much OCaml or don't do much systems programming, and I'm really glad that was preserved -- that mix of perspectives is how we get new and interesting stuff, and also all of the people were nice :)

There were several projects I saw more closely for the first time and was really interested in: g2p's storage, timada's performance harness; haesbaert's awa-ssh; maker's ocaml-acme; and there were tons of other things I didn't see closely but overheard interesting bits and pieces of!

Rereading the aggregated trip report from the 2016 spring hack retreat, it's really striking to me how much of Mirage 3's work started there; from this year's event, I think Mirage 4 is going to be amazing. :)
----

## Viktor Baluch & Luk Burchard:

“Let’s make operating systems great again” – with this in mind we started our trip to Marrakech. But first things first: we are two first year computer science students from Berlin with not a whole lot of knowledge of hypervisors, operating systems or functional programming. This at first seems like a problem… and it turned out it was :).
The plan was set, let’s learn this amazing language called OCaml and start hacking on some code, right? But, as you could imagine, it turned out to be different yet even better experience. When we arrived, we received a warm welcome in Marrakech from very motivated people who were happy to teach us new things from their areas of expertise. We wanted to share some of our valuable knowledge as well, so we taught some people how to play Cambio, our favourite card game, and it spread like wildfire (almost everyone was playing it in the second evening). We’re glad that we managed to set back productivity in such a fun way. ;P

Back to what we came to Morocco for: as any programming language, OCaml seems to provide its special blend of build system challenges. [Rudi](https://github.com/rgrinberg/) was kind enough to help us navigate the labyrinth of distribution packages, opam, and ocamlfind with great patience and it took us only two days to get it almost right.

Finally having a working installation, we got started by helping [Michele](https://github.com/mmaker/) with his [ocaml-acme](https://github.com/mmaker/ocaml-acme/) package, a client for Let's Encrypt (and other services implementing the protocol). An easy to use and integrate client seemed like one feature that could provide a boost to unikernel adoption and it looked like a good match for us as OCaml beginners since there are many implementations in other programming languages that we could refer to. After three days we finally made our first Open Source OCaml contributions to this MirageOS-related project by implementing the dns-01 challenge.

Hacking away on OCaml code of course wasn’t the only thing we did in Marrakech: we climbed the Atlas mountains to see the seven magic waterfalls (little disclaimer: there are only four). It was not a really productive day but great for building up the spirit which makes the community so unique and special. Seeing camels might also helped a little bit. ;)

One of the most enjoyable things that the retreat provided was the chance for participants to share knowledge through presentations which lead to very interesting conversations like after [Amir’s](https://github.com/amirmc/) presentation when some artists asked about sense of life and computer systems (by the way, one question is already solved and it is ’42’). We were also very impressed by the power and expressiveness of functional languages which [Sprios](https://github.com/seliopou/) demonstrated in his parser combinator [Angstrom](https://github.com/inhabitedtype/angstrom/).

Thank you to everyone involved for giving us the experience of an early ‘enlightenment’ about functional programming as first year students and the engaging discussions with so many amazing people! We sure learned a lot and will continue working with OCaml and MirageOS whenever possible.

Hope to see all of you again next time!
----

## Aaron Zauner

I flew from Egypt to Marrakech not sure what to expect, although I'm not new to functional programming, I'm a total OCaml novice and haven't worked on unikernels - but have always been interested in the topic. Hannes invited me to hang out and discuss, and that's exactly what I did. I really enjoyed spending my time with and meeting all of you. Some of you I have known "from the interwebs" for a while, but never met in person, so this was a great opportunity for me to finally get to see some of you in real life. I spent most of my time discussing security topics (everything from cryptography, bootstrapping problems to telco/ mobile security), operating system design and some programming language theory. I got to know the OCaml environment, a bit more about MirageOS and I read quite a few cryptography and operating system security papers.

All of the people I spoke with were very knowledgeble - and I got to see what people exactly work on in MirageOS - which certainly sparked further interest in the project. I've been to Morocco a couple of times but the food we got at Queens of the Medina was by far the best food I've eaten in Morocco so far. I think the mix of nerds and artists living at the Riad was really inspiring for all of us, I was certainly interested in what they were working on, and they seemed to be interested in what all of these freaky hackers were about too. Living together for more than a week gives the opportunity to get to know people not only on a technical level but -- on a personal level, in my opinion we had a great group of people. Giving back to the local community by giving talks on what we're doing at the Hackathon was a great idea, and I enjoyed all of the talks that I've attended. I've been to a few hackathons (and even organized one or two), but this one has certainly been the most enjoyable one for me. People, food, location and the discussions (also Karaoke and learning to play Cambio!) I've had will make me remember the time I spent with you guys for a long time. I hope I'm able to join again at some point (and actually contribute to code not only discussions) in the future. Unfortunately I cannot give any feedback on possible improvements, as I think we had a very well selected group of people and perfect conditions for a Hackathon, could not think of how to organize it better - Thank you Hannes!
----

## Thomas Leonard

This was my second time at the hackathon, and it was great to see everyone and work on Mirage stuff again! I brought along a NUC which provided an additional wireless access point, running a Mirage/Xen DHCP server using haesbaert's [charrua](https://github.com/mirage/charrua-core) library - one of the fruits of last year's efforts.

My goal this year was to update [qubes-mirage-firewall](http://roscidus.com/blog/blog/2016/01/01/a-unikernel-firewall-for-qubesos/) to support Mirage 3 and the latest version of [mirage-nat](https://github.com/yomimono/mirage-nat), and to add support for NAT of ICMP messages (so that `ping` works and connection errors are reported). In the process, I converted mirage-nat to use the new parsers in the Mirage 3 version of the tcpip library, which cleaned up the code a lot. It turned out that the firewall stressed these parsers in new ways and we were able to [make them more robust](https://github.com/mirage/mirage-tcpip/pull/301) as a result. Having Mirage 3 release manager and mirage-nat author yomimono on hand to help out was very useful!

It was great to see so many QubesOS users there this year. Helping them get the firewall installed motivated me to write some proper installation instructions for [qubes-test-mirage](https://github.com/talex5/qubes-test-mirage).

After the hackathon, I also updated mirage-nat to limit the size of the NAT table (using pqwy's [lru](https://github.com/pqwy/lru)) and made a new release of the firewall with all the improvements.

ComposMin was looking for a project and I hopefully suggested some tedious upgrading and build system porting work. He accepted!! So, [qubes-mirage-skeleton](https://github.com/talex5/qubes-mirage-skeleton) now works with Mirage 3 and [mirage-profile](https://github.com/mirage/mirage-profile) has been ported to topkg - something I had previously attempted and failed at.

Rudi gave me an introduction to the new [jbuilder](https://github.com/janestreet/jbuilder) build tool and I look forward to converting some of my projects to use it in the near future.

Particularly useful for me personally was the chance discovery that Ximin Luo is a Debian Developer. He signed my GPG key, allowing me to complete a Debian key rollover that I began in May 2009, and thus recover the ability to update my package again.

I also wanted to work on [irmin-indexeddb](https://github.com/talex5/irmin-indexeddb) (which allows web applications to store Irmin data in the browser), but ran out of time - maybe next year...

Many thanks to hannesm for organising this!
----

## Amir Chaudhry

This was my first time at the Marrakech hack retreat. I was only there for about half the time (mostly the weekend) and my goal was simply to meet people and understand what their experiences have been. Having missed the inaugural event last year, I wasn't sure what to expect in terms of format/event. What I found was a very relaxed approach with lots of underlying activity. The daily stand ups just before lunch were well managed and it was interesting to hear what people were thinking of working on, even when that included taking a break. The food was even more amazing than I'd been led to believe by tweets :)

Somehow, a few hours after I arrived, Hannes managed to sweet-talk me in to giving a presentation the next day about MirageOS to the artists and dance troupe that normally make use of the venue. Since we'd taken over the place for a week — displacing their normal activities — our host thought it would be helpful if someone explained "what the nerds are doing here". This was an unexpected challenge as getting across the background for MirageOS involves a lot of assumed knowledge about operating system basics, software development, software _itself_, the differences between end-users and developers, roughly how the internet works, and so on. There's a surprising number of things that we all just 'know', which the average software user has no clue about. I hadn't given a talk to that kind of audience before so I spent half a day scrambling for analogies before settling on one that seemed like it might work — involving houses, broken windows, and the staff of Downton Abbey. The talk led to a bunch of interesting discussions with the artists which everyone got involved with. I think the next time I do this, I might also add an analogy around pizza (I have many ideas on this theme already). If you're interested in the slides themselves (mostly pics), there's a PDF at https://www.dropbox.com/s/w5wnlbxujf7pk5w/Marrakech.pdf?dl=0

I also had time to chat with Mindy about an upcoming talk on MirageOS 3.0, and Martin about future work on Solo5. The talks and demos I saw were really useful too and sharing that knowledge with others in this kind of environment was a great idea. Everyone loved the t-shirts and were especially pleased to see me as it turned out I was bringing many of the medium-sized ones. One of the best things about this trip was putting names and faces to GitHub handles, though my brain regularly got the mapping wrong. :)

Overall, this was an excellent event and now that it's happened twice, I think we can call it a tradition. I'm looking forward to the next one!
----

## Jurre van Bergen

I spent most of my time reading up on functional programming and setting up an developer environment and helped with some small things here and there. I didn't feel confident to do a lot of code yet, but it was a very nice environment to ask questions in, especially as a newcomer to MirageOS and OCaml!

I plan to do more OCaml in my spare time and play more with MirageOS in the future. Maybe someday, we can actually merge in some MirageOS things into [Tails](https://tails.boum.org/). I hope to actually do some OCaml code with people next year!
Next to that, there was also some time to relax, climbing the Atlas mountains was a welcome change of scenery after reading through up on functional programming for a couple of days. Will definitely do that again some day!

Next to that, shout out to Viktor and Luke for teaching us how to play Cambio, we had a lot of fun with it the entire retreat in the evenings!
I was excited to learn that so many people were actually into karaoke, I hope those who don't will join us next year ;-)
----

## Reynir Björnsson

A work in progress from Reynir is his work on documentation in the toplevel:

> As mentioned on the midday talkie talkie I've made a OCaml toplevel directive for querying documentation (if available). It's available here <https://github.com/reynir/ocp-index-top>.
> To test it out you can install it with opam pin:
>    opam pin add ocp-index-top https://github.com/reynir/ocp-index-top.git
>
 It doesn't depend on opam-lib. opam-lib is yuuuuge and the API is unstable. Instead I shell out to opam directly similar to how ocp-browser works. This means installing the package is less likely to make a mess in your dependencies.
>
> There is one issue I don't know how to fix (see issue #1). When requiring `ocp-index-top` the `compiler-libs` and `ocp-index.lib` libraries are pulled into scope which is not cool and totally unnecessary.
----

Many thanks to everyone involved!  The hackathon is already booked for next year in the same place...

