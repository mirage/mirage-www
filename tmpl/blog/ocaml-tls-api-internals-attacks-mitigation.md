*This is the fifth in a series of posts that introduce new libraries for a pure OCaml implementation of TLS.
You might like to begin with the [introduction][tls-intro].*

[ocaml-tls][] is the new, clean-slate implementation of TLS in OCaml that we've
been working on for the past six months. In this post we try to document some of
its internal design, the reasons for the decisions we made, and
the current security status of that work.

### The OCaml-TLS architecture

The OCaml ecosystem has several distinct ways of interacting with the outside world
(and the network in particular): straightforward [unix][ocaml-unix] interfaces
and the asynchronous programming libraries [lwt][] and [async][]. One of the
early considerations was not to restrict ourselves to any of those -- we wanted
to support them all.

There were also two distinct basic "platforms" we wanted to target from the
outset: the case of a simple executable, and the case of `Mirage` unikernels.

So one of the first questions we faced was deciding how to represent
interactions with the network in a portable way. This can be done by
systematically abstracting out the API boundary which gives access to network
operations, but we had a third thing in mind as well: we wanted to exploit the
functional nature of OCaml to its fullest extent!

Our various prior experiences with Haskell and Idris convinced us to adopt
what is called "purely functional" technique. We believe it to be an approach
which first forces the programmer to give principled answers to all the
difficult design questions (errors and global data-flow) *in advance*, and then
leads to far cleaner and composable code later on. A purely functional system
has all the data paths made completely explicit in the form of function
arguments and results. There are no unaccounted-for interactions between
components mediated by shared state, and all the activity of the parts of the
system is exposed through types since, after all, it's only about computing
values from values.

For these reasons, the library is split into two parts: the directory `/lib`
(and the corresponding findlib package `tls`) contains the core TLS logic, and
`/mirage` and `/lwt` (packaged as `tls.mirage` and `tls.lwt` respectively)
contain front-ends that tie the core to `Mirage` and `Lwt_unix`.

[ocaml-unix]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html
[lwt]: http://ocsigen.org/lwt/
[async]: https://ocaml.janestreet.com/ocaml-core/111.17.00/doc/async/

### Core

The [core][tls-engine-mli] library is purely functional. A TLS session is represented by the
abstract type `Tls.Engine.state`, and various functions consume this session
type together with raw bytes (`Cstruct.t` -- which is by itself mutable, but
`ocaml-tls` eschews this) and produce new session values and resulting buffers.

The central entry point is [handle_tls][], which transforms an input state and a
buffer to an output state, a (possibly empty) buffer to send to the
communication partner, and an optional buffer of data intended to be received by
the application:

