Deploying OCaml-TLS
===================

We developed various Unix applications which use the OCaml-TLS stack.
In this article, we will describe them in detail and getting you ready
to deploy.

[tlstunnel](https://github.com/hannesm/tlstunnel)
---------

```
opam install tlstunnel
```

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

[jackline](https://github.com/hannesm/jackline)
--------

```
opam repo add xmpp-dev https://github.com/hannesm/xmpp-opam.git
opam install jackline
```

Jackline is a terminal-based XMPP (jabber) client supporting basic
features (ping, message receipts, OTR encryption).  After installation
it starts with an interactive configuration.

[tlsclient](https://github.com/hannesm/tlsclient)
---------

```
opam pin add tlsclient https://github.com/hannesm/tlsclient.git
```

Tlsclient is a TLS client, in the spirit of `openssl s_client`.  Given
a hostname and port it will connect there and do a TLS handshake, and
report back the certificate chain and security parameters.  A
directory with trust anchors can be provided, which will be used to
verify the certificate chain.
