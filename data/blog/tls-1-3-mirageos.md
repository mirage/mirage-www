---
updated: 2020-05-20 14:00
authors:
- name: Hannes Mehnert
  uri: https://github.com/hannesm
  email: hm519@cam.ac.uk
subject: TLS 1.3 support for MirageOS
permalink: tls-1-3-mirageos
---

We are pleased to announce that [TLS 1.3](https://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_1.3) support for MirageOS is available. With
mirage 3.7.7 and tls 0.12 the [Transport Layer Security (TLS) Protocol Version 1.3](https://tools.ietf.org/html/rfc8446)
is available in all MirageOS unikernels, including on our main website. If you're reading this, you've likely established a TLS 1.3 connection already :)

Getting there was some effort: we now embed the Coq-verified [fiat](https://github.com/mirage/fiat/)
library (from [fiat-crypto](https://github.com/mit-plv/fiat-crypto/)) for the P-256 elliptic curve, and the F*-verified [hacl](https://github.com/mirage/hacl)
library (from [Project Everest](https://project-everest.github.io/)) for the X25519 elliptic curve to establish 1.3 handshakes with ECDHE.

Part of our TLS 1.3 stack is support for pre-shared keys, and 0 RTT. If you're keen to try these features, please do so and report any issues you encounter [to our issue tracker](https://github.com/mirleft/ocaml-tls).

We are still lacking support for RSA-PSS certificates and EC certificates, post-handshake authentication, and the chacha20-poly1305 ciphersuite. There is also a [minor symbol clash](https://github.com/mirage/hacl/issues/32) with the upstream F* C bindings which we are aware of. We will continue to work on these, and patches are welcome.

