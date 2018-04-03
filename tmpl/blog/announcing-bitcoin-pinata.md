<a href="http://ownme.ipredator.se/"><img src="http://amirchaudhry.com/images/btc-pinata/btc-pinata.png" style="float:right; padding: 10px" width="300px" /></a>

Last summer we announced the beta release of a clean-slate implementation of
TLS in pure OCaml, alongside a [series of blog posts][om-tls] that described
the libraries and the thinking behind them.  It took two hackers six months
— starting on [the beach][mirleft-map] —  to get the stack to that point and
their [demo server][tls-demo] is still going strong. Since then, the team has
continued working and recently [presented][31c3] at the 31st Chaos
Communication Congress.

The authors are putting their stack to the test again and this time they've
built a **[Bitcoin Piñata][tls-pinata]**! Essentially, they've hidden a
private key to a bitcoin address within a Unikernel running on Xen. If you're
able to smash your way in, then you get to keep the spoils.

There's more context around this in my [Piñata post][ac-post] and you can see
the details on the [site itself][tls-pinata]. Remember that the codebase is
[all open][mirleft] (as well as [issues][tls-issues]) so there's nothing to
reverse engineer. Have fun!


[om-tls]: http://openmirage.org/blog/introducing-ocaml-tls
[mirleft-map]: https://goo.gl/maps/GpcQs
[tls-demo]: https://tls.nqsb.io
[31c3]: http://media.ccc.de/browse/congress/2014/31c3_-_6443_-_en_-_saal_2_-_201412271245_-_trustworthy_secure_modular_operating_system_engineering_-_hannes_-_david_kaloper.html#video
[tls-pinata]: http://ownme.ipredator.se
[ac-post]: http://amirchaudhry.com/bitcoin-pinata
[mirleft]: https://github.com/mirleft/
[tls-issues]: https://github.com/mirleft/ocaml-tls/issues?q=label%3A%22security+concern%22+
