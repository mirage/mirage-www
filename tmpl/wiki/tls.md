Deploying OCaml-TLS
===================

We developed various applications which use our OCaml-TLS stack,
running either on UNIX or on Mirage.  In this article, we will
describe them in detail and getting you ready to deploy.

tlstunnel
---------

`opam install tlstunnel`

Tlstunnel is a [stud](https://github.com/bumptech/stud) like TLS
proxy.  It listens on a given port and address, answers TLS
connections, and forwards the data to another service.  It is
developed as a UNIX application.  The configuration options of
`tlstunnel` are simplistic: `--frontend host:port` and `--backend
host:port` specify the front and backend.  Optionally logs can be
directed to a file (`--log FILE`).  Required options are the
certificate chain and private key, PEM-encoded in a file.  They can be
merged into a single file, or given as two distinct files (`--cert
FILE` and optionally `--key FILE` if a distinct file is used).

mirage-seal
-----------

`opam repo add mirage-dev https://github.com/mirage/mirage-dev.git`
`opam install mirage-seal`

Mirage-seal is a tool on top of mirage which lets you seal up a
directory to be served by a unikernel using https.  `mirage-seal` has
two command-line options, `--data=files/` and `--keys=secrets/`.
Inside of `secrets` you should have the private key and certificate
chain, as PEM-encoded files.

jackline
--------

`opam repo add xmpp-dev https://github.com/hannesm/xmpp-opam.git`
`opam install jackline`

Jackline is a terminal-based XMPP (jabber) client supporting basic
features (ping, message receipts, OTR encryption).  After installation
it starts with an interactive configuration.

tlsclient
---------

`opam pin add tlsclient https://github.com/hannesm/tlsclient.git`
`opam install tlsclient`

Tlsclient is a TLS client, in the spirit of `openssl s_client`.  Given
a hostname and port it will connect there and do a TLS handshake, and
report back the certificate chain and security parameters.  A
directory with trust anchors can be provided, which will be used to
verify the certificate chain.
