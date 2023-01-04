---
updated: 2022-12-07
authors:
- name: Hannes Mehnert
  uri: http://hannes.robur.coop
- name: Pierre Alain
  uri: https://github.com/palainp
subject: 'MirageOS security advisory 03: xen with solo5 >= 0.6.6 & < 0.7.5'
permalink: MSA03
---

## MirageOS Security Advisory 03 - infinite loop in console output on xen

- Module:       solo5
- Announced:    2022-12-07
- Credits:      Krzysztof Burghardt, Pierre Alain, Thomas Leonard, Hannes Mehnert
- Affects:      solo5 >= 0.6.6 & < 0.7.5,
                qubes-mirage-firewall >= 0.8.0 & < 0.8.4
- Corrected:    2022-12-07: solo5 0.7.5,
                2022-12-07: qubes-mirage-firewall 0.8.4
- CVE:          CVE-2022-46770

For general information regarding MirageOS Security Advisories,
please visit [https://mirage.io/security](https://mirage.io/security).

### Background

MirageOS is a library operating system using cooperative multitasking, which can
be executed as a guest of the Xen hypervisor. Output on the console is performed
via the Xen console protocol.

### Problem Description

Since MirageOS moved from PV mode to PVH, and thus replacing Mini-OS with solo5,
there was an issue in the solo5 code which failed to properly account the
already written bytes on the console. This only occurs if the output to be
performed does not fit in a single output buffer (2048 bytes on Xen).

The code in question set the number of bytes written to the last written count
(written = output_some(buf)), instead of increasing the written count
(written += output_some(buf)).

### Impact

Console output may lead to an infinite loop, endlessly printing data onto the
console.

A prominent unikernel is the Qubes MirageOS firewall, which prints some input
packets onto the console. This can lead to a remote denial of service
vulnerability, since any client could send a malformed and sufficiently big
network packet.

### Workaround

No workaround is available.

### Solution

The solution is to fix the console output code in solo5, as done in
https://github.com/Solo5/solo5/pull/538/commits/099be86f0a17a619fcadbb970bb9e511d28d3cd8

For the qubes-mirage-firewall, update to a solo5 release (0.7.5) which has the
issue fixed. This has been done in the release 0.8.4 of qubes-mirage-firewall.

The recommended way to upgrade is:
```bash
opam update
opam upgrade solo5
```

### Correction details

The following PRs were part of the fix:

- [solo5/pull/538](https://github.com/Solo5/solo5/pull/538) - xen console: update the "to be written" count
- [qubes-mirage-firewall/pull/167](https://github.com/mirage/qubes-mirage-firewall/pull/167) - update opam repository commit

### Timeline

- 2022-12-04: initial report by Krzysztof Burghardt https://github.com/mirage/qubes-mirage-firewall/issues/166
- 2022-12-04: investigation by Hannes Mehnert and Pierre Alain
- 2022-12-05: initial fix by Pierre Alain https://github.com/Solo5/solo5/pull/538
- 2022-12-05: review of fix by Thomas Leonard
- 2022-12-07: release of fixed packages and security advisory

### References

You can find the latest version of this advisory online at
[https://mirage.io/blog/MSA03](https://mirage.io/blog/MSA03).

This advisory is signed using OpenPGP, you can verify the signature
by downloading our public key from a keyserver (`gpg --recv-key
4A732D757C0EDA74`),
downloading the raw markdown source of this advisory from
[GitHub](https://raw.githubusercontent.com/mirage/mirage-www/master/data/security/03.txt.asc)
and executing `gpg --verify 03.txt.asc`.
