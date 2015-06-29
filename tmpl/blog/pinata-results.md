TL;DR: Nobody took our BTC.  Random people from the Internet even donated
into our BTC wallet.
We showed the feasibility of a
transparent self-service bounty.  In the style of Dijkstra: security
bounties can be a very effective way to show the presence of
vulnerabilities, but they are hopelessly inadequate for showing their
absence.

#### What are you talking about?

Earlier this year, we [released a Bitcoin Piñata](https://mirage.io/blog/announcing-bitcoin-pinata).
The [Piñata](http://ownme.ipredator.se) was a security bounty
containing 10 BTC and it's been online since 10th February 2015.
Upon successful
mutual authentication, where the Piñata has only a single trust anchor, it sends the
private key to the Bitcoin address.

[It is open source](https://github.com/mirleft/btc-pinata),
and exposes both the client and server side of
[ocaml-tls](https://github.com/mirleft/ocaml-tls), running as an 8.2MB
[MirageOS](http://openmirage.org) unikernel.  You can see the [code manifest](https://github.com/mirleft/btc-pinata/blob/master/opam-full.txt) to find out which libraries are involved.  We put this online and invited people to attack it.

Any approach was permitted in attacking the Piñata:
the host system, the MirageOS [TCP/IP
stack](https://github.com/mirage/mirage-tcpip), our TLS,
X.509 and ASN.1 implementations, as well as the Piñata code.
A successful attacker could do whatever they want with the BTC, no
questions asked (though we would [notice the transaction](https://blockchain.info/address/183XuXTTgnfYfKcHbJ4sZeF46a49Fnihdh)).

The exposed server could even be short-circuited to the exposed
client: you could proxy a TLS connection in which the (encrypted!)
secret was transmitted via your machine.

This post summarises what we've seen so far and what we've learned about attempts people have made to take the BTC.

#### Accesses

There were 50,000 unique IP addresses who accessed the website.
1000 unique IP addresses initiated more than 20,000 TLS
connections to the Piñata, trying to break it.  Cumulative numbers of
the HTTP and TLS accesses are shown in the diagram:

<img src="/graphics/pinata_access.png" alt="Cumulative Piñata accesses" />

There were more than 9000 failing and 12000 successful TLS sessions,
comprised of short-circuits described earlier, and our own tests.

No X.509 certificate was presented in 1200 of the failed TLS
connections.  Another 1000 failed due to invalid input as the first
bytes.  This includes attempts using telnet — I'm looking at you,
xx.xxx.74.126 `please give key` (on 10th February at 16:00) and
xx.xxx.166.143 `hi give me teh btcs` (on 11th February at 05:57)!

#### We are not talking to everybody

Our implementation first parses the record version of a client hello,
and if it fails, an unknown record version is reported.  This happened
in 10% of all TLS connections (including the 1000 with invalid input in the
last section).

Another big class, 6%, were attempted Heartbeat packets (popular due
to [Heartbleed](https://en.wikipedia.org/wiki/Heartbleed)), which we
do not implement.

Recently, issues in the state machines of TLS implementations were
published in [smacktls](http://smacktls.com) (and [CCS
injection](http://ccsinjection.lepidum.co.jp/)).  3% of the Piñata connections
received an unexpected handshake record at some point, which the Piñata handled
correctly by shutting down the connection.

In 2009, the [renegotiation
attack](https://en.wikipedia.org/wiki/Transport_Layer_Security#Renegotiation_attack)
on the TLS protocol was published, which allowed a person in the
middle to inject prefix bytes, because a renegotiated handshake was
not authenticated with data from the previous handshake.  OCaml-TLS
closes a connection if the [renegotiation
extension](https://tools.ietf.org/html/rfc5746) is not present, which
happened in 2% of the connections.
Another 2% did not propose a ciphersuite supported by OCaml-TLS; yet
another 2% tried to talk SSL version 3 with us, which we do not
implement (for [good reasons](https://tools.ietf.org/html/rfc7568), such as
[POODLE](https://www.us-cert.gov/ncas/alerts/TA14-290A)).

In various other (old versions of) TLS implementations, these
connections would have been successful and insecure!

#### Attempts worth noting

Interesting failures were: 31 connections which sent too many or too
few bytes, leading to parse errors.

TLS requires each communication partner who authenticates themselves to
present a certificate.  To prove ownership of the private key of the
certificate, a hash of the concatenated handshake records needs to be
signed and transmitted over the wire.  22 of our TLS traces had
invalid signatures.  Not verifying such signatures was the problem of Apple's famous [goto
fail](https://www.imperialviolet.org/2014/02/22/applebug.html).

Another 100 failure traces tested our X.509 validation:
The majority of these failures (58) sent us certificates which were not signed by our trust
anchor, such as `CN=hacker/emailAddress=hacker@hacker` and `CN=Google
Internal SNAX Authority` and various Apple and Google IDs -- we're still trying to figure out what SNAX is, Systems Network Architecture maybe?

Several certificates contained invalid X.509 extensions: we require
that a server certificate does not contain the `BasicConstraints =
true` extension, which marks this certificate as certificate
authority, allowing to sign other certificates.  While not explicitly
forbidden, best practices (e.g. from
[Mozilla](https://wiki.mozilla.org/SecurityEngineering/mozpkix-testing#Behavior_Changes))
reject them.  Any sensible systems administrator would not accept a CA
as a server certificate.

Several other certificates were self-signed or contained an invalid
signature: one certificate was our client certificate, but with a
different RSA public key, thus the signature on the certificate was
invalid; another one had a different RSA public key, and the signature
was zeroed out.

Some certificates were not of X.509 version 3, or were expired.
Several certificate chains were not pairwise signed, a [common attack
vector](https://crypto.stanford.edu/~dabo/pubs/abstracts/ssl-client-bugs.html).

Two traces contained certificate structures which our ASN.1 parser
rejected.

Another two connections (both initiated by ourselves) threw an
exception which lead to [shutdown of the connection](https://github.com/mirleft/btc-pinata/blob/master/logger.ml#L116): there
[was](https://github.com/mirleft/ocaml-tls/commit/80117871679d57dde8c8e3b73392024ef4b42c38)
an out-of-bounds access while parsing handshake records.  This did not
lead to arbitrary code execution.

#### Conclusion

The BTC Piñata was the first transparent self-service bounty, and it
was a success: people showed interest in the topic; some even donated
BTC; we enjoyed setting it up and running it; we fixed a non-critical
out of bounds access in our implementation; a large fraction of our
stack has been covered by the recorded traces.

There are several points to improve a future Piñata: attestation that the code
running is the open sourced code, attestation that the service owns
the private key (maybe by doing transactions or signatures with input
from any user).

There are several applications using OCaml-TLS, using MirageOS as well
as Unix:

- [mirage-seal](https://github.com/mirage/mirage-seal) compiles to
a unikernel container which serves a given directory over https;
- [tlstunnel](https://github.com/hannesm/tlstunnel) is a
([stud](https://github.com/bumptech/stud) like) TLS proxy, forwarding
to a backend server;
- [jackline](https://github.com/hannesm/jackline) is a
(alpha version) terminal-based XMPP client;
- [conduit](https://github.com/mirage/ocaml-conduit) is an abstraction
over network connections -- to make it use OCaml-TLS, set
`CONDUIT_TLS=native`.

Again, a big thank you to [IPredator](https://ipredator.se) for
hosting our BTC Piñata and lending us the BTC!
