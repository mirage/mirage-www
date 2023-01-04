---
updated: 2019-03-21
authors:
- name: Mindy Preston
  uri: https://github.com/yomimono
  email: mindy.preston@cl.cam.ac.uk
subject: 'MirageOS security advisory 01: netchannel 1.10.0'
permalink: MSA01
---

## MirageOS Security Advisory 01 - memory disclosure in mirage-net-xen

- Module:       netchannel
- Announced:    2019-03-21
- Credits:      Thomas Leonard, Hannes Mehnert, Mindy Preston
- Affects:      netchannel = 1.10.0
- Corrected:    2019-03-20 1.10.1 release

For general information regarding MirageOS Security Advisories,
please visit [https://mirage.io/security](https://mirage.io/security).

### Background

MirageOS is a library operating system using cooperative multitasking, which can
be executed as a guest of the Xen hypervisor.  Virtual devices, such as a
network device, share memory between MirageOS and the hypervisor.  To maintain
adequate performance, the virtual device managing network communication between
MirageOS and the Xen hypervisor maintains a shared pool of pages and reuses
them for write requests.

### Problem Description

In version 1.10.0 of netchannel, the API for handling network requests
changed to provide higher-level network code with an interface for writing into
memory directly.  As part of this change, code paths which exposed memory taken
from the shared page pool did not ensure that previous data had been cleared
from the buffer.  This error resulted in memory which the user did not
overwrite staying resident in the buffer, and potentially being sent as part of
unrelated network communication.

The mirage-tcpip library, which provides interfaces for higher-level operations
like IPv4 and TCP header writes, assumes that buffers into which it writes have
been zeroed, and therefore may not explicitly write some fields which are always
zero.  As a result, some packets written with netchannel v1.10.0 which were
passed to mirage-tcpip with nonzero data will have incorrect checksums
calculated and will be discarded by the receiver.

### Impact

This issue discloses memory intended for another recipient and corrupts packets.
Only version 1.10.0 of netchannel is affected.  Version 1.10.1 fixes this issue.

Version 1.10.0 was available for less than one month and many upstream users
had not yet updated their own API calls to use it.  In particular, no version of
qubes-mirage-firewall or its dependency mirage-nat compatible with version
1.10.0 was released.

### Workaround

No workaround is available.

### Solution

Transmitting corrupt data and disclosing memory is fixed in version 1.10.1.

The recommended way to upgrade is:
```bash
opam update
opam upgrade netchannel
```

Or, explicitly:
```bash
opam upgrade
opam reinstall netchannel=1.10.1
```

Affected releases (version 1.10.0 of netchannel and mirage-net-xen) have been marked uninstallable in the opam repository.

### Correction details

The following list contains the correction revision numbers for each
affected branch.

Memory disclosure on transmit:

master: [6c7a13a5dae0f58dcc0653206a73fa3d8174b6d2](https://github.com/mirage/mirage-net-xen/commit/6c7a13a5dae0f58dcc0653206a73fa3d8174b6d2)

1.10.0: [bd0382eabe17d0824c8ba854ec935d8a2e5f7489](https://github.com/mirage/mirage-net-xen/commit/bd0382eabe17d0824c8ba854ec935d8a2e5f7489)

### References

[netchannel](https://github.com/mirage/mirage-net-xen)

You can find the latest version of this advisory online at
[https://mirage.io/blog/MSA01](https://mirage.io/blog/MSA01).

This advisory is signed using OpenPGP, you can verify the signature
by downloading our public key from a keyserver (`gpg --recv-key 4A732D757C0EDA74`),
downloading the raw markdown source of this advisory from [GitHub](https://raw.githubusercontent.com/mirage/mirage-www/master/data/security/01.txt.asc)
and executing `gpg --verify 01.txt.asc`.
