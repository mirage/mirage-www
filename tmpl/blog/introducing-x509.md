*This is the third in a series of posts that introduce new libraries for a pure OCaml implementation of TLS.
You might like to begin with the [introduction][tls-intro].*

### The problem of authentication

When establishing a secure connection to a remote server, often the
authenticity of the remote server should be verified. Otherwise an
attacker ([MITM][^0]) between the client and the server can eavesdrop on
the transmitted data. To the best of our knowledge, authentication
cannot be done solely in-band, but needs external
infrastructure. Various methods are used in practice, which rely on
public key encryption.

*Web of trust* (used by [OpenPGP][^1]) is a decentralised public key
infrastructure. It relies on out-of-band verification of public keys
and transitivity of trust. If Alice signed Bob's public key, and
Charlie trusts Bob (and signed his public key), then Charlie can trust
that Alice's public key is hers.

*Public key infrastructure* (used by [TLS][^2]) relies on trust
anchors which are communicated out-of-band (e.g. distributed with the
client software). In order to authenticate a server, a chain of trust
between a trust anchor and the server certificate (public key) is
established. Only those clients which have the trust anchor deployed
can verify the authenticity of the server.

### X.509 public key infrastructure

[X.509][^3] is an ITU standard for a public key infrastructure,
developed in 1988. Amongst other things, it specifies the format of
certificates, their attributes, revocation lists, and a path
validation algorithm. X.509 certificates are encoded using abstract
syntax notation one (ASN.1).

A *certificate* contains a public key, a subject (server name), a
validity period, a purpose (i.e. key usage), an issuer, and
possibly other extensions. All components mentioned in the certificate
are signed by an issuer.

A *certificate authority* (CA) receives a certificate signing request
from a server operator. It verifies that this signing request is
legitimate (e.g. requested server name is owned by the server
operator) and signs the request. The CA certificate must be trusted by
all potential clients. A CA can also issue intermediate CA
certificates, which are allowed to sign certificates.

When a server certificate or intermediate CA certificate is
compromised, the CA publishes this certificate in its certificate
revocation list (CRL), which each client should poll periodically.

The following certificates are exchanged before a TLS session:
- CA -> Client: CA certificate, installed as trust anchor on the client
- Server -> CA: certificate request, to be signed by the CA
- CA -> Server: signed server certificate

During the TLS handshake the server sends the certificate chain to the
client. When a client wants to verify a certificate, it has to verify
the signatures of the entire chain, and find a trust anchor which
signed the outermost certificate. Further constraints, such as the
maximum chain length and the validity period, are checked as
well. Finally, the server name in the server certificate is checked to
match the expected identity.
For an example, you can see the sequence diagram of the TLS handshake your browser makes when you visit our [demonstration server][tls-demo].

[tls-demo]: https://tls.openmirage.org

### Example code for verification

OpenSSL implements [RFC5280][] path validation, but there is no
implementation to validate the identity of a certificate. This has to
be implemented by each client, which is rather complex (e.g. in
[libfetch][] it spans over more than 300 lines). A client of the
`ocaml-x509` library (such as our [http-client][http_client]) has to
write only two lines of code:

```OCaml
lwt authenticator = X509_lwt.authenticator (`Ca_dir ca_cert_dir) in
lwt (ic, oc) =
  Tls_lwt.connect_ext
    (Tls.Config.client_exn ~authenticator ())
    (host, port)
```

The authenticator uses the default directory where trust anchors are
stored (['ca_cert_dir'][ca_cert_dir]), and this authenticator is
passed to the ['connect_ext'][connect_ext] function. This initiates
the TLS handshake, and passes the trust anchors and the hostname to
the TLS library.

During the client handshake when the certificate chain is received by
the server, the given authenticator and hostname are used to
authenticate the certificate chain (in ['validate_chain'][validate_chain]):

```OCaml
match
 X509.Authenticator.authenticate ?host:server_name authenticator stack
with
 | `Fail SelfSigned         -> fail Packet.UNKNOWN_CA
 | `Fail NoTrustAnchor      -> fail Packet.UNKNOWN_CA
 | `Fail CertificateExpired -> fail Packet.CERTIFICATE_EXPIRED
 | `Fail _                  -> fail Packet.BAD_CERTIFICATE
 | `Ok                      -> return server_cert
```

Internally, `ocaml-x509` extracts the hostname list from a
certificate in ['cert_hostnames'][cert_hostnames], and the
[wildcard or strict matcher][hostname_matches] compares it to the input.
In total, this is less than 50 lines of pure OCaml code.

