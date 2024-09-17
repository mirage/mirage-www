---
updated: 2019-03-05
authors:
- name: Hannes Mehnert
  uri: https://github.com/hannesm
  email: hm519@cam.ac.uk
subject: Announcing MirageOS 3.5.0
permalink: announcing-mirage-35-release
---

We are happy to announce our MirageOS 3.5.0 release. We didn't announce post 3.0.0 releases too well -- that's why this post tries to summarize the changes in the MirageOS ecosystem over the past two years. MirageOS consists of over 100 opam packages, lots of which are reused in other OCaml projects and deployments without MirageOS. These opam packages are maintained and developed further by lots of developers.

On the OCaml tooling side, since MirageOS 3.0.0 we did several major changes:
- moved most packages to [dune](https://dune.build/) (formerly jbuilder) and began using [dune-release](https://github.com/samoht/dune-release) for smooth developer experience and simple releases,
- require [opam](https://opam.ocaml.org) to be version 2.0.2 or later, allowing `pin-depends` in `config.ml`. `pin-depends` allows you to depend on a development branch of any opam package for your unikernel,
- adjusted documentation to adhere to [odoc](https://github.com/ocaml/odoc/) requirements,
- the `mirage` command-line utility now emits lower and upper bounds of opam packages, allowing uncompromising deprecation of packages,
- support for OCaml 4.06.0 (and above), where `safe-string` is enabled by default. Strings are immutable now!!,
- remove usage of `result` package, which has incorporated into `Pervasives` since OCaml 4.03.0.

The 3.5.0 release contains several API improvements of different MirageOS interfaces - if you're developing your own MirageOS unikernels, you may want to read this post to adjust to the new APIs.

## MirageOS interface API changes:

- [mirage-clock](https://github.com/mirage/mirage-clock) has the `type t` constrained to `unit` as of 2.0.0;
- [mirage-protocols](https://github.com/mirage/mirage-protocols) renames the `ETHIF` module type to the clearer `ETHERNET`. As of 2.0.0 it also contains keep-alive support, complies with recent TCP/IP layering rework (see below), and IPv4 now supports reassembly and fragmentation;
- [mirage-net](https://github.com/mirage/mirage-net) reflects revised layering API as of 2.0.0 (see below);
- [mirage-kv](https://github.com/mirage/mirage-kv) has a revised API and introduction of a read-write key-value store (see below).

## Major changes

### [Key-value store](https://github.com/mirage/mirage-kv)

We improved the key-value store API, and added a read-write store. There is also [ongoing work](https://github.com/mirage/irmin/pull/559) which implements the read-write interface using irmin, a branchable persistent storage that can communicate via the git protocol. Motivations for these changes were the development of [CalDAV](https://github.com/robur-coop/caldav), but also the development of [wodan](https://github.com/mirage/wodan), a flash-friendly, safe and flexible filesystem. The goal is to EOL the [mirage-fs](https://github.com/mirage/mirage-fs) interface in favour of the key-value store.

Major API improvements (in [this PR](https://github.com/mirage/mirage-kv/pull/14), since 2.0.0):
- The `key` is now a path (list of segments) instead of a `string`
- The `value` type is now a `string`
- The new function `list : t -> key -> (string * [`Value|`Dictionary], error) result io` was added
- The function `get : t -> key -> (value, error) result io` is now provided (used to be named `read` and requiring an `offset` and `length` parameter)
- The functions `last_modified : t -> key -> (int * int64, error) result io` and `digest : t -> key -> (string, error) result io` have been introduced
- The function `size` was removed.
- The signature `RW` for read-write key-value stores extends `RO` with three functions `set`, `remove`, and `batch`

There is now a [non-persistent in-memory implementation](https://github.com/mirage/mirage-kv-mem) of a read-write key-value store available. Other implementations (such as [crunch](https://github.com/mirage/ocaml-crunch), [mirage-kv-unix](https://github.com/mirage/mirage-kv-unix), [mirage-fs](https://github.com/mirage/mirage-fs), [tar](https://github.com/mirage/ocaml-tar) have been adapted, as well as clients of mirage-kv (dns, cohttp, tls)).

### [TCP/IP](https://github.com/mirage/mirage-tcpip)

The IPv4 implementation now has support for [fragment reassembly](https://github.com/mirage/mirage-tcpip/pull/375). Each incoming IPv4 fragment is checked for the "more fragments" and "offset" fields. If these are non-zero, the fragment is processed by the [fragment cache](https://mirage.github.io/mirage-tcpip/tcpip/Fragments/index.html), which uses a [least recently used](https://github.com/pqwy/lru) data structure of maximum size 256kB content shared by all incoming fragments. If there is any overlap in fragments, the entire packet is dropped ([avoiding security issues](https://eprint.iacr.org/2015/1020.pdf)). Fragments may arrive out of order. The code is [heavily unit-tested](https://github.com/mirage/mirage-tcpip/blob/v3.7.1/test/test_ipv4.ml#L49-L203). Each IPv4 packet may at most be in 16 fragments (to minimise CPU DoS with lots of small fragments), the timeout between the first and last fragment is 10 seconds.

The layering and allocation discipline has been revised. [`ethernet`](https://github.com/mirage/ethernet) (now encapsulating and decapsulating Ethernet) and [`arp`](https://github.com/mirage/arp) (the address resolution protocol) are separate opam packages, and no longer part of `tcpip`.

At the lowest layer, [mirage-net](https://github.com/mirage/mirage-net) is the network device. This interface is implemented by our different backends ([xen](https://github.com/mirage/mirage-net-xen), [solo5](https://github.com/mirage/mirage-net-solo5), [unix](https://github.com/mirage/mirage-net-unix), [macos](https://github.com/mirage/mirage-net-macosx), and [vnetif](https://github.com/mirage/mirage-vnetif)). Some backends require buffers to be page-aligned when they are passed to the host system. This was previously not really ensured: while the abstract type `page_aligned_buffer` was required, `write` (and `writev`) took the abstract `buffer` type (always constrained to `Cstruct.t` by mirage-net-lwt). The `mtu` (maximum transmission unit) used to be an optional `connect` argument to the Ethernet layer, but now it is a function which needs to be provided by mirage-net.

The `Mirage_net.write` function now has a signature that is explicit about ownership and lifetime: `val write : t -> size:int -> (buffer -> int) -> (unit, error) result io`.
It requires a requested `size` argument to be passed, and a fill function which is called with an allocated buffer, that satisfies the backend demands. The `fill` function is supposed to write to the buffer, and return the length of the frame to be send out. It can neither error (who should handle such an error anyways?), nor is it in the IO monad. The `fill` function should not save any references to the buffer, since this is the network device's memory, and may be reused. The `writev` function has been removed.

The [Ethernet layer](https://github.com/mirage/mirage-protocols) does encapsulation and decapsulation now. Its `write` function has the following signature:
`val write: t -> ?src:macaddr -> macaddr -> Ethernet.proto -> ?size:int -> (buffer -> int) -> (unit, error) result io`.
It fills in the Ethernet header with the given source address (defaults to the device's own MAC address) and destination address, and Ethernet protocol. The `size` argument is optional, and defaults to the MTU. The `buffer` that is passed to the `fill` function is usable from offset 0 on. The Ethernet header is not visible at higher layers.

The IP layer also embeds a revised `write` signature:
`val write: t -> ?fragment:bool -> ?ttl:int -> ?src:ipaddr -> ipaddr -> Ip.proto -> ?size:int -> (buffer -> int) -> buffer list -> (unit, error) result io`.
This is similar to the Ethernet signature - it writes the IPv4 header and sends a packet. It also supports fragmentation (including setting the do-not-fragment bit for path MTU discovery) -- whenever the payload is too big for a single frame, it is sent as multiple fragmented IPv4 packets. Additionally, setting the time-to-live is now supported, meaning we now can implement traceroute!
The API used to include two functions, `allocate_frame` and `write`, where only buffers allocated by the former should be used in the latter. This has been combined into a single function that takes a fill function and a list of payloads. This change is for maximum flexibility: a higher layer can either construct its header and payload, and pass it to `write` as payload argument (the `buffer list`), which is then copied into the buffer(s) allocated by the network device, or the upper layer can provide the callback `fill` function to assemble its data into the buffer allocated by the network device, to avoid copying. Of course, both can be used - the outgoing packet contains the IPv4 header, and possibly the buffer until the offset returned by `fill`, and afterwards the payload.

The TCP implementation has [preliminary keepalive support](https://github.com/mirage/mirage-tcpip/pull/338).

### [Solo5](https://github.com/solo5/solo5)

- MirageOS 3.0.0 used the 0.2.0 release of solo5
- The `ukvm` target was renamed to `hvt`, where `solo5-hvt` is the monitoring process
- Support for [FreeBSD bhyve](http://bhyve.org/) and [OpenBSD VMM](https://man.openbsd.org/vmm.4) hypervisor (within the hvt target)
- Support for ARM64 and KVM
- New target [muen.sk](https://muen.sk), a separation kernel developed in SPARK/Ada
- New target [GenodeOS](https://genode.org), an operating system framework using a microkernel
- Debugger support: attach gdb in the host system for improved debugging experience
- Core dump support
- Drop privileges on OpenBSD and FreeBSD
- Block device write fixes (in [mirage-block-solo5](https://github.com/mirage/mirage-block-solo5))

### [random](https://github.com/mirage/mirage-random)

The [default random device](https://github.com/mirage/mirage-random-stdlib) from the OCaml standard library is now properly seeded using [mirage-entropy](https://github.com/mirage/mirage-entropy). In the future, we plan to make the [fortuna RNG](https://github.com/mirleft/ocaml-nocrypto) the default random number generator.

### Argument passing to unikernels

The semantics of arguments passed to a MirageOS unikernel used to vary between different backends, now they're the same everywhere: all arguments are concatenated using the whitespace character as separator, and split on the whitespace character again by [parse-argv](https://github.com/mirage/parse-argv). To pass a whitespace character in an argument, the whitespace now needs to be escaped: `--hello=foo\ bar`.

### Noteworthy package updates

- [cstruct 3.6.0](https://github.com/mirage/ocaml-cstruct) API changes and repackaging, see [this announcement](https://discuss.ocaml.org/t/ann-cstruct-3-0-0-with-packaging-changes) and [this announcement](https://discuss.ocaml.org/t/psa-cstruct-3-4-0-removes-old-ocamlfind-subpackage-aliases)
- [ipaddr 3.0.0](https://github.com/mirage/ocaml-ipaddr) major API changes, the s-expression serialisation is a separate subpackage, macaddr is now a standalone opam package
- [base64 3.0.0](https://github.com/mirage/base64) performance and API changes, see [this announcement](https://discuss.ocaml.org/t/ann-major-release-of-base64-article)
- [git 2.0.0](https://github.com/mirage/ocaml-git), read [this announcement](https://discuss.ocaml.org/t/ann-ocaml-git-2-0), as well as [its design and implementation](https://discuss.ocaml.org/t/ocaml-git-git-design-and-implementation)
- [io-page 2.0.0](https://github.com/mirage/io-page), see [this announcement](https://discuss.ocaml.org/t/ann-io-page-2-0-0-with-packaging-changes)
- [cohttp 2.0.0](https://github.com/mirage/ocaml-cohttp), see [this announcement](https://discuss.ocaml.org/t/ann-major-releases-of-cohttp-conduit-dns-tcpip)
- [dns 1.0.0](https://github.com/mirage/ocaml-dns), see [this announcement](https://discuss.ocaml.org/t/ann-major-releases-of-cohttp-conduit-dns-tcpip)
- [conduit 1.0.0](https://github.com/mirage/ocaml-conduit), see [this announcement](https://discuss.ocaml.org/t/ann-major-releases-of-cohttp-conduit-dns-tcpip)

## More features and bugfixes

- More HTTP server choices are supported via a new [httpaf device](https://github.com/mirage/mirage/pull/955) that permits the [high performance httpaf](https://github.com/inhabitedtype/httpaf) stack to run as a unikernel now.
- [libvirt.xml is generated for virtio target](https://github.com/mirage/mirage/pull/903)
- [Unix target now include -tags thread](https://github.com/mirage/mirage/issues/861) (for mirage-framebuffer SDL support)
- Various modules (IPv6, DHCP) are explicit about their dependency to the random device
- [QubesDB can be requested in config.ml when the target is Xen](https://github.com/mirage/mirage/pull/807)

You may also want to read the [MirageOS 3.2.0 announcement](https://discuss.ocaml.org/t/ann-mirage-3-2-0) and the [MirageOS 3.3.0 announcement](https://discuss.ocaml.org/t/mirage-3-3-0-released).

## Next steps

We are working on [further](https://github.com/mirage/mirage/issues/969) [changes](https://github.com/mirage/functoria/pull/167) which revise the `mirage` internal build system to [dune](https://dune.build). At the moment it uses `ocamlbuild`, `ocamlfind`, `pkg-config`, and `make`. The goal of this change is to make MirageOS more developer-friendly. On the horizon we have MirageOS unikernel monorepos, incremental builds, pain-free cross-compilation, documentation generation, ...

Several other MirageOS ecosystem improvements are on the schedule for 2019, including an [irmin 2.0 release](https://zshipko.github.io/irmin-tutorial/), a [seccomp target for Solo5](https://github.com/Solo5/solo5/pull/310), and [easier deployment and multiple interface in Solo5](https://github.com/Solo5/solo5/issues/326).

