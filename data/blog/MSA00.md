---
updated: 2016-5-3
authors:
- name: Hannes Mehnert
  uri: https://github.com/hannesm
  email: hm519@cam.ac.uk
subject: 'MirageOS security advisory 00: mirage-net-xen'
permalink: MSA00
---

## MirageOS Security Advisory 00 - memory disclosure in mirage-net-xen

- Module:       mirage-net-xen
- Announced:    2016-05-03
- Credits:      Enguerrand Decorne, Thomas Leonard, Hannes Mehnert, Mindy Preston
- Affects:      mirage-net-xen <1.4.2
- Corrected:    2016-01-08 1.5.0 release, 2016-05-03 1.4.2 release

For general information regarding MirageOS Security Advisories,
please visit [https://mirage.io/security](https://mirage.io/security).

Hannes published a [blog article](https://hannes.nqsb.io/Posts/BadRecordMac) about
the analysis of this issue.

### Background

MirageOS is a library operating system using cooperative multitasking, which can
be executed as a guest of the Xen hypervisor.  Virtual devices, such as a
network device, share memory between MirageOS and the hypervisor.  MirageOS
allocates and grants the hypervisor access to a ringbuffer containing pages to
be sent on the network device, and another ringbuffer with pages to be filled
with received data.  A write on the MirageOS side consists of filling the page
with the packet data, submitting a write request to the hypervisor, and awaiting
a response from the hypervisor.  To correlate the request with the response, a
16bit identifier is used.

### Problem Description

Generating this 16bit identifier was not done in a unique manner.  When multiple
pages share an identifier, and are requested to be transmitted via the wire, the
first successful response will mark all pages with this identifier free, even
those still waiting to be transmitted.  Once marked free, the MirageOS
application fills the page for another chunk of data.  This leads to corrupted
packets being sent, and can lead to disclosure of memory intended for another
recipient.

### Impact

This issue discloses memory intended for another recipient.  All versions before
mirage-net-xen 1.4.2 are affected.  The receiving side uses a similar mechanism,
which may lead to corrupted incoming data (eventually even mutated while being
processed).

Version 1.5.0, released on 8th January, already assigns unique identifiers for
transmission.  Received pages are copied into freshly allocated buffers before
passed to the next layer.  When 1.5.0 was released, the impact was not clear to
us.  Version 1.6.1 now additionally ensures that received pages have a unique
identifier.

### Workaround

No workaround is available.

### Solution

The unique identifier is now generated in a unique manner using a monotonic
counter.

Transmitting corrupt data and disclosing memory is fixed in versions 1.4.2 and
above.

The recommended way to upgrade is:
```bash
opam update
opam upgrade mirage-net-xen
```

Or, explicitly:
```bash
opam upgrade
opam reinstall mirage-net-xen=1.4.2
```

Affected releases have been marked uninstallable in the opam repository.

### Correction details

The following list contains the correction revision numbers for each
affected branch.

Memory disclosure on transmit:

master: [47de2edfad9c56110d98d0312c1a7e0b9dcc8fbf](https://github.com/mirage/mirage-net-xen/commit/47de2edfad9c56110d98d0312c1a7e0b9dcc8fbf)

1.4: [ec9b1046b75cba5ae3473b2d3b223c3d1284489d](https://github.com/mirage/mirage-net-xen/commit/ec9b1046b75cba5ae3473b2d3b223c3d1284489d)

Corrupt data while receiving:

master: [0b1e53c0875062a50e2d5823b7da0d8e0a64dc37](https://github.com/mirage/mirage-net-xen/commit/0b1e53c0875062a50e2d5823b7da0d8e0a64dc37)

1.4: [6daad38af2f0b5c58d6c1fb24252c3eed737ede4](https://github.com/mirage/mirage-net-xen/commit/6daad38af2f0b5c58d6c1fb24252c3eed737ede4)

### References

[mirage-net-xen](https://github.com/mirage/mirage-net-xen)

You can find the latest version of this advisory online at
[https://mirage.io/blog/MSA00](https://mirage.io/blog/MSA00).

This advisory is signed using OpenPGP, you can verify the signature
by downloading our public key from a keyserver (`gpg --recv-key 4A732D757C0EDA74`),
downloading the raw markdown source of this advisory from [GitHub](https://raw.githubusercontent.com/mirage/mirage-www/master/data/security/00.txt.asc)
and executing `gpg --verify 00.md.asc`.