```OCaml
type state

type ret = [
  | `Ok of [ `Ok of state | `Eof | `Alert of alert ] *
      [ `Response of Cstruct.t ] * [ `Data of Cstruct.t option ]
  | `Fail of alert * [ `Response of Cstruct.t ]
]

val handle_tls : state -> Cstruct.t -> ret
```

As the signature shows, errors are signalled through the `ret` type. This
reflects the actual internal structure: all the errors are represented as
values, and operations are composed using an error [monad][monad-ml].

Other entry points share the same basic behaviour: they transform the prior
state and input bytes into the later state and output bytes.

Here's a rough outline of what happens in `handle_tls`:

TLS packets consist of a header, which contains the protocol version, length,
and content type, and the payload of the given content type. Once inside our
[main handler][handle_tls], we [separate][separate_records] the buffer into
TLS records, and [process][handle_raw_record] each individually. We first
check that the version number is correct, then [decrypt][decrypt], and [verify
the mac][verify_mac].

Decrypted data is then [dispatched][handle_packet] to one of four sub-protocol
handlers (Handshake, Change Cipher Spec, Alert and Application Data). Each
handler can [return][return_types] a new handshake state, outgoing data,
application data, the new decryption state or an error (with the outgoing data
being an interleaved list of buffers and new encryption states).

The outgoing buffers and the encryption states are [traversed][encrypt] to
produce the final output to be sent to the communication partner, and the final
encryption, decryption and handshake states are combined into a new overall
state which is returned to the caller.

Handshake is (by far) the most complex TLS sub-protocol, with an elaborate state
machine. Our [client][client_handshake] and [server][server_handshake] encode
this state as a "flat" [sum type][handshake_states], with exactly one incoming
message allowed per state. The handlers first [parse][parse_handshake] the
handshake packet (which fails in case of malformed or unknown data) and then
dispatch it to the handling function. The [handshake state][handshake_state] is
carried around and a fresh one is returned from the handler in case it needs
updates. It consists of a protocol version, the handshake state, configuration,
renegotiation data, and possibly a handshake fragment.

Logic of both handshake handlers is very localised, and does not mutate any
global data structures.

[monad-ml]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/control.ml
[return_types]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/state.ml#L109
[encrypt]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L48
[handle_packet]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L240
[verify_mac]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L85
[decrypt]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L95
[handle_tls]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L321
[handle_raw_record]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L275
[separate_records]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L150

[handshake_state]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/state.ml#L92
[parse_handshake]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/reader.ml#L361
[separate_handshakes]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.ml#L217
[handshake_states]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/state.ml#L61
[server_handshake]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/handshake_server.ml#L247
[client_handshake]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/handshake_client.ml#L285

### Core API

Our public API for the core library consists of the [Tls.Engine][tls-engine-mli]
and [Tls.Config][tls-config-mli] modules.

`Tls.Engine` contains the basic reactive function `handle_tls`, mentioned above,
which processes incoming data and optionally produces a response, together with
several operations that allow one to initiate message transfer like
`send_application_data` (which processes application-level messages for
sending), `send_close_notify` (for sending the ending message) and `reneg`
(which initiates full TLS renegotiation).

The module also contains the only two ways to obtain the initial state:

```OCaml
val client : Config.client -> (state * Cstruct.t)
val server : Config.server -> state
```

That is, one needs a configuration value to create it. The `Cstruct.t`
that `client` emits is the initial Client Hello since in TLS,
the client starts the session.

`Tls.Config` synthesizes configurations, separately for client and server
endpoints, through the functions `client_exn` and `server_exn`. They take a
number of parameters that define a TLS session, check them for consistency, and
return the sanitized `config` value which can be used to create `state`s and,
thus, sessions. If the check fails, they raise an exception.

The parameters include the pair of a certificate and its private key for the
server, and an `X509.Authenticator.t` for the client, both produced by our
[ocaml-x509][] library and described in a [previous article][x509-intro].

This design reflects our attempts to make the API as close to "fire and forget"
as we could, given the complexity of TLS: we wanted the library to be relatively
straightforward to use, have a minimal API footprint and, above all, fail very
early and very loudly when mis-configured.

[tls-engine-mli]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/engine.mli

[tls-config-mli]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/config.mli

[ocaml-x509]: https://github.com/mirleft/ocaml-x509


### Effectful front-ends

Clearly, reading and writing network data *does* change the state of the world.
Having a pure value describing the state of a TLS session is not really useful
once we write something onto the network; it is certainly not the case that we
can use more than one distinct `state` to process further data, as only one
value is in sync with the other endpoint at any given time.

Therefore we wrap the core types into stateful structures loosely inspired by
sockets and provide IO operations on those. The structures of `mirage` and `lwt`
front-ends mirror one another.

In both cases, the structure is pull-based in the sense that no processing is
done until the client requires a read, as opposed to a callback-driven design
where the client registers a callback and the library starts spinning in a
listening loop and invoking it as soon as there is data to be processed. We do
this because in an asynchronous context, it is easy to create a callback-driven
interface from a demand-driven one, but the opposite is possible only with
unbounded buffering of incoming data.

One exception to demand-driven design is the initial session creation: the
library will only yield the connection after the first handshake is over,
ensuring the invariant that it is impossible to interact with a connection if it
hasn't already been fully established.

**Mirage**

The `Mirage` [interface][tls_mirage_types_mli] matches the [FLOW][flow]
signature (with additional TLS-specific operations). We provide a functor that
needs to be applied to an underlying TCP module, to obtain a TLS transport on
top. For example:

```OCaml
module Server (Stack: STACKV4) (Entropy: ENTROPY) (KV: KV_RO) =
struct

  module TLS  = Tls_mirage.Make (Stack.TCPV4) (Entropy)
  module X509 = Tls_mirage.X509 (KV) (Clock)

  let accept conf flow =
    TLS.server_of_tcp_flow conf flow >>= function
    | `Ok tls ->
      TLS.read tls >>= function
      | `Ok buf ->
        TLS.write tls buf >> TLS.close buf

  let start stack e kv =
    TLS.attach_entropy e >>
    lwt authenticator = X509.authenticator kv `Default in
    let conf          = Tls.Config.server_exn ~authenticator () in
    Stack.listen_tcpv4 stack 4433 (accept conf) ;
    Stack.listen stack

end
```

**Lwt**

The `lwt` interface has [two layers][tls_lwt_mli]. `Tls_lwt.Unix` is loosely based
on read/write operations from `Lwt_unix` and provides in-place update of
buffers. `read`, for example, takes a `Cstruct.t` to write into and returns the
number of bytes read. The surrounding module, `Tls_lwt`, provides a simpler,
`Lwt_io`-compatible API built on top:

```OCaml
let main host port =
  Tls_lwt.rng_init () >>
  lwt authenticator = X509_lwt.authenticator (`Ca_dir nss_trusted_ca_dir) in
  lwt (ic, oc)      = Tls_lwt.connect ~authenticator (host, port) in
  let req = String.concat "\r\n" [
    "GET / HTTP/1.1" ; "Host: " ^ host ; "Connection: close" ; "" ; ""
  ] in
  Lwt_io.(write oc req >> read ic >>= print)
```

We have further plans to provide wrappers for `Async` and plain `Unix` in a
similar vein.

[tls_mirage_types_mli]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/mirage/tls_mirage_types.mli
[flow]: https://github.com/mirage/mirage/blob/ae3c966f8d726dc97208595b8005e02e39478cb1/types/V1.mli#L136
[example_unikernel]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/mirage/example/unikernel.ml
[tls_lwt_mli]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lwt/tls_lwt.mli


### Attacks on TLS

As the most used security protocol, TLS is widely deployed and it was
standardized in 1999, thus it is also quite old.  As such, many
researchers are interested in its security properties and its
flaws. Various vulnerabilities on different layers of TLS have been
found - [heartbleed][] and others are implementation specific,
advancements in cryptoanalysis such as [collisions of
MD5][md5_collision] lead to vulnerabilities, and even others are due
to incorrect usage of TLS ([truncation attack][truncation] or
[BREACH][breach]). Finally, some weaknesses are in the protocol
itself. Extensive [overviews][tls_attacks] of [attacks on
TLS][mitls_attacks] are available.

We look at protocol level attacks of TLS and how [ocaml-tls][ocaml-tls]
implements mitigations against these.  [TLS 1.2 RFC][RFC5246] provides an
overview of attacks and mitigations, and we [track][issue31] our progress in
covering them. This is slightly out of date as the RFC is roughly six years old and
in the meantime more attacks have been published, such as the [renegotiation
flaw][understanding_reneg].

As [already mentioned][tls-intro], we track all our
[mitigated][closed] and [open][open] security issues on our GitHub
issue tracker.

Due to the choice of using OCaml, a memory managed programming
language, we obstruct entire bug classes, namely temporal and spatial
memory safety.

Cryptoanalysis and improvement of computational power weaken some
ciphers, such as RC4 and 3DES (see [issue 8][issue8] and [issue
10][issue10]). If we phase these two ciphers out, there wouldn't be
any ciphersuite left to communicate with some compliant TLS-1.0
implementations.

[issue8]: https://github.com/mirleft/ocaml-tls/issues/8
[issue10]: https://github.com/mirleft/ocaml-tls/issues/10
[open]: https://github.com/mirleft/ocaml-tls/issues?labels=security+concern&page=1&state=open
[closed]: https://github.com/mirleft/ocaml-tls/issues?labels=security+concern&page=1&state=closed
[ocaml-tls]: https://github.com/mirleft/ocaml-tls
[understanding_reneg]: http://www.educatedguesswork.org/2009/11/understanding_the_tls_renegoti.html
[heartbleed]: https://en.wikipedia.org/wiki/Heartbleed
[md5_collision]: http://eprint.iacr.org/2005/067
[truncation]: http://www.theregister.co.uk/2013/08/01/gmail_hotmail_hijacking/
[breach]: http://breachattack.com/
[RFC5246]: https://tools.ietf.org/html/rfc5246#appendix-D.4
[tls_attacks]: http://eprint.iacr.org/2013/049.pdf
[mitls_attacks]: http://www.mitls.org/wsgi/tls-attacks
[issue31]: https://github.com/mirleft/ocaml-tls/issues/31

**Timing attacks**

When the timing characteristics between the common case and the error
case are different, this might potentially leak confidential
information. Timing is a very prominent side-channel and there are a huge
variety of timing attacks on different layers, which are observable by
different attackers. Small differences in timing behaviour might
initially be exploitable only by a local attacker, but advancements to
the attack (e.g. increasing the number of tests) might allow a 
remote attacker to filter the noise and exploit the different timing
behaviour.

**Timing of cryptographic primitives**

We [already mentioned][nocrypto-intro] [cache][] [timing][cache_timing]
attacks on our AES implementation, and that we use [blinding][]
techniques to mitigate RSA timing attacks.

By using a memory managed programming language, we open the attack
vector of garbage collector (GC) timing attacks (also mentioned [in
our nocrypto introduction][nocrypto-intro]).

Furthermore, research has been done on virtual machine side channels
([l3][], [cross vm][cross_vm] and [cache timing][cache_vm]), which we
will need to study and mitigate appropriately.

**For the time being we suggest to not use the stack on a multi-tenant
shared host or on a shared host which malicious users might have
access to.**

[blinding]: https://en.wikipedia.org/wiki/Blinding_(cryptography)
[cache]: http://www.cs.tau.ac.il/~tromer/papers/cache.pdf
[cache_timing]: http://cr.yp.to/antiforgery/cachetiming-20050414.pdf
[l3]: http://eprint.iacr.org/2013/448.pdf
[cross_vm]: http://www.cs.unc.edu/~reiter/papers/2012/CCS.pdf
[cache_vm]: http://fc12.ifca.ai/pre-proceedings/paper_70.pdf

**Bleichenbacher**

In 1998, Daniel Bleichenbacher discovered a [timing flaw in the
PKCS1][bleichenbacher] encoding of the premaster secret: the TLS server
failed faster when the padding was wrong than when the decryption
failed. Using this timing, an attacker can run an adaptive chosen
ciphertext attack and find out the plain text of a PKCS1 encrypted
message. In TLS, when RSA is used as the key exchange method, this
leads to discovery of the premaster secret, which is used to derive the
keys for the current session.

The mitigation is to have both padding and decryption failures use the
exact same amount of time, thus there should not be any data-dependent
branches or different memory access patterns in the code. We
implemented this mitigation in [Handshake_server][answer_client_key_exchange].

[bleichenbacher]: http://archiv.infsec.ethz.ch/education/fs08/secsem/Bleichenbacher98.pdf
[answer_client_key_exchange]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/handshake_server.ml#L45

**Padding oracle and CBC timing**

[Vaudenay][] discovered a vulnerability involving block ciphers: if an
attacker can distinguish between bad mac and bad padding, recovery of
the plaintext is possible (within an adaptive chosen ciphertext
attack). Another approach using the same issue is to use
[timing][practical] information instead of separate error messages.
Further details are described [here][tls_cbc].

The countermeasure, which we implement [here][cbc_mit], is to continue
with the mac computation even though the padding is
incorrect. Furthermore, we send the same alert (`bad_record_mac`)
independent of whether the padding is malformed or the mac is
incorrect.

[tls_cbc]: https://www.openssl.org/~bodo/tls-cbc.txt
[Vaudenay]: http://www.iacr.org/archive/eurocrypt2002/23320530/cbc02_e02d.pdf
[practical]: http://lasecwww.epfl.ch/memo/memo_ssl.shtml
[cbc_mit]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/engine.ml#L100

**Lucky 13**

An advancement of the CBC timing attack was discovered in 2013, named
[Lucky 13][Lucky13]. Due to the fact that the mac is computed over the
plaintext without padding, there is a slight (but measurable)
difference in timing between computing the mac of the plaintext and
computing the fake mac of the ciphertext. This leaks information. We
do not have proper mitigation against Lucky 13 in place yet.  You can
find further discussion in [issue 7][issue7] and [pull request
49][pull49].

[Lucky13]: http://www.isg.rhul.ac.uk/tls/Lucky13.html
[issue7]: https://github.com/mirleft/ocaml-tls/issues/7
[pull49]: https://github.com/mirleft/ocaml-tls/pull/49

**Renegotiation not authenticated**

In 2009, Marsh Ray published a vulnerability of the TLS protocol which
lets an attacker prepend arbitrary data to a session due to
[unauthenticated renegotiation][understanding_reneg]. The attack
exploits the fact that a renegotiation of ciphers and key material is
possible within a session, and this renegotiated handshake is not
authenticated by the previous handshake. A man in the middle can
initiate a session with a server, send some data, and hand over the
session to a client. Neither the client nor the server can detect the
man in the middle.

A fix for this issue is the [secure renegotiation extension][RFC5746],
which embeds authenticated data of the previous handshake into the
client and server hello messages. Now, if a man in the middle
initiates a renegotiation, the server will not complete it due to
missing authentication data (the client believes this is the first
handshake).

We implement and require the secure renegotiation extension by
default, but it is possible to configure `ocaml-tls` to not require
it -- to be able to communicate with servers and
clients which do not support this extension.

Implementation of the mitigation is on the server side in
[ensure_reneg][] and on the client side in [validate_reneg][]. The
data required for the secure renegotiation is stored in
[`handshake_state`][reneg_state] while sending and receiving Finished
messages. You can find further discussion in [issue 3][issue3].

[RFC5746]: https://tools.ietf.org/html/rfc5746
[validate_reneg]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/handshake_client.ml#L50
[ensure_reneg]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/handshake_server.ml#L85
[issue3]: https://github.com/mirleft/ocaml-tls/issues/3
[reneg_state]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/state.ml#L97

**TLS 1.0 and known-plaintext (BEAST)**

TLS 1.0 reuses the last ciphertext block as IV in CBC mode. If an attacker
has a (partially) known plaintext, she can find the remaining plaintext.
This is known as the [BEAST][] attack and there is a [long discussion][mozilla-bug]
about mitigations. Our mitigation is to prepend each TLS-1.0
application data fragment with an empty fragment to randomize the IV.
We do this exactly [here][empty_iv]. There is further discussion in
[issue 2][issue2].

Our mitigation is slightly different from the 1/n-1 splitting proposed
[here][qualys]: we split every application data frame into a 0 byte
and n byte frame, whereas they split into a 1 byte and a n-1 byte
frame.

Researchers have exploited this vulnerability in 2011, although it was
known since [2006][]. TLS versions 1.1 and 1.2 use an explicit IV,
instead of reusing the last cipher block on the wire.

[qualys]: https://community.qualys.com/blogs/securitylabs/2013/09/10/is-beast-still-a-threat
[mozilla-bug]: https://bugzilla.mozilla.org/show_bug.cgi?id=665814
[BEAST]: http://vnhacker.blogspot.co.uk/2011/09/beast.html
[empty_iv]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/engine.ml#L375
[2006]: http://eprint.iacr.org/2006/136
[issue2]: https://github.com/mirleft/ocaml-tls/issues/2

**Compression and information leakage (CRIME)**

When using compression on a chosen-plaintext, encrypting this can leak
information, known as [CRIME][crime]. [BREACH][breach] furthermore
exploits application layer compression, such as HTTP compression. We
mitigate CRIME by not providing any TLS compression support, while we
cannot do anything to mitigate BREACH.

[crime]: http://arstechnica.com/security/2012/09/crime-hijacks-https-sessions/

**Traffic analysis**

Due to limited amount of padding data, the actual size of transmitted
data can be recovered. The mitigation is to implement [length hiding
policies][length_hiding]. This is tracked as [issue 162][issue162].

[issue162]: https://github.com/mirleft/ocaml-tls/issues/162
[length_hiding]: http://tools.ietf.org/html/draft-pironti-tls-length-hiding-02

**Version rollback**

SSL-2.0 is insecure, a man in the middle can downgrade the version to
SSL-2.0. The mitigation we implement is that we do not support
SSL-2.0, and thus cannot be downgraded. Also, we check that the
version of the client hello matches the first two bytes in the
premaster secret [here][client_version]. You can find further discussion in
[issue 5][issue5].

[client_version]: https://github.com/mirleft/ocaml-tls/blob/c06cbaaffe49024d8570916b70f7839603a54692/lib/handshake_server.ml#L55
[issue5]: https://github.com/mirleft/ocaml-tls/issues/5

**Triple handshake**

A vulnerability including session resumption and renegotiation was
discovered by the [miTLS team][mitls], named [triple
handshake][triple].  Mitigations include disallowing renegotiation,
disallowing modification of the certificate during renegotiation, or
a hello extension. Since we do not support session resumption yet, we
have not yet implemented any of the mentioned mitigations. There is
further discussion in [issue 9][issue9].

[mitls]: http://www.mitls.org
[issue9]: https://github.com/mirleft/ocaml-tls/issues/9
[triple]: https://secure-resumption.com/

**Alert attack**

A [fragment of an alert][alert_attack] can be sent by a man in the
middle during the initial handshake. If the fragment is not cleared
once the handshake is finished, the authentication of alerts is
broken. This was discovered in 2012; our mitigation is to discard
fragmented alerts.

[alert_attack]: http://www.mitls.org/wsgi/alert-attack

### EOF.

Within six months, two hackers managed to develop a clean-slate TLS
stack, together with required crypto primitives, ASN.1, and X.509
handling, in a high-level pure language. We interoperate
with widely deployed TLS stacks, as shown by our [demo server][demo].
The code size is nearly two orders of magnitude smaller than OpenSSL,
the most widely used open source library (written in C, which a lot of
programming languages wrap instead of providing their own TLS
implementation). Our code base seems to be robust -- the [demo
server][demo] was hit by hacker news.

There is a huge need for high quality TLS implementations, because
several TLS implementations suffered this year from severe security
problems, such as [heartbleed][], [goto fail][CVE-2014-1266], [session
id][CVE-2014-3466], [Bleichenbacher][java], [change cipher
suite][CVE-2014-0224] and [GCM DoS][polar]. The main cause is
implementation complexity due to lack of abstraction, and memory
safety issues.

We still need to address some security issues, and improve our performance. We
invite people to do rigorous code audits (both manual and automated) and try
testing our code in their services.

**Please be aware that this release is a *beta* and is missing external code audits.
It is not yet intended for use in any security critical applications.**

[demo]: https://tls.openmirage.org
[polar]: https://polarssl.org/tech-updates/security-advisories/polarssl-security-advisory-2014-02
[java]: http://armoredbarista.blogspot.de/2014/04/easter-hack-even-more-critical-bugs-in.html
[CVE-2014-1266]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-1266
[CVE-2014-3466]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-3466
[CVE-2014-0224]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-0224

****

Posts in this TLS series:

 - [Introducing transport layer security (TLS) in pure OCaml][tls-intro]
 - [OCaml-TLS: building the nocrypto library core][nocrypto-intro]
 - [OCaml-TLS: adventures in X.509 certificate parsing and validation][x509-intro]
 - [OCaml-TLS: ASN.1 and notation embedding][asn1-intro]
 - [OCaml-TLS: Discussion of API, known attacks and our mitigations][tls-api]

[tls-intro]: http://openmirage.org/blog/introducing-ocaml-tls
[nocrypto-intro]: http://openmirage.org/blog/introducing-nocrypto
[x509-intro]: http://openmirage.org/blog/introducing-x509
[asn1-intro]: http://openmirage.org/blog/introducing-asn1
[tls-api]: http://openmirage.org/blog/ocaml-tls-api-internals-attacks-mitigation