[validate_chain]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lib/handshake_client.ml#L84
[connect_ext]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lwt/tls_lwt.ml#L227
[ca_cert_dir]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lwt/examples/ex_common.ml#L6
[http_client]: https://github.com/mirleft/ocaml-tls/blob/6dc9258a38489665abf2bd6cdbed8a1ba544d522/lwt/examples/http_client.ml
[libfetch]: https://github.com/freebsd/freebsd/blob/bf1a15b165af779577b0278b3d47151edb0d47f9/lib/libfetch/common.c#L326-665
[cert_hostnames]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L134-144
[hostname_matches]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L325-L346

### Problems in X.509 verification

Several weaknesses in the verification of X.509 certificates have been
discovered, ranging from cryptographic attacks due to
[collisions in hash algorithms][md5_collision] ([practical][]) over
[misinterpretation of the name][broken_null] in the certificate (a C
string is terminated by a null byte), and treating X.509 version 1
certificates always as a [trust anchor in GnuTLS][trust_gnutls].

An [empirical study of software that does certificate
verification][most_dangerous] showed that badly designed APIs are the
root cause of vulnerabilities in this area. They tested various
implementations by using a list of certificates, which did not form a
chain, and would not authenticate due to being self-signed, or
carrying a different server name.

Another recent empirical study ([Frankencert][]) generated random
certificates and validated these with various stacks. They found lots
of small issues in nearly all certificate verification stacks.

Our implementation mitigates against some of the known attacks: we
require a complete valid chain, check the extensions of a certificate,
and implement hostname checking as specified in [RFC6125][]. We have a
test suite with over 3200 tests and multiple CAs. We do not yet discard
certificates which use MD5 as hash algorithm. Our TLS stack
requires certificates to have at least 1024 bit RSA keys.

[md5_collision]: http://www.win.tue.nl/~bdeweger/CollidingCertificates/ddl-full.pdf
[practical]: http://www.win.tue.nl/hashclash/rogue-ca/
[broken_null]: http://www.blackhat.com/presentations/bh-usa-09/MARLINSPIKE/BHUSA09-Marlinspike-DefeatSSL-SLIDES.pdf
[trust_gnutls]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-0092
[most_dangerous]: https://crypto.stanford.edu/~dabo/pubs/abstracts/ssl-client-bugs.html
[Frankencert]: http://www.cs.utexas.edu/~suman/publications/frankencert.pdf

### X.509 library internals

The `x509` library uses [asn-combinators][] to parse X.509 certificates and
the [nocrypto][] library for signature verification
(which we wrote about [previously][nocrypto-intro]).
At the moment we do not yet
expose certificate builders from the library, but focus on certificate parsing
and certificate authentication.

The [x509][module_x509] module provides modules which parse
PEM-encoded ([pem][module_pem]) certificates ([Cert][module_cert])
and private keys
([Pk][module_pk]), and an authenticator module
([Authenticators][module_authenticator]).

[module_x509]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml
[module_pem]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml#L18
[module_cert]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml#L85
[module_pk]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml#L105
[module_authenticator]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml#L123

So far we have two authenticators implemented:
- ['chain_of_trust'][chain_of_trust], which implements the basic path
  validation algorithm from [RFC5280][] (section 6) and the hostname
  validation from [RFC6125][]. To construct such an authenticator, a
  timestamp and a list of trust anchors is needed.
- ['null'][null], which always returns success.

The method ['authenticate'][authenticate], to be called when a
certificate stack should be verified, receives an authenticator, a
hostname and the certificate stack. It returns either `Ok` or `Fail`.

[chain_of_trust]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml#L137
[null]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.ml#L142
[authenticate]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/x509.mli#L42

Our [certificate type][tbscert] is very similar to the described structure in the RFC:

```OCaml
type tBSCertificate = {
  version    : [ `V1 | `V2 | `V3 ] ;
  serial     : Z.t ;
  signature  : Algorithm.t ;
  issuer     : Name.dn ;
  validity   : Time.t * Time.t ;
  subject    : Name.dn ;
  pk_info    : PK.t ;
  issuer_id  : Cstruct.t option ;
  subject_id : Cstruct.t option ;
  extensions : (bool * Extension.t) list
}

