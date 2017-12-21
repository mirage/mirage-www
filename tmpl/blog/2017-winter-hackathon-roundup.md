# MirageOS Winter Hack Retreat, Marrakesh 2017

This winter, 33 people from around the world gathered in Marrakesh for a Mirage hack retreat. This is fast becoming a [MirageOS](/blog/2016-spring-hackathon) [tradition](/blog/2017-march-hackathon-roundup), and we're a little sad that it's over already! We've collected some trip reports from those who attended the 2017 winter hack retreat, and we'd like to thank our amazing hosts, organisers and everyone who took the time to write up their experiences.
<img src="/graphics/winter2017.jpg" style="float:right; padding: 15px" />

We, the MirageOS community, strongly beliefs in using their own software: this website is a unikernel since day one^W^W it is possible to run MirageOS unikernels.  In Marrakesh we used our own DHCP and DNS server without trouble.  There are many more services under heavy development (including git, ssh, ...), which we're looking forward to use soon ourselves.

Several atteendees joined for the second or third time in Marrakesh, and brought their own projects, spanning over [graphql](https://github.com/andreas/ocaml-graphql-server), [reproducible builds](https://reproducible-builds.org/) (with application to [qubes-mirage-firewall](https://github.com/talex5/qubes-mirage-firewall), see [holger's report](http://layer-acht.org/thinking/blog/20171204-qubes-mirage-firewall/) and [Gabriel's OCaml fixes for build path variation](https://github.com/ocaml/ocaml/pull/1515)).  A stream of improving error messages in the OCaml compiler (based on [Arthur Charguéraud PR](https://github.com/ocaml/ocaml/pull/102)) was prepared and merged ([PR 1496](https://github.com/ocaml/ocaml/pull/1496), [PR 1501](https://github.com/ocaml/ocaml/pull/1501), [PR 1506](https://github.com/ocaml/ocaml/pull/1505), [PR 1510](https://github.com/ocaml/ocaml/pull/1510), and [PR 1534](https://github.com/ocaml/ocaml/pull/1534)).  Our OCaml [git implementation](https://github.com/mirage/ocaml-git/) was rewritten to support git push properly, and this PR was [merged](https://github.com/mirage/ocaml-git/pull/227).  Other projects of interest are [awa-ssh](https://github.com/haesbaert/awa-ssh), [anonymity profiles in DHCP](https://github.com/mirage/charrua-core/pull/76), and fixes to the deployment troubles of [our website](https://github.com/mirage/mirage-www).  There is now a [mirage PNG viewer integrated into Qubes](https://github.com/cfcs/eye-of-mirage) and a [password manager](https://github.com/cfcs/passmenage).  Some [getting started notes](https://github.com/juga0/mirage_mar2017) were written down as well as the new [learning about MirageOS](https://mirage.io/wiki/learning) website.

A huge fraction of the [Solo5 contributors](https://github.com/solo5/solo5) gathered in Marrakesh as well and discussed the future, including terminology, the project scope, and outlined a roadmap for merging branches in various states.  Adrian from the [Muen](https://muen.sk) project joined the discussion, and in the aftermath they are now running their website using MirageOS on top of the Muen separation kernel.

A complete list of fixes and discussions is not available, please bear with us if we forgot anything above.  A sneak preview: there will be another retreat in March 2018 in Marrakesh.  Following are texts written by individual participants about their experience.

## Mindy Preston

I came to Marrakesh for the hack retreat with one goal in mind: documentation.  I was very pleased to discover that [Martin Keegan](https://github.com/mk270) had come with the same goal in mind and fresher eyes, and so I had some time to relax, enjoy Priscilla and the sun, photograph some cats, and chat about projects both past and future.  In particular, I was really pleased that there's continued interest in building on some of the projects I've worked on at previous hack retreats.

On the way to the first hack retreat, I did some work applying [Stephen Dolan's](https://github.com/stedolan) then-experimental [American Fuzzy Lop](http://lcamtuf.coredump.cx) instrumentation to testing the [mirage-tcpip](https://github.com/mirage/mirage-tcpip) library via [mirage-net-pcap](https://github.com/yomimono/mirage-net-pcap). (A post on this was [one of the first Canopy entries!](https://canopy.mirage.io/Projects/Fuzzing)  At this hack retreat, I did a short presentation on the current state of this work:

* AFL instrumentation was released in OCaml 4.05; switches with it enabled by default are available in opam (`opam sw 4.05.0+afl`)
* [crowbar](https://github.com/stedolan/crowbar) for writing generative tests powered by AFL, with an [experimental staging branch](https://github.com/stedolan/crowbar/tree/staging) that shows OCaml code for regenerating failing test cases
* a [companion ppx_deriving](https://github.com/yomimono/ppx_deriving_crowbar) plugin for automatic generator discovery based on type definitions
* [bun](https://github.com/yomimono/ocaml-bun), for integrating afl tests into CI runs

I was lucky to have a lot of discussions about fuzzing in OCaml, some of which inspired further work and suggestions on [some current problems in Crowbar](https://github.com/stedolan/crowbar/issues/7).  (Special thanks to [gasche](https://github.com/gasche) and [armael](https://github.com/armael) for their help there!)  I'm also grateful to [aantron](https://github.com/aantron) for some discussions on ppx_bisect motivated by an attempt to estimate coverage for this testing workflow.  I was prodded into trying to get Crowbar ready to release by these conversations, and wrote a lot of docstrings and an actual README for the project.

[juga0](https://github.com/juga0) added some extensions to the [charrua-core DHCP library](https://github.com/mirage/charrua-core) started by [Christiano Haesbaert](https://github.com/haesbaert) a few hack retreats ago.  juga0 wanted to add some features to support [more anonymity for DHCP clients](https://tools.ietf.org/html/rfc7844.html), so we did some associated work on the [rawlink](https://github.com/haesbaert/rawlink) library, and added an experimental Linux DHCP client for charrua-core itself.  I got to write a lot of docstrings for this library!

I was also very excited to see the work that [cfcs](https://github.com/cfcs) has been doing on building more interesting MirageOS unikernels for use in QubesOS.  I had seen static screenshots of [mirage-framebuffer](https://github.com/cfcs/mirage-framebuffer) in action which didn't do it justice at all; seeing it in person (including self-hosted slides!) was really cool, and inspired me to think about how to fix [some ugliness in writing unikernels using the framebuffer](https://discuss.ocaml.org/t/mirageos-parametric-compilation-depending-on-target/1005/12). The [experimental password manager](https://github.com/cfcs/passmenage) is something I hope to be using by the next hack retreat.  Maybe 2017 really is [the year of unikernels on the desktop](https://mirage.io/blog/qubes-target)!

tg, hannes, halfdan, samoht, and several others (sorry if I missed you!) worked hard to get some unikernel infrastructure up and running at Priscilla, including homegrown DHCP and DNS services, self-hosted pastebin and etherpad, an FTP server for blazing-fast local filesharing, and (maybe most importantly!) a local `opam` mirror.  I hope that in future hack retreats, we can set up a local `git` server using the [OCaml git implementation](https://github.com/mirage/ocaml-git), which got some major improvements during the hack retreat thanks to dinosaure (from the other side of the world!) and samoht.

Finally, the [qubes-mirage-firewall](https://github.com/talex5/qubes-mirage-firewall) got a lot of attention this hack retreat.  (The firewall itself incorporates [some past hack retreat work](https://somerandomidiot.com/post/2017-10-09-nat-your-own-packets/) by me and talex5.)  h01ger worked on the [reproducibility of the build](http://layer-acht.org/thinking/blog/20171204-qubes-mirage-firewall/), and cfcs did some work on passing ruleset changes to the firewall -- currently, users of qubes-mirage-firewall need to rebuild the unikernel with ruleset changes.

We also uncovered some strangeness and bugs in the [handling of Xen block-storage devices](https://github.com/mirage/mirage/pull/874), which I was happy to fix in advance of the more intense use of block storage I expect with [wodan](https://github.com/g2p/wodan) and [irmin](https://github.com/mirage/irmin) in the near future.

Oh yes, and somewhere in there, I did find time to see some cats, eat tajine, wander around the medina, and enjoy all of the wonder that [Priscilla, the Queen of the Medina](http://queenofthemedina.com) and her lovely hosts have to offer.  Thanks to everyone who did the hard work of organizing, feeding, and laundering this group of itinerant hackers!

----

## Ximin Luo

This was my third MirageOS hack retreat, I continued right where I left off last time.

I've had a pet project for a while to develop a end-to-end secure protocol for group messaging. One of its themes is to completely separate the transport and application layers, by sticking an end-to-end secure session layer in between them, with the aim of unifying all the *secure messaging* protocols that exist today. Like many pet projects, I haven't had much time to work on it recently, and took the chance to this week.

I worked on implementing a consistency checker for the protocol. This allows chat members to verify everyone is seeing and has seen the same messages, and to distinguish between other members being silent (not sending anything) vs the transport layer dropping packets (either accidentally or maliciously). This is built on top of my as-yet-unreleased pure library for setting timeouts, monitors (scheduled tasks) and expectations (promises that can timeout), which I worked on in the previous hackathons.

I also wrote small libraries for doing 3-valued and 4-valued logic, useful for implementing complex control flows where one has to represent different control states like `success`, `unknown/pending`, `temporary failure`, `permanent failure`, and be able to compose these states in a logically coherent way.

For my day-to-day work I work on the [Reproducible Builds](https://reproducible-builds.org/), and as part of this we write patches and/or give advice to compilers on how to generate output deterministically. I showed Gabriel Scherer our testing framework with our results for various ocaml libraries, and we saw that the main remaining issue is that the build process embeds absolute paths into the output. I explained our `BUILD_PATH_PREFIX_MAP` mechanism for stripping this information without negatively impacting the build result, and he implemented this for the ocaml compiler. It works for findlib! Then, I need to run some wider tests to see the overall effect on all ocaml packages. Some of the non-reproducibility is due to GCC and/or GAS, and more analysis is needed to distinguish these cases.

I had very enjoyable chats with Anton Bachin about continuation-passing style, call-cc, coroutines, and lwt; and with Gabriel Scherer about formal methods, proof systems, and type systems.

For fun times I carried on the previous event's tradition of playing Cambio, teaching it to at least half of other people here who all seemed to enjoy it very much! I also organised a few mini walks to places a bit further out of the way, like Gueliz and the Henna Art Cafe.

On the almost-last day, I decided to submerge myself in the souks at 9am or so and explored it well enough to hopefully never get lost in there ever again! The existing data on OpenStreetMap for the souks is actually er, *topologically accurate* shall we say, except missing some side streets. :)

All-in-all this was another enjoyable event and it was good to be back in a place with nice weather and tasty food!

----

## Martin Keegan

My focus at the retreat was on working out how to improve the documentation.
This decomposed into

* encouraging people to fix the build for the docs system
* talking to people to find out what the current state of Mirage is
* actually writing some material and getting it merged

What I learnt was

* which backends are in practice actually usable today
* the current best example unikernels
* who can actually get stuff done
* how the central configuration machinery of ``mirage configure`` works today
* what protocols and libraries are currently at the coal-face
* that some important documentation exists in the form of blog posts

I am particularly grateful to Mindy Preston and Thomas Gazagnaire for
their assistance on documentation. I am continuing the work now that I
am back in Cambridge.

The tone and pace of the retreat was just right, for which Hannes is
due many thanks.

On the final day, I gave a brief presentation about the use of OCaml
for making part of a vote counting system, focusing on the practicalities
and cost of explaining to laymen the guarantees provided by `.mli`
interface files, with an implicit comparison to the higher cost in more
conventional programming languages.

The slides for the talk as delivered [are here](http://mk.ucant.org/media/talks/2017-12-05_OCaml-Marrakesh-STV/), but it deserves its own
blog post.

----

## Michele Orrù

This year's Marrakech experience has been been a bit less productive than
past years'. I indulged a bit more chatting to people, and pair programming with
them.

I spent some of my individual time time getting my hands dirty with the Jsonm
library, hoping that I would have been able to improve the state of my
ocaml-letsencrypt library; I also learned how to integrate ocaml API in C,
improving and updating the ocaml-scrypt library, used by another fellow mirage
user in order to develop its own password manager.
Ultimately, I'm not sure either direction I took was good: a streaming Json library is
perhaps not the best choice for an application that shares few jsons (samhot
should have been selling more his easyjson library!), and the ocaml-scrypt
library has been superseeded by the pure implementation ocaml-scrypt-kdf, which
supposedly will make the integration in mirage easier.

The overall warm atmosphere and the overall positive attitude of the
group make me still think of this experience as a positive learning experience,
and how they say: failure the best teacher is.

----

## Reynir Björnsson

For the second time this year (and ever) I went to Marrakech to participate in the MirageOS hack retreat / unconference.
I wrote about my [previous trip](http://reyn.ir/posts/2017-03-20-11-27-Marrakech%202017.html).

### The walk from the airport

Unlike the previous trip I didn't manage to meet any fellow hackers at the RAK airport.
Considering the annoying haggling taking a taxi usually involves and that the bus didn't show up last time I decided to walk the 5.3 km from the airport to Priscilla (the venue).
The walk to [Jemaa el-Fnaa](https://en.wikipedia.org/wiki/Jemaa_el-Fnaa) (AKA 'Big Square') was pretty straight forward.
Immediately after leaving the airport area I discovered every taxi driver would stop and tell me I needed a ride.
I therefore decided to walk on the opposite side of the road.
This made things more difficult because I then had more difficulties reading the road signs.
Anyway, I found my way to the square without any issues, although crossing the streets on foot requires cold blood and nerves of steel.

Once at the square I noticed a big café with lots of lights that I recognized immediately.
I went past it thinking it was Café de France.
It was not.
I spent about 30-40 minutes practicing my backtracking skills untill I finally gave up.
I went back to the square in order to call Hannes and arrange a pickup.
The two meeting points at the square was some juice stand whose number I couldn't remember and Café de France, so I went looking for the latter.
I quickly realized my mistake, and once I found the correct café the way to Priscilla was easy to remember.

All in all I don't recommend walking unless you *definitely* know the way and is not carrying 12-15 kg of luggage.

### People

Once there I met new and old friends.
Some of the old friends I had seen at [Bornhack](https://bornhack.dk) while others I hadn't seen since March.
In either case it was really nice to meet them again!
As for the new people it's amazing how close you can get with strangers in just a week.
I had some surprisingly personal conversations with people I had only met a few days prior.
Lovely people!

### My goals

Two months prior to the hack retreat I had started work on implementing the ssh-agent protocol.
I started the project because I couldn't keep up with Christiano's [awa-ssh](https://github.com/haesbaert/awa-ssh) efforts in my limited spare time, and wanted to work on something related that might help that project.
My goals were to work on my [ocaml-ssh-agent](https://github.com/reynir/ocaml-ssh-agent) implementation as well as on awa-ssh.

Before going to Marrakech I had had a stressful week at work.
I had some things to wrap up before going to a place without a good internet connection.
I therefore tried to avoid doing anything on the computer the first two days.
On the plane to Marrakech I had taken up knitting again - something I hadn't done in at least two years.
The morning of the first day I started knitting.
Eventually I had to stop knitting because I had drunk too much coffee for me to have steady enough hands to continue, so I started the laptop despite my efforts not to.
I then looked at awa-ssh, and after talking with Christiano I made the first (and sadly only) contribution to awa-ssh of that trip:
The upstream [nocrypto](https://github.com/mirleft/ocaml-nocrypto) library had been changed in a way that required changes to awa-ssh.
I rewrote the digest code to reflect the upstream changes, and refactored the code on suggestion by Christiano.

In ocaml-ssh-agent I was already using [angstrom](https://github.com/inhabitedtype/angstrom) for parsing ssh-agent messages.
I rewrote the serialization from my own brittle cstruct manipulations to using [faraday](https://github.com/inhabitedtype/faraday).
This worked great, except I never quite understood how to use the `Faraday_lwt_unix` module.
Instead I'm serializing to a string and then writing that string to the `SSH_AUTH_SOCK`.

### GADT !!!FUN!!!

The ssh-agent is a request-response protocol.
Only a certain subset of the responses are valid for each request.
I wanted to encode that relationship into the types so that the user of the library wouldn't have to deal with invalid responses.
In order to do that I got help by [@aantron](https://github.com/aantron) to implement this with GADTs.
The basic idea is a phantom type is added to the request and response types.
The phantom type, called request\_type, is a polymorphic variant that reflects the kind of requests that are possible.
Each response is parameterized with a subset of this polymorphic variant.
For example, every request can fail, so `Ssh_agent_failure` is parameterized with the whole set,
while `Ssh_agent_identities_answer` is parameterized with `` `Ssh_agent_request_identities``,
and `Ssh_agent_success` is parameterized with `` `Ssh_agent_successable`` - a collapse of all the request types that can either return success or failure.

This worked great except it broke the typing of my parser -
The compiler can't guess what the type parameter should be for the resulting `ssh_agent_response`.
To work around that [@gasche](https://github.com/gasche) helped me solve that problem by introducing an existential type:

```OCaml
    type any_ssh_agent_response = Any_response : 'a ssh_agent_response -> any_ssh_agent_response
```

Using this I could now write a function `unpack_any_response` which 'discards' every response that doesn't make sense for a particular request.
Its type is the following:

```OCaml
    val unpack_any_response : 'a ssh_agent_request -> any_ssh_agent_response ->
                              ('a ssh_agent_response, string) result
```

Now I want to write a `listen` function that takes a handler of type `'a ssh_agent_request -> 'a ssh_agent_response`, in other words a handler that can only create valid response types.
This unfortunately doesn't type check.
The parser returns an existential
`type any_ssh_agent_request = Any_request : 'req_type ssh_agent_request -> any_ssh_agent_request`.
This is causing me a problem: the `'req_type` existential would escape.
I do not know how to solve this problem, or if it's possible to solve it at all.
I discussed this issue with [@infinity0](http://github.com/infinity0) after the retreat, and we're not very optimistic.
Perhaps someone in `#ocaml` on Freenode might know a trick.

```OCaml
    let listen ((ic, oc) : in_channel * out_channel)
        (handler : 'a Ssh_agent.ssh_agent_request -> 'a Ssh_agent.ssh_agent_response) =
      match Angstrom_unix.parse Ssh_agent.Parse.ssh_agentc_message ic with
      | { len = 0; _ }, Ok (Ssh_agent.Any_request request) ->
        Ok (Ssh_agent.Any_response (handler response))
      | { len; _ }, Ok _ ->
        Error "Additional data in reply"
      | _, Error e ->
        Error e
```

### Ideas for uses of ocaml-ssh-agent

Besides the obvious use in a ssh-agent client in a ssh client, the library could be used to write an ssh-agent unikernel.
This unikernel could then be used in [Qubes OS](https://www.qubes-os.org/) in the same way as [Qubes Split SSH](https://github.com/henn/qubes-app-split-ssh) where the ssh-agent is running in a separate VM not connected to the internet.
Furthermore, [@cfcs](https://github.com/cfcs) suggested an extension could be implemented such that only identities relevant for a specific host or host key are offered by the ssh-agent.
When one connects to e.g. github.com using ssh keys all the available public keys are sent to the server.
This allows the server to do finger printing of the client since the set of keys is likely unique for that machine, and may leak information about keys irrelevant for the service (Github).
This requires a custom ssh client which may become a thing with awa-ssh soon-ish.

### Saying goodbye

Leaving such lovely people is always difficult.
The trip to the airport was emotional.
It was a chance to spend some last few moments with some of the people from the retreat knowing it was also the last chance this time around.
I will see a lot of the participants at 34c3 in 3 weeks already, while others I might not see again in the near future.
I do hope to stay in contact with most of them online!

Thank you for yet another great retreat!

----

Many thanks to everyone involved!  The hackathon is already booked for March 2018 in the same place...
