---
updated: 2019-10-18
authors:
- name: Martin Lucina
  uri: https://lucina.net/
  email: martin@lucina.net
subject: Announcing MirageOS 3.6.0
permalink: announcing-mirage-36-release
---

We are pleased to announce the release of MirageOS 3.6.0. This release updates MirageOS to support [Solo5](https://github.com/Solo5/solo5) 0.6.0 and later.

New features:

* Support for the Solo5 `spt` (sandboxed process tender) target via `mirage configure -t spt`. The `spt` target runs MirageOS unikernels in a minimal strict seccomp sandbox on Linux `x86_64`, `aarch64` and `ppc64le` hosts.
* Support for the Solo5 _application manifest_, enabling support for multiple network and block storage devices on the `hvt`, `spt` and `muen` targets. The `genode` and `virtio` targets are still limited to using a single network or block storage device.
* Several notable security enhancements to Solo5 targets, such as enabling stack smashing protection throughout the toolchain by default and improved page protections on some targets.  For details, please refer to the Solo5 0.6.0 [release notes](https://github.com/Solo5/solo5/releases/tag/v0.6.0).

Additional user-visible changes:

* Solo5 0.6.0 has removed the compile-time specialization of the `solo5-hvt` tender. As a result, a `solo5-hvt` binary is no longer built at `mirage build` time. Use the `solo5-hvt` binary installed in your `$PATH` by OPAM to run the unikernel.
* `mirage build` now produces silent `ocamlbuild` output by default. To get the old behaviour, run with `--verbose` or set the log level to `info` or `debug`.
* New functions `Mirage_key.is_solo5` and `Mirage_key.is_xen`, analogous to `Mirage_key.is_unix`.

Thanks to Hannes Mehnert for help with the release engineering for MirageOS 3.6.0.