type certificate = {
  tbs_cert       : tBSCertificate ;
  signature_algo : Algorithm.t ;
  signature_val  : Cstruct.t
}
```

[tbscert]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/asn_grammars.ml#L734

The certificate itself wraps the to be signed part (['tBSCertificate'][tbscert]),
the used signature algorithm, and the actual signature. It consists of
a version, serial number, issuer, validity, subject, public key
information, optional issuer and subject identifiers, and a list of
extensions -- only version 3 certificates may have extensions.

The ['certificate'][module_certificate] module implements the actual
authentication of certificates, and provides some useful getters such
as ['cert_type'][cert_type], ['cert_usage'][cert_usage], and
['cert_extended_usage'][cert_extended_usage]. The main entry for
authentication is ['verify_chain_of_trust'][verify_chain_of_trust],
which checks correct signatures of the chain, extensions and validity
of each certificate, and the hostname of the server certificate.

[module_certificate]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/certificate.mli
[cert_type]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/certificate.ml#L91
[cert_usage]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/certificate.ml#L95
[cert_extended_usage]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/certificate.ml#L100
[verify_chain_of_trust]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/certificate.ml#L419

The grammar of X.509 certificates is developed in the
['asn_grammars'][module_asn_grammars] module, and the object
identifiers are gathered in the ['registry'][module_registry] module.

[module_asn_grammars]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/asn_grammars.ml
[module_registry]: https://github.com/mirleft/ocaml-x509/blob/cdea2b1ae222e88a403f2d8f954a6aa31c984941/lib/registry.ml
[asn-combinators]: https://github.com/mirleft/ocaml-asn-combinators
[nocrypto]: https://github.com/mirleft/ocaml-nocrypto
[RFC5280]: https://tools.ietf.org/html/rfc5280

### Implementation of certificate verification

We provide the function ['valid_cas'][valid_cas], which takes a
timestamp and a list of certificate authorities. Each certificate
authority is checked to be [valid][is_ca_cert_valid], self-signed,
correctly signed, and having 
[proper X.509 v3 extensions][valid_trust_anchor_extensions].
As mentioned above, version 1 and version 2
certificates do not contain extensions. For a version 3 certificate,
['validate_ca_extensions'][validate_ca_extensions] is called: The
basic constraints extensions must be present, and its value must be
true. Also, key usage must be present and the certificate must be
allowed to sign certificates. Finally, we reject the certificate if
there is any extension marked critical, apart from the two mentioned
above.

When we have a list of validated CA certificates, we can use these to
[verify the chain of trust][verify_chain_of_trust], which gets a
hostname, a timestamp, a list of trust anchors and a certificate chain
as input. It first checks that the [server certificate is
valid][is_server_cert_valid], the [validity of the intermediate
certificates][is_cert_valid], and that the [chain is complete][climb]
(the pathlen constraint is not validated) and rooted in a trust
anchor. A server certificate is valid if the validity period matches
the current timestamp, the given hostname [matches][validate_hostname]
its subject alternative name extension or common name (might be
wildcard or strict matching, [RFC6125][]), and it does not have a
basic constraints extension which value is true.

[validate_hostname]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L333
[climb]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L421
[is_cert_valid]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L264
[is_server_cert_valid]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L384
[verify_chain_of_trust]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L419
[valid_cas]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L438
[is_ca_cert_valid]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L282
[valid_trust_anchor_extensions]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L277
[validate_ca_extensions]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml#L206

### Current status of ocaml-x509

We currently support only RSA certificates. We do not check revocation
lists or use the online certificate status protocol (OCSP). Our
implementation does not handle name constraints and policies. However, if
any of these extensions is marked critical, we refuse to validate the
chain. To keep our main authentication free of side-effects, it
currently uses the timestamp when the authenticator was created,
rather than when it is used.

We invite people to read through the
[certificate verification][certificate] and the
[ASN.1 parsing][asn1]. We welcome discussion on the
[mirage-devel mailing list][mirage_ml] and bug reports
on the [GitHub issue tracker][issues].

[mirage_ml]: http://lists.xenproject.org/archives/html/mirageos-devel/
[issues]: https://github.com/mirleft/ocaml-x509/issues
[certificate]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/certificate.ml
[asn1]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/asn_grammars.ml

[^0]: https://en.wikipedia.org/wiki/Man-in-the-middle_attack
[^1]: https://en.wikipedia.org/wiki/OpenPGP
[^2]: https://en.wikipedia.org/wiki/Transport_Layer_Security
[^3]: https://en.wikipedia.org/wiki/X.509
[RFC6125]: https://tools.ietf.org/html/rfc6125

****

Posts in this TLS series:
 
 - [Introducing transport layer security (TLS) in pure OCaml][tls-intro]
 - [OCaml-TLS: building the nocrypto library core][nocrypto-intro]
 - [OCaml-TLS: building the X.509 library][x509-intro]

[tls-intro]: http://openmirage.org/blog/introducing-ocaml-tls
[nocrypto-intro]: http://openmirage.org/blog/introducing-nocrypto
[x509-intro]: http://openmirage.org/blog/introducing-x509
