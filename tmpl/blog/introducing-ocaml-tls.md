We announce a **beta** release of `ocaml-tls`, a clean-slate implementation of
[Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security) (TLS) in
OCaml.

### What is TLS?

Transport Layer Security (TLS) is probably the most widely deployed
security protocol on the Internet. It provides communication privacy
to prevent eavesdropping, tampering, and message forgery. Furthermore,
it optionally provides authentication of the involved endpoints. TLS
is commonly deployed for securing web services ([HTTPS](http://tools.ietf.org/html/rfc2818)), emails,
virtual private networks, and wireless networks.

TLS uses asymmetric cryptography to exchange a symmetric key, and
optionally authenticate (using X.509) either or both endpoints. It
provides algorithmic agility, which means that the key exchange
method, symmetric encryption algorithm, and hash algorithm are
negotiated.

### TLS in OCaml

Our implementation [ocaml-tls](https://github.com/mirleft/ocaml-tls) is already able to interoperate with
existing TLS implementations, and supports several important TLS extensions
such as server name indication ([RFC4366][], enabling virtual hosting)
and secure renegotiation ([RFC5746][]).

Our [demonstration server][^7] runs `ocaml-tls` and renders exchanged
TLS messages in nearly real time by receiving a trace of the TLS
session setup. If you encounter any problems, please give us [feedback][^14].

`ocaml-tls` and all dependent libraries are available via [OPAM][^18] (`opam install tls`). The [source is available][^1]
under a BSD license. We are primarily working towards completeness of
protocol features, such as client authentication, session resumption, elliptic curve and GCM
cipher suites, and have not yet optimised for performance.

`ocaml-tls` depends on the following independent libraries: [ocaml-nocrypto][^6] implements the
cryptographic primitives, [ocaml-asn1-combinators][^5] provides ASN.1 parsers/unparsers, and
[ocaml-x509][^8] implements the X509 grammar and certificate validation ([RFC5280][]). [ocaml-tls][^1] implements TLS (1.0, 1.1 and 1.2; [RFC2246][],
[RFC4346][], [RFC5246][]).

We invite the community to audit and run our code, and we are particularly interested in discussion of our APIs.
Please use the [mirage-devel mailing list][^9] for discussions.

**Please be aware that this release is a *beta* and is missing external code audits.
It is not yet intended for use in any security critical applications.**

In our [issue tracker][^14] we transparently document known attacks against TLS and our mitigations
([checked][^4] and [unchecked][^11]).
We have not yet implemented mitigations against either the
[Lucky13][^12] timing attack or traffic analysis (e.g. [length-hiding padding][^13]).

### Trusted code base

Designed to run on Mirage, the trusted code base of `ocaml-tls` is small. It includes the libraries already mentioned,
[`ocaml-tls`][^1], [`ocaml-asn-combinators`][^5], [`ocaml-x509`][^8],
and [`ocaml-nocrypto`][^6] (which uses C implementations of block
ciphers and hash algorithms). For arbitrary precision integers needed in 
asymmetric cryptography, we rely on [`zarith`][^15], which wraps
[`libgmp`][^16]. As underlying byte array structure we use
[`cstruct`][^17] (which uses OCaml `Bigarray` as storage).

We should also mention the OCaml runtime, the OCaml compiler, the
operating system on which the source is compiled and the binary is executed, as
well as the underlying hardware. Two effectful frontends for
the pure TLS core are implemented, dealing
with side-effects such as reading and writing from the network: [Lwt_unix](http://ocsigen.org/lwt/api/Lwt_unix) and
Mirage, so applications can run directly as a Xen unikernel.

### Why a new TLS implementation?

**Update:**
Thanks to [Frama-C][frama-c] guys for [pointing][twitter-1] [out][twitter-2]
that [CVE-2014-1266][] and [CVE-2014-0224][] are *not* memory safety issues, but
logic errors. This article previously stated otherwise.

[frama-c]: http://frama-c.com/
[twitter-1]: https://twitter.com/spun_off/status/486535304426188800
[twitter-2]: https://twitter.com/spun_off/status/486536572792090626

There are only a few TLS implementations publicly available and most
programming languages bind to OpenSSL, an open source implementation written
in C. There are valid reasons to interface with an existing TLS library,
rather than developing one from scratch, including protocol complexity and
compatibility with different TLS versions and implementations. But from our
perspective the disadvantage of most existing libraries is that they
are written in C, leading to:

  * Memory safety issues, as recently observed by [Heartbleed][] and GnuTLS
    session identifier memory corruption ([CVE-2014-3466][]) bugs;
  * Control flow complexity (Apple's goto fail, [CVE-2014-1266][]);
  * And difficulty in encoding state machines (OpenSSL change cipher suite
    attack, [CVE-2014-0224][]).

Our main reasons for `ocaml-tls` are that OCaml is a modern functional
language, which allows concise and declarative descriptions of the
complex protocol logic and provides type safety and memory safety to help
guard against programming errors. Its functional nature is extensively
employed in our code: the core of the protocol is written in purely
functional style, without any side effects.

Subsequent blog posts [over the coming
days](https://github.com/mirage/mirage/issues/257) will examine in more detail
the design and implementation of the four libraries, as well as the security
trade-offs and some TLS attacks and our mitigations against them.  For now
though, we invite you to try out our **[demonstration server][^7]**
running our stack over HTTPS.  We're particularly interested in feedback on our [issue tracker](https://github.com/mirleft/ocaml-tls) about
clients that fail to connect, and any queries from anyone reviewing the [source code](https://github.com/mirleft/)
of the constituent libraries. 

[^1]: https://github.com/mirleft/ocaml-tls
[^3]: http://www.openbsd.org/papers/bsdcan14-libressl/mgp00026.html)
[^4]: https://github.com/mirleft/ocaml-tls/issues?labels=security+concern&page=1&state=open
[^5]: https://github.com/mirleft/ocaml-asn1-combinators
[^6]: https://github.com/mirleft/ocaml-nocrypto
[^7]: https://tls.openmirage.org/
[^8]: https://github.com/mirleft/ocaml-x509
[^9]: http://lists.xenproject.org/archives/html/mirageos-devel/
[^10]: https://github.com/mirage/mirage-entropy
[^11]: https://github.com/mirleft/ocaml-tls/issues?labels=security+concern&page=1&state=closed
[^12]: http://www.isg.rhul.ac.uk/tls/Lucky13.html
[^13]: http://tools.ietf.org/html/draft-pironti-tls-length-hiding-02
[^14]: https://github.com/mirleft/ocaml-tls/issues
[^15]: https://forge.ocamlcore.org/projects/zarith
[^16]: https://gmplib.org/
[^17]: https://github.com/mirage/ocaml-cstruct
[^18]: https://opam.ocaml.org/packages/tls/tls.0.1.0/

[attacks]: http://eprint.iacr.org/2013/049
[Heartbleed]: https://en.wikipedia.org/wiki/Heartbleed
[mostdangerous]: https://crypto.stanford.edu/~dabo/pubs/abstracts/ssl-client-bugs.html
[frankencert]: https://www.cs.utexas.edu/~shmat/shmat_oak14.pdf
[mitls]: http://www.mitls.org
[Fortuna]: https://www.schneier.com/fortuna.html
[HOL]: http://www.infsec.ethz.ch/people/andreloc/publications/lochbihler14iw.pdf
[cheap]: http://people.cs.missouri.edu/~harrisonwl/drafts/CheapThreads.pdf
[RFC4366]: https://tools.ietf.org/html/rfc4366
[RFC5746]: https://tools.ietf.org/html/rfc5746
[RFC5280]: https://tools.ietf.org/html/rfc5280
[RFC2246]: https://tools.ietf.org/html/rfc2246
[RFC4346]: https://tools.ietf.org/html/rfc4346
[RFC5246]: https://tools.ietf.org/html/rfc5246
[CVE-2014-1266]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-1266
[CVE-2014-3466]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-3466
[CVE-2014-0224]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-0224


****

Posts in this TLS series:
 
 - [Introducing transport layer security (TLS) in pure OCaml][tls-intro]
 - [OCaml-TLS: building the nocrypto library core][nocrypto-intro]
 - [OCaml-TLS: adventures in X.509 certificate parsing and validation][x509-intro]
 - [OCaml-TLS: ASN.1 and notation embedding][asn1-intro]
 - [OCaml-TLS: architecture of OCaml-TLS and mitigations to known attacks][tls-api]

[tls-intro]: http://openmirage.org/blog/introducing-ocaml-tls
[nocrypto-intro]: http://openmirage.org/blog/introducing-nocrypto
[x509-intro]: http://openmirage.org/blog/introducing-x509
[asn1-intro]: http://openmirage.org/blog/introducing-asn1
[tls-api]: http://openmirage.org/blog/ocaml-tls-api-internals-attacks-mitigation
