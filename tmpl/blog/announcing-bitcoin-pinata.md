Last summer we announced the beta release of a clean-slate implementation of
TLS in pure OCaml, alongside a [series of blog posts][om-tls] that described
the libraries and the thinking behind them.  It took two hackers six months
— starting on [the beach][mirleft-map] —  to get the stack to that point and
their [demo server][tls-demo] is still going strong. Since then, the team has
continued working and recently [presented][31c3] at the 31st Chaos
Communication Congress.

The latest example goes quite a bit further than a server that just displays
the handshake. This time, the team have constructed a Xen unikernel that's
holding a private key to a bitcoin address and are asking people to try and
*break in*. Hence, they've called it the **[Bitcoin Piñata][tls-pinata]**!\*

## What the Bitcoin Piñata does

[![Bitcoin Pinata](http://amirchaudhry.com/images/btc-pinata/btc-pinata.png)](http://ownme.ipredator.se)

The Piñata unikernel will transmit its private bitcoin key if you can
successfully set up a TLS connection **but** it's rigged so that it will *only*
create that connection if you can present the certificate it's expecting to
see — which has been *signed appropriately*.  Of course, you're not being given
the secret key with which to do that signing and that means there should be
*no way* for anyone to form a TLS connection with the Piñata.
In order to get the private key to the bitcoin address, you'll have to smash
your way in.

Helpfully (perhaps), things are set up so that you *can* make the Piñata talk
to itself, allowing you to [eavesdrop][mitm] on a successful connection and
see the encrypted traffic. In addition, all the [code and libraries][repo] are
open-source so you can look through any of the codebase.  There isn't anything
that anyone will have to reverse engineer, which should make this a little
more enjoyable.

This contest is set to run until mid-March or whenever the coins are taken.
If someone does manage to get in, please do let us know how!


### The Rubber-hose approach

Of course there are many other ways to get at the private key and as many
people like to comment, the human element is sometimes the weakest link — 
after all, a safe is only as secure as the person with the combination.

In this case, there is obviously a secret key or certificate *somewhere*
that could be presented so it may be tempting to go hunting for that. Perhaps
phishing attempts on the authors may yield a way forward, or maybe just
straight-forward [Rubber-hose cryptanalysis][rubber-hose]!  Sure, these
options might provide a result<sup>&dagger;</sup> but this is meant to be fun.
The authors haven't specified any rules but please be nice and focus on the
technical things around the Piñata. Don't be this guy.

![Pinata-kid-bat](http://amirchaudhry.com/images/btc-pinata/pinata-kid-bat.gif)


## What's the point of this contest?

Even though the Bitcoin Piñata is clearly a contest, nobody is deluding
themselves into thinking that if the coins are still there in March, that
somehow the stack can be declared 'undefeated' — while pleasing, that
result wouldn't necessarily *prove* anything. Contests have their place but as
Bruce Schneier [already pointed out][schneier], they are not useful mechanisms
to judge security.

However, it does give us the chance to engage in some shameless self-promotion
and try to draw vast amounts of attention to the work. That, and the chance to
stress-test the stack in the wild. Ultimately, we *want* to use this code in
production but must take a lot of care to get there and want to be sure that
it can bear up. This is just one more way of learning what happens when
putting something 'real' out there. 

If the Bitcoins *do* end up being taken, then there's *definitely* something
valuable that the team can learn from that. Regardless of the Piñata, if we
have more people exploring the [TLS codebase][mirleft] or trying it out for
themselves, it will undoubtedly be A Good Thing. 

##### Responsible sidenote

*For clarity and to avoid any doubt, please be aware that the TLS codebase is
missing external code audits and is not yet intended for use in any security
critical applications.  All development is done in the open, including the
tracking of [security-related issues][tls-issues], so please do consider
auditing the code, testing it in your services and reporting issues.*

****

<p class="small">* If you've never come across a piñata before, hopefully 
    the gif in the post gives you an idea.  If not, the
    <a href="https://en.wikipedia.org/wiki/Pinata">wiki page</a>
    will surely help, where I learned that the origin may be Chinese rather
    than Spanish!
</p>

<p class="small"><sup>&dagger;</sup> Of course, I'm not suggesting that
    anyone would actually go this far. I'm simply acknowledging that there is
    a human factor and asking that we put it aside.
</p>


[mirleft-map]: https://goo.gl/maps/GpcQs
[om-tls]: http://openmirage.org/blog/introducing-ocaml-tls
[tls-demo]: https://tls.openmirage.org
[tls-issues]: https://github.com/mirleft/ocaml-tls/issues?q=label%3A%22security+concern%22+
[31c3]: http://media.ccc.de/browse/congress/2014/31c3_-_6443_-_en_-_saal_2_-_201412271245_-_trustworthy_secure_modular_operating_system_engineering_-_hannes_-_david_kaloper.html#video
[mitm]: http://en.wikipedia.org/wiki/Man-in-the-middle_attack
[tls-pinata]: http://ownme.ipredator.se
[wiki]: https://en.wikipedia.org/wiki/Piñata
[repo]: https://github.com/mirleft/btc-pinata
[rubber-hose]: http://en.wikipedia.org/wiki/Rubber-hose_cryptanalysis
[schneier]: https://www.schneier.com/crypto-gram/archives/1998/1215.html#contests
[mirleft]: https://github.com/mirleft/
