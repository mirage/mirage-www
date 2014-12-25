### ocaml-dns-v0.12.0: Multicast DNS parsing support

Released on 2014-12-25 as [v0.12.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.12.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Parse and marshal the mDNS unicast-response bit (#29).
* Add OUnit tests for `Dns.Packet.parse` using `pcap` files.
* Fix parsing of `SRV` records (#30).
* Use `Bytes` instead of `String` for mutable buffers.
* Switch to `Base64` v2, which uses `B64` as the toplevel module name
  to avoid linking conflicts with other community libraries.

### ocaml-cohttp-v0.15.0: Compatibility with new base64 and minor interface tweaks

Released on 2014-12-25 as [v0.15.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.15.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:
* Change `Cohttp_lwt_body.map` to use a non-labelled type to fit the Lwt
  style better (#200).
* Depend on Base64 version 2, which uses `B64` as the toplevel module name (#220).

New features and bug fixes:
* Remove use of deprecated `Lwt_unix.run` and replace it with `Lwt_main.run`.
  Should be no observable external change (#217).
* Improve ocamldoc of `Cohttp.S` signature (#221).

### ocaml-ctypes-0.3.4: ocaml-ctypes 0.3.4

Released on 2014-12-23 as [0.3.4](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.3.4). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.


### mirage-console-2.1.0: Xen: support stand-alone console servers

Released on 2014-12-22 as [2.1.0](https://github.com/mirage/mirage-console/releases/tag/2.1.0). See <https://github.com/mirage/mirage-console> for full history.

- Console.connect now blocks waiting for consoles to be hotplugged. This makes it possible to run stand-alone console servers which are not integrated directly with the toolstack.

### ocaml-tls-0.3.0: A New Dawn - After Solstice

Released on 2014-12-22 as [0.3.0](https://github.com/mirleft/ocaml-tls/releases/tag/0.3.0). See <https://github.com/mirleft/ocaml-tls> for full history.

* X509_lwt provides Fingerprints and Hex_fingerprints constructor for checking fingerprints of certificates instead of trusting trust anchors
* client configuration requires an authenticator
* server certificate must be at least Config.min_rsa_key_size bits
* expose epoch via lwt interface
* mirage-2.2.0 compatibility
* cleanups of mirage interface
* nocrypto-0.3.0 compatibility

### ocaml-x509-0.2.1: The Slow Sculpture

Released on 2014-12-22 as [0.2.1](https://github.com/mirleft/ocaml-x509/releases/tag/0.2.1). See <https://github.com/mirleft/ocaml-x509> for full history.

It's all about evolution, not revolution with this one.

Even though it's solstice.

### ocaml-nocrypto-0.3.0: Break-my-API Christmas special

Released on 2014-12-22 as [0.3.0](https://github.com/mirleft/ocaml-nocrypto/releases/tag/0.3.0). See <https://github.com/mirleft/ocaml-nocrypto> for full history.

This one is mostly about breaking your API.

With a bit of luck, name clashes with the other libs are gone.

### mirage-platform-v2.1.2: Further Xen/MiniOS header cleanup

Released on 2014-12-21 as [v2.1.2](https://github.com/mirage/mirage-platform/releases/tag/v2.1.2). See <https://github.com/mirage/mirage-platform> for full history.

[xen] Updated headers and build for Mini-OS 0.5.  This involves:

* Require libminios >= 0.5
* Remove old includes directory when installing
* Compile with `-fno-builtin` (avoids warnings about standard functions)
* Removed `complex.h` (now provided by Openlibm)
* Include `cdefs.h` from `types.h` (needed for `__BEGIN_DECLS`)
* Removed open from `unistd.h` (comes from `fcntl.h`)
* Removed `assert.h` and `__assert_fail` (provided by Mini-OS)
* Removed `string.h` (provided by Mini-OS)
* Removed `cdefs.h` (provided by Mini-OS)
* Added missing `console.h` includes (for `printk`)

### ocaml-cow-v1.1.0: Support ezjsonm interface for JSON manipulation

Released on 2014-12-21 as [v1.1.0](https://github.com/mirage/ocaml-cow/releases/tag/v1.1.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Add OPAM 1.2 compatible description file (#53).
* Fix compatibility with `ezjsonm` version 0.4+ (#55).

### mirage-tcpip-v2.2.1: Remove uint dependency and start safe-string migration

Released on 2014-12-20 as [v2.2.1](https://github.com/mirage/mirage-tcpip/releases/tag/v2.2.1). See <https://github.com/mirage/mirage-tcpip> for full history.

* Use `Bytes` instead of `String` to begin the `-safe-string` migration in OCaml 4.02.0 (#93).
* Remove dependency on `uint` to avoid the need for a C stub (#92).


### mirage-xen-minios-v0.6.0: Build Mini-OS and Openlibm with -nostdinc

Released on 2014-12-20 as [v0.6.0](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.6.0). See <https://github.com/mirage/mirage-xen-minios> for full history.

### cowabloga-v0.0.9: Compatibility with Cohttp 0.14.x

Released on 2014-12-19 as [v0.0.9](https://github.com/mirage/cowabloga/releases/tag/v0.0.9). See <https://github.com/mirage/cowabloga> for full history.

Add compatibility with Cohttp 0.14.x APIs.

### ocaml-github-v0.9.4: Add bindings for organisation teams and repositories

Released on 2014-12-19 as [v0.9.4](https://github.com/avsm/ocaml-github/releases/tag/v0.9.4). See <https://github.com/avsm/ocaml-github> for full history.

* Add bindings for organisation teams and repositories (#45).
* Use `Bytes` instead of `String` for future `safe-string` support.
* Use the Cohttp 0.14.0 API in the test cases and make them optional
  (activate with `--enable-tests` during configure).
* Add a `--json` option to `git-list-releases` so that it can emit
  the release information in JSON rather than Markdown.


### mirage-tcpip-v2.2.0: Add IPv6 stack

Released on 2014-12-18 as [v2.2.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.2.0). See <https://github.com/mirage/mirage-tcpip> for full history.


Add IPv6 support. This changeset minimises interface changes to the existing
`STACKV4` interfaces to faciliate a progressive merge.  The only visible
interface changes are:

* `IPV4.set_ipv4_*` functions have been renamed `IPV4.set_ip_*` because they
  are shared between IPV4 and IPV6.
* `IPV4.get_ipv4` and `get_ipv4_netmask` now return a `list` of `Ipaddr.V4.t`
  (again because this is the common semantics with IPV6.)
* Several types that had `v4` in their names (like `IPV4.ipv4addr`) have lost
  that particle.


### mirage-v2.2.0: Add IPv6 support to the type definitions

Released on 2014-12-18 as [v2.2.0](https://github.com/mirage/mirage/releases/tag/v2.2.0). See <https://github.com/mirage/mirage> for full history.

Add IPv6 support, from Nicolas Ojeda Bar. This alters some of the interfaces that were previously hardcoded to IPv4 by generalising them.  For example:

```
type v4
type v6

type 'a ip
type ipv4 = v4 ip
type ipv6 = v6 ip
```

Full support for configuring IPv6 does not exist yet, as this release is
intended for getting the type definitions in place before adding configuration
support.


### ocaml-cohttp-v0.14.0: Simplify server interface

Released on 2014-12-18 as [v0.14.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.14.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:
* Simplify the Lwt server signature, so that manual construction of
  a `callback` is no longer required (#210).
  Code that previous looked like:

```
   let conn_closed (_,conn_id) () = <...>
   let config = { Server.callback; conn_closed } in
```

should now be:

```
   let conn_closed (_,conn_id) = <...>
   let config = Server.make ~callback ~conn_closed () in
```

* Remove the `Cohttp.Base64` module in favour of the external `base64`
  library (which is now a new dependency).

New features and bug fixes:
* Lwt `respond_error` now defaults to an internal server error if no
  status code is specified (#212).
* Modernise the `opam` file using the OPAM 1.2 workflow (#211).
* Flush the response body to the network by default, rather than
  buffering by default.  The `?flush` optional parameter can still
  be explicitly set to false if flushing is not desired (#205).


### mirage-xen-minios-v0.5.0: Build Openlibm with Mini-OS CFLAGS

Released on 2014-12-17 as [v0.5.0](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.5.0). See <https://github.com/mirage/mirage-xen-minios> for full history.

In particular, this now uses `-mno-red-zone` on x86_64 architectures.

### mirage-net-xen-v1.2.0: Add profile tracing to Netfront

Released on 2014-12-17 as [v1.2.0](https://github.com/mirage/mirage-net-xen/releases/tag/v1.2.0). See <https://github.com/mirage/mirage-net-xen> for full history.

* Add profiling tracepoints and labels (#13).  Introduces a dependency on `mirage-profile`.
* New `opam` file present in source repository for OPAM 1.2 workflow.


### mirage-platform-v2.1.1: Add header definitions for Ctypes support

Released on 2014-12-17 as [v2.1.1](https://github.com/mirage/mirage-platform/releases/tag/v2.1.1). See <https://github.com/mirage/mirage-platform> for full history.

* Remove checksum stubs from Unix and Xen, as they are provided by `tcpip` now.
* [xen] Define UINTx_MAX and SIZE_MAX in stdint.h, which is sufficient to let Ctypes compile (ocamllabs/ocaml-ctypes#231)


### ocaml-git-1.4.2: Fix writing of empty files

Released on 2014-12-14 as [1.4.2](https://github.com/mirage/ocaml-git/releases/tag/1.4.2). See <https://github.com/mirage/ocaml-git> for full history.

* Fix `Git_unix.IO.write_file` to work on empty files

### mirage-tc-0.2.1: Bug-fix release

Released on 2014-12-14 as [0.2.1](https://github.com/mirage/mirage-tc/releases/tag/0.2.1). See <https://github.com/mirage/mirage-tc> for full history.

- Report more useful errors on binary parse errors
- Add cstructs combinators
- Fix Tc.List.equal

### mirage-profile-v0.4: mirage-profile 0.4

Released on 2014-12-12 as [v0.4](https://github.com/mirage/mirage-profile/releases/tag/v0.4). See <https://github.com/mirage/mirage-profile> for full history.

- Add signal support (to see interactions with `Lwt_condition`s).
- Don't break the build when new events are added to Lwt.

### mirage-tcpip-v2.1.1: Improved DHCP logging

Released on 2014-12-12 as [v2.1.1](https://github.com/mirage/mirage-tcpip/releases/tag/v2.1.1). See <https://github.com/mirage/mirage-tcpip> for full history.

Improve console printing for the DHCP client to output line breaks properly on Xen consoles.


### mirage-trace-viewer-v0.1: mirage-trace-viewer 0.1

Released on 2014-12-12 as [v0.1](https://github.com/talex5/mirage-trace-viewer/releases/tag/v0.1). See <https://github.com/talex5/mirage-trace-viewer> for full history.

Intial release, with support for:
* Reading trace data from files, Unix processes and Xen guests.
* Displaying traces using GTK or JavaScript.
* Saving traces to a file or stdout.

### mirage-v2.1.1: Improve Xen linking, MacOS X compilation and build times

Released on 2014-12-10 as [v2.1.1](https://github.com/mirage/mirage/releases/tag/v2.1.1). See <https://github.com/mirage/mirage> for full history.

* Do not reuse the Unix linker options when building Xen unikernels.  Instead,
  get the linker options from the ocamlfind `xen_linkopts` variables (#332).
  See `tcpip.2.1.0` for a library that does this for a C binding.
* Only activate MacOS X compilation by default on 10.10 (Yosemite) or higher.
  Older revisions of MacOS X will use the generic Unix mode by default, since
  the `vmnet` framework requires Yosemite or higher.
* Do not run crunched filesystem modules through `camlp4`, which significantly
  speeds up compilation on ARM platforms (from minutes to seconds!) (#299).


### mirage-v2.1.0: Specific target support for MacOS X, and bug fixes for builds

Released on 2014-12-07 as [v2.1.0](https://github.com/mirage/mirage/releases/tag/v2.1.0). See <https://github.com/mirage/mirage> for full history.

* Add specific support for `MacOSX` as a platform, which enables network bridging
  on Yosemite (#329).  The `--unix` flag will automatically activate the new target
  if run on a MacOS X host.  If this breaks for you due to being on an older version of
  MacOS X, then use the new `--target` flag to set either Unix, MacOSX or Xen to the
  `mirage configure` command.
* Add `mirage.runtime` findlib library and corresponding Mirage_runtime module (#327).
* If net driver in STACKV4_direct can't initialize, print a helpful error (#164).
* [xen]: fixed link order in generated Makefile (#322).
* Make `Lwt.tracing` instructions work for Fish shell too by improving quoting (#328).

### mirage-tcpip-v2.1.0: Add profile tracing, and better Xen stub compilation

Released on 2014-12-07 as [v2.1.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.1.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* Build Xen stubs separately, with `CFLAGS` from `mirage-xen` 2.1.0+.
  This allows us to use the red zone under x86_64 Unix again.
* Adding tracing labels and counters, which introduces a new dependency on the
  `mirage-profile` package.

### mirage-platform-v2.1.0: Add Xen tracing and improve packaging of C runtime

Released on 2014-12-07 as [v2.1.0](https://github.com/mirage/mirage-platform/releases/tag/v2.1.0). See <https://github.com/mirage/mirage-platform> for full history.

* [xen] Report trace events for GC, block_domain, XenStore and event channels.
  This introduces a new dependency on the `mirage-profile` package.
* [xen] Install a `pkg-config` file to allow other projects to compile C stubs
  against `mirage-xen`.
* [xen] Remove duplication of OCaml header files inside the `include` tree.

### mirage-profile-v0.3: mirage-profile 0.3

Released on 2014-12-06 as [v0.3](https://github.com/mirage/mirage-profile/releases/tag/v0.3). See <https://github.com/mirage/mirage-profile> for full history.

- Removed C stubs for adding timestamp on Xen. Use the new monotonic time support in mirage-xen instead.

- Use a monotonic clock on OS X (David Scott). OS X doesn't have `clock_gettime` so we use something OS X-specific.


### mirage-tcpip-v2.0.3: Remove ARP race condition and simplify DHCP client

Released on 2014-12-05 as [v2.0.3](https://github.com/mirage/mirage-tcpip/releases/tag/v2.0.3). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fixed race waiting for ARP response (#86).
* Move the the code that configures IPv4 address, netmask and gateways
  after receiving a successful lease out of the `Dhcp_clientv4` module
  and into `Stackv4` (#87)

### mirage-platform-v2.0.1: Xen stability: use monotonic time, check for page aligned I/O and add assert stubs

Released on 2014-12-05 as [v2.0.1](https://github.com/mirage/mirage-platform/releases/tag/v2.0.1). See <https://github.com/mirage/mirage-platform> for full history.

* [xen] Assert that pages passed to the grant share API are page-aligned.
  This always happens if they are created via `Io_page.create`, and
  probably not true if made by `Cstruct.create`.
* [xen] Use monotonic time for timing events, not wall-clock time.
* [xen] Provide functions that C code often uses for asserts (`abort`,
  `printf`, etc).

### ocaml-cohttp-v0.13.0: Support for the pure OCaml TLS stack in HTTP clients and servers

Released on 2014-12-05 as [v0.13.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.13.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:

* Add sexp converters for Conduit contexts and `Lwt` client and server
  modules and module types.

New Features and bug fixes:
* Can use the Conduit 0.7+ `CONDUIT_TLS=native` environment variable to
  make HTTPS requests using the pure OCaml TLS stack instead of depending
  on OpenSSL bindings.  All of the installed binaries (client and server)
  can work in this mode.
* Add `Cohttp_lwt_unix_debug` which lets libraries control the debugging
  output from Cohttp.  Previously the only way to do this was to set the
  `COHTTP_DEBUG` environment variable at the program start.
* Add `cohttp-curl-lwt` as a lightweight URI fetcher from the command-line.
  It uses the `cmdliner` as a new dependency.
* Remove build dependency check on `lwt.ssl` for `cohttp.lwt`.
  This has been moved to conduit, so only `lwt.unix` is needed here now.


### mirage-http-v2.1.0: Expose sexp converters for HTTP contexts

Released on 2014-12-05 as [v2.1.0](https://github.com/mirage/mirage-http/releases/tag/v2.1.0). See <https://github.com/mirage/mirage-http> for full history.

* Use the Conduit 0.7+ resolver API (provide `of_sexp` for context).
* Do not link against `camlp4` in the `META` file and only use it during build.

### ocaml-conduit-v0.7.1: Reduce debug logging by default

Released on 2014-12-05 as [v0.7.1](https://github.com/mirage/ocaml-conduit/releases/tag/v0.7.1). See <https://github.com/mirage/ocaml-conduit> for full history.

* Do not emit debug output when the `CONDUIT_DEBUG` variable is not set.
* Do not create symlinks in a local build, which helps with OPAM pins.
* Improve ocamldoc for `Conduit_lwt_unix`.

### mirage-profile-v0.2: mirage-profile 0.2

Released on 2014-12-05 as [v0.2](https://github.com/mirage/mirage-profile/releases/tag/v0.2). See <https://github.com/mirage/mirage-profile> for full history.

* Now supports OCaml 4.00 (doesn't use O_CLOEXEC)
* Adds support for labelled Lwt mvars

### ocaml-conduit-v0.7.0: Add native OCaml-TLS support

Released on 2014-12-04 as [v0.7.0](https://github.com/mirage/ocaml-conduit/releases/tag/v0.7.0). See <https://github.com/mirage/ocaml-conduit> for full history.

* Add Lwt-unix support for the native OCaml/TLS stack as an alternative
  to OpenSSL. This can be activated by setting the `CONDUIT_TLS` environment
  variable to `native`.  If this is not set and OpenSSL is available, then
  OpenSSL is used by in preference to the pure OCaml implementation.
* Add sexp convertors for `Conduit_lwt_unix.ctx` and `Conduit_mirage.ctx`
  and the `Resolver` service types.
* Fix the Mirage tests to the Mirage 2.0.1+ Conduit interfaces.
* Add more debugging output when the `CONDUIT_DEBUG` variable is set on Unix.
* *Interface breaking:* The `client` and `server` types in `Conduit_lwt_unix`
  now explicitly label the fields of the tuples with a polymorphic variant.
  This allows them to remain independent of this library but still be
  more self-descriptive (i.e. `Port of int` instead of just `int`).

### mirage-tc-0.2.0: More combinators

Released on 2014-12-04 as [0.2.0](https://github.com/mirage/mirage-tc/releases/tag/0.2.0). See <https://github.com/mirage/mirage-tc> for full history.

- Add bool base type-classes
- Rename I0, I1, I2, I3 to S0, S1, S2 and S3
- Expose value combinators (to mirror the functor combinators)
- Remove dependency to camlp4
- Add combinators for triples
- Rename base type-classes
- Expose more useful type-classes generators
- Add base combinators for all the type-classes
- Expose Reader.parse_error

### ocaml-git-1.4.1: Fix `ogit --version` and expose more values

Released on 2014-12-04 as [1.4.1](https://github.com/mirage/ocaml-git/releases/tag/1.4.1). See <https://github.com/mirage/ocaml-git> for full history.

* Fix `ogit --version` (#22)
* Expose the backend type
* Expose `Git_unix.Sync.IO`

### ocaml-vmnet-v1.0.1: Handle interface initialisation failure more gracefully

Released on 2014-12-02 as [v1.0.1](https://github.com/mirage/ocaml-vmnet/releases/tag/v1.0.1). See <https://github.com/mirage/ocaml-vmnet> for full history.

Instead of just hanging indefinitely, raise the `Vmnet.Error` exception when interface init fails (#1, reported by @nojb)

### mirage-tcpip-v2.0.2: Support IPv4 multicast addresses and stability fixes

Released on 2014-12-01 as [v2.0.2](https://github.com/mirage/mirage-tcpip/releases/tag/v2.0.2). See <https://github.com/mirage/mirage-tcpip> for full history.

* Add IPv4 multicast to MAC address mapping in IPv4 output processing (#81 from Luke Dunstan).
* Improve formatting of DHCP console logging, including printing out options (#83).
* Build with -mno-red-zone on x86_64 to avoid stack corruption on Xen (#80).


### mirage-net-macosx-v1.0.0: Initial public release

Released on 2014-12-01 as [v1.0.0](https://github.com/mirage/mirage-net-macosx/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-net-macosx> for full history.

MacOS X implementation of the Mirage NETWORK interface.

This interface exposes raw Ethernet frames using the
[Vmnet](https://github.com/mirage/ocaml-vmnet) framework that
is available on MacOS X Yosemite onwards.  It is suitable for
use with an OCaml network stack such as the one found at
<https://github.com/mirage/mirage-tcpip>.

For a complete system that uses this, please see the
[MirageOS](http://openmirage.org) homepage.


### ocaml-vmnet-v1.0.0: Initial public release

Released on 2014-12-01 as [v1.0.0](https://github.com/mirage/ocaml-vmnet/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-vmnet> for full history.

MacOS X 10.10 (Yosemite) introduced the somewhat undocumented `vmnet`
framework.  This exposes virtual network interfaces to userland applications.
There are a number of advantages of this over previous implementations:

- Unlike [tuntaposx](http://tuntaposx.sourceforge.net/), this is builtin
  to MacOS X now and so is easier to package up and distribute for end users.
- `vmnet` uses the XPC sandboxing interfaces and should make it easier to
  drop a hard dependency on running networking applications as `root`.
- Most significantly, `vmnet` supports bridging network traffic to the
  outside world, which was previously unsupported.

These OCaml bindings are constructed against the documentation contained
in the `<vmnet.h>` header file in Yosemite, and may not be correct due to
the lack of any other example code.  However, they do suffice to run
[MirageOS](http://openmirage.org) applications that can connect to the
outside world.  The bindings are also slightly complicated by the need
to interface [GCD](http://en.wikipedia.org/wiki/Grand_Central_Dispatch)
thread pools with the OCaml runtime, so please report any instabilities
that you see when using this interface as a consumer.

There are two libraries provided:

- `Vmnet` is the raw OCaml binding to the `vmnet` framework, using
   OCaml preemptive threads to handle synchronisation.
- `Lwt_vmnet` uses the [Lwt](http://ocsigen.org/lwt) framework to
  provide a monadic asynchronous I/O interface at a higher level.

Most users should use `Lwt_vmnet` to handle guest traffic.

### io-page-v1.2.0: Add a direct Cstruct allocation function

Released on 2014-11-28 as [v1.2.0](https://github.com/mirage/io-page/releases/tag/v1.2.0). See <https://github.com/mirage/io-page> for full history.

* Add `Io_page.get_buf` which allocates an Io_page and immediately turns it into a Cstruct that spans the entire page.
* Improve ocamldoc for exported functions.
* Add OPAM 1.2 file for easier local pinning workflow.


### ocaml-github-v0.9.3: Add repository branch query functions

Released on 2014-11-28 as [v0.9.3](https://github.com/avsm/ocaml-github/releases/tag/v0.9.3). See <https://github.com/avsm/ocaml-github> for full history.

* Add `repo_branches` and `branches` query functions (#44 from Jeff Hammerbacher).
* Improve `opam` 1.2 metadata.

### ocaml-cstruct-v1.5.0: Camlp4 is now an optional dependency on Cstruct

Released on 2014-11-24 as [v1.5.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.5.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

This release moves the `camlp4` extension to being an optional dependency, so that libraries that manipulate Cstruct values without actually specifying C structure layouts are not forced to introduce a camlp4 dependency.

* Make `camlp4` an optional build-time dependency (#35).
* Remove `ounit` as a dependency in the `opam` file.
* Improve `opam` description file for OPAM 1.2 workflow (#36).
* Refresh Merlin IDE description (#37).

### mirage-v2.0.1: Add Tracing support

Released on 2014-11-21 as [v2.0.1](https://github.com/mirage/mirage/releases/tag/v2.0.1). See <https://github.com/mirage/mirage> for full history.

* Add `register ~tracing` to enable tracing with mirage-profile at start-up (#321).
* Update Dockerfile for latest libraries (#320).
* Only build mirage-types if Io_page is also installed (#324).


### mirage-xen-minios-v0.4.2: Add explicit section for boot loader

Released on 2014-11-21 as [v0.4.2](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.4.2). See <https://github.com/mirage/mirage-xen-minios> for full history.

This adds an explicit linker section for the boot code, meaning we can ensure it always appears at the start of the image without requiring minios.a to be first in the linker command, which in turn allows untangling the linker command generated by mirage. 

### ezjsonm-0.3.1: Expose [parse_error]

Released on 2014-11-20 as [0.3.1](https://github.com/mirage/ezjsonm/releases/tag/0.3.1). See <https://github.com/mirage/ezjsonm> for full history.

* Expose [parse_error]

### ocaml-git-v1.4.0: Use latest Conduit API

Released on 2014-11-20 as [v1.4.0](https://github.com/mirage/ocaml-git/releases/tag/v1.4.0). See <https://github.com/mirage/ocaml-git> for full history.

* Port to Conduit 0.6.0 API.
* Depend on `ocaml-hex`


### mirage-profile-v0.1: mirage-profile-0.1

Released on 2014-11-12 as [v0.1](https://github.com/mirage/mirage-profile/releases/tag/v0.1). See <https://github.com/mirage/mirage-profile> for full history.

Initial release. Mirage-profile can be compiled with or without Lwt tracing. If compiled without, it generates stubs with no runtime overhead. With tracing support, it writes to a CTF-format ring buffer, which can be shared with a collection system.

### ocaml-github-v0.9.2: Improved log error messages

Released on 2014-11-09 as [v0.9.2](https://github.com/avsm/ocaml-github/releases/tag/v0.9.2). See <https://github.com/avsm/ocaml-github> for full history.

* Better log error messages (#39).
* Tweak Makefile to build JavaScript version by default if `js_of_ocaml` is installed.


### mirage-http-v2.0.0: Mirage 2.0 compatible HTTP interface

Released on 2014-11-07 as [v2.0.0](https://github.com/mirage/mirage-http/releases/tag/v2.0.0). See <https://github.com/mirage/mirage-http> for full history.

* Use the Conduit 0.6+ resolver API.
* Add a local `opam` file for the OPAM 1.2.0 workflow.

### ocaml-conduit-v0.6.1: Improve connection closing semantics

Released on 2014-11-07 as [v0.6.1](https://github.com/mirage/ocaml-conduit/releases/tag/v0.6.1). See <https://github.com/mirage/ocaml-conduit> for full history.

When terminating conduits, always close the output channel first before the input channel, so that any pending data in the underlying fd is flushed.


### ocaml-cohttp-v0.12.0: Add JavaScript and StringIO backends, and numerous interface improvements

Released on 2014-11-05 as [v0.12.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.12.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:

* Rename `Cohttp.Auth.t` to `Cohttp.Auth.credential` and `Cohttp.Auth.req`
  to `Cohttp.Auth.challenge`.  Also expose an `Other` variant
  to make it more extensible for unknown authentication types. The
  `Cohttp.Auth` functions using these types have also been renamed accordingly.
* Rename `Cohttp.Transfer.encoding_to_string` to `string_of_encoding`
  for consistency with the rest of Cohttp's APIs.
* The `has_body` function in the Request and Response modules now
  explicitly signals when the body size is unknown.
* Move all the module type signatures into `Cohttp.S`.
* If users have percent-encoded file names, their resolution is changed:
 `resolve_local_file` in `Cohttp_async` and `Cohttp_lwt` now always
  percent-decode paths (#157)
* Remove the `Cohttp_lwt.Server.server` type synonym to `t`.
* When reading data from a HTTP body stream using the `Fixed` encoding,
  we need to maintain state (bytes remaining) so we know when to finish.
  The `Cohttp.Request` and `Cohttp.Response` interfaces now expose a
  `reader` and `writer` types to track this safely.
* Add `is_empty` function to the `Cohttp.S.Body` module type.
* Add `Strings` representation to `Cohttp.Body` to efficiently hold a
  list of body chunks.
* Move flushing logic for HTTP bodies into the portable `Request` and
  `Response` modules instead of individual Lwt and Async backends.
* Port module interfaces to the latest Conduit (0.6.0+) API.
* Cohttp requires OCaml 4.01.0 or higher now.

New features and bugfixes:

* Add a `Cohttp_lwt_xhr` JavaScript backend that enables Cohttp logic to be
  mapped to `XMLHTTPRequest` in browsers via `js_of_ocaml` (via Andy Ray).
* Add a `Cohttp.String_io` and `String_io_lwt` module that uses OCaml
  `string` or `Buffer.t` to read and write HTTP requests and responses
  instead of network connections.
* `cohttp_server_lwt` and `cohttp_server_async` now return better errors (#158)
* `cohttp_server_lwt` and `cohttp_server_async` now serve indexes directly (#162)
* [lwt] Add `stop` thread to terminate a running server if it finishes (#147).
* Add `Cohttp.Connection.compare` to make ordering of connections possible.
* Add `Body.map` and `Body.as_pipe` to work with HTTP bodies more easily.
* Remove link-time dependency on camlp4 via META fixes (#127).
* Support HTTP methods and versions other than the standard ones. (#142).
* Improve `cohttp_server_lwt` and `cohttp_server_async` directory listings (#158)
* Fix `Cohttp_async.resolve_local_file` directory traversal vulnerability (#158)
* [async] In the Async server, do not close the Reader too early.
* [async] Close file descriptors more eagerly in the HTTP client (#167).
* Reduce thread allocation by replacing `return <const>` with `return_none`,
  `return_unit` or `return_nil`.


### mirage-tcpip-v2.0.1: Improve behaviour under heavy load

Released on 2014-11-03 as [v2.0.1](https://github.com/mirage/mirage-tcpip/releases/tag/v2.0.1). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fixed race condition in the signalling between the rx/tx threads under load.
* Experimentally switch to immediate ACKs in TCPv4 by default instead of delayed ones.

### ocaml-github-v0.9.1: Fix support for draft Releases

Released on 2014-11-03 as [v0.9.1](https://github.com/avsm/ocaml-github/releases/tag/v0.9.1). See <https://github.com/avsm/ocaml-github> for full history.

Mark `published_at` and `created_at` fields in Releases to be optional, as they may not be set in the case of draft tags.


### mirage-platform-v2.0.0: Add Xen/ARM support, depend on external MiniOS library, install runtime headers

Released on 2014-11-03 as [v2.0.0](https://github.com/mirage/mirage-platform/releases/tag/v2.0.0). See <https://github.com/mirage/mirage-platform> for full history.

* Remove dietlibc, libm and most of the include files, replacing them with
  external dependencies on Mini-OS and openlibm.
* Introduce Xen/ARM support that works with both Xen 4.4 and the 4.5dev
  hypervisor ABI.  Testing on Cubieboard2 and Cubietruck devices.
* [xen] Move the Xen main Lwt loop into OCaml code to simplify it (#99).
* Build fixes to work with multiple findlib directories in a single
  installation (#101 from Petter Urkedal).
* [xen] Install runtime headers for `mirage-xen` so that external C
  libraries can be compiled (#102 from James Bielman)
* [xen] Add support for demand-mapping for backend devices via a MiniOS
  gntmap device (#103).


### ocaml-vchan-v2.0.0: Add Unix and Mirage backends and improve interoperability

Released on 2014-11-03 as [v2.0.0](https://github.com/mirage/ocaml-vchan/releases/tag/v2.0.0). See <https://github.com/mirage/ocaml-vchan> for full history.

* add `Vchan_lwt_unix` with instantiation of functor
* make Vchan.Port.t abstract (previously was a string)
* use the same Xenstore path convention as `libxenvchan.h`
* support channel closing, `Eof etc
* define an `ENDPOINT` signature for a Vchan.


### mirage-v2.0.0: Support for Mirage 2.0 libraries (Vchan, Conduit, Resolver) and CLI improvements

Released on 2014-11-03 as [v2.0.0](https://github.com/mirage/mirage/releases/tag/v2.0.0). See <https://github.com/mirage/mirage> for full history.

Backwards incompatible changes to V1 types:
* `CONSOLE` is now a `FLOW`, so `write` has a different signature and 'write_all' has been removed.

New features in the CLI and config parser:
* Set on_crash = 'preserve' in default Xen config.
* Automatically install dependencies again, but display the live output to the user.
* Include C stub libraries in linker command when generating Makefiles for Xen.
* Add `Vchan`, `Conduit` and `Resolver` code generators.
* Generate a `*.xe` script which can upload a kernel to a XenServer.
* Generate a libvirt `*.xml` configuration file (#292).
* Fix determination of `mirage-xen` location for paths with spaces (#279).
* Correctly show config file locations when using a custom one.
* Fix generation of foreign (non-functor) modules (#293)


### ocaml-dns-v0.11.0: Add Async resolver and reduce Io_page dependencies 

Released on 2014-11-03 as [v0.11.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.11.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Do not depend in Io_page; instead `Dns.Buf.create` now accepts an
  optional `alloc` parameter to use a custom allocator such as `Io_page`.
* Add Async DNS resolver modules from @marklrh (#22).
* Add a Dns_resolver_mirage.Static for a static DNS interface.


### mirage-tcpip-v2.0.0: Mirage 2.0 compatible TCP/IP release, and socket backend fixes

Released on 2014-11-03 as [v2.0.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.0.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* Moved 1s complement checksum C code here from mirage-platform.
* Depend on `Console_unix` and `Console_xen` instead of `Console`.
* [socket] Do not return an `Eof` when writing 0-length buffer (#76).
* [socket] Accept callbacks now run in async threads instead of being serialised (#75).

### cowabloga-v0.0.8: Adapt to newer Conduit 0.6.0+ APIs

Released on 2014-11-02 as [v0.0.8](https://github.com/mirage/cowabloga/releases/tag/v0.0.8). See <https://github.com/mirage/cowabloga> for full history.

No change aside from adding support for Conduit 0.6 APIs used in Mirage 2.0.0 and later.

### ocaml-github-v0.9.0: Add Gist bindings and JavaScript compilation support

Released on 2014-11-02 as [v0.9.0](https://github.com/avsm/ocaml-github/releases/tag/v0.9.0). See <https://github.com/avsm/ocaml-github> for full history.

* Add `Jar_cli` module for use by applications that use the Git Jar (#34).
* Add bindings to the Gist APIs for storing text fragments (#36).
* Add a JavaScript port, using Cohttp and js_of_ocaml (#36).
* Build `ocamldoc` HTML documentation by default.

### ocaml-conduit-v0.6.0: Significant interface improvements for Lwt, Async and Mirage

Released on 2014-11-02 as [v0.6.0](https://github.com/mirage/ocaml-conduit/releases/tag/v0.6.0). See <https://github.com/mirage/ocaml-conduit> for full history.

* Add an explicit `ctx` content to track every conduit's runtime state.
* Allow the source interface for a conduit to be set.
* Support a `password` callback for the SSL layer (#4).
* [lwt] Add stop parameters in main-loop of the server (#5).
* Add `Conduit_mirage` with Mirage functor suport.
* Add ocamldoc of most interfaces.
* Add a `CONDUIT_DEBUG` environment variable to the Unix backends for
  live debugging.
* Add a `conn` value to the callback to query more information about the
  current connection (#2).
* Expose the representation of `Conduit_lwt_unix.flow` in the external signature.
  This lets library users obtain the original `Lwt_unix.file_descr` when using
  Conduit libraries like Cohttp.


### mirage-console-2.0.0: Improved build scripts and satisfy the FLOW interface.

Released on 2014-10-31 as [2.0.0](https://github.com/mirage/mirage-console/releases/tag/2.0.0). See <https://github.com/mirage/mirage-console> for full history.

* enable travis (for both xen and unix cases)
* fix dependencies: drop mirage-{xen,unix}; keep dependencies on implementation
  libraries and mirage-types
* switch build to OASIS
* add command-line tool to attach consoles
* add experimental support for named consoles
* add support for reading from consoles (so we can do user interaction)
* [xen] support connecting to additional (named) consoles
* [xen] don't zero the initial console ring
* install findlib packages as `mirage-console.[xen/unix]`

### ocaml-tls-0.2.0: pre halloween special

Released on 2014-10-30 as [0.2.0](https://github.com/mirleft/ocaml-tls/releases/tag/0.2.0). See <https://github.com/mirleft/ocaml-tls> for full history.

* expose trust anchor when authenticating the certificate (requires x509 >= 0.2)
* information about the active session is exposed via epoch : state -> epoch
* distinguish between supported ciphersuites (type ciphersuite) and
  known ciphersuites (type any_ciphersuite)
* distinguish between supported versions by the stack (type tls_version)
  and readable versions (tls_any_version), which might occur in a tls
  record or client_hello read from the network
* support > TLS-1.2 client hellos (as reported by ssllabs.com)
* support iOS 6 devices (who propose NULL ciphers - reported in #160)
* send minimal protocol version in record layer of client hello
  (maximum version is in the client hello itself) (RFC5246, E.1)

### ocaml-x509-0.2.0: bug fix release

Released on 2014-10-30 as [0.2.0](https://github.com/mirleft/ocaml-x509/releases/tag/0.2.0). See <https://github.com/mirleft/ocaml-x509> for full history.

from CHANGES.md:
* expose Certificate.cert_hostnames, wildcard_matches
* Certificate.verify_chain_of_trust and X509.authenticate both return now
  [ `Ok of certificate | `Fail of certificate_failure ], where [certificate] is the trust anchor


### mirage-tc-0.1.0: Initial release

Released on 2014-10-25 as [0.1.0](https://github.com/mirage/mirage-tc/releases/tag/0.1.0). See <https://github.com/mirage/mirage-tc> for full history.

### mirage-xen-minios-v0.4.1: Fix x86 timers

Released on 2014-10-24 as [v0.4.1](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.4.1). See <https://github.com/mirage/mirage-xen-minios> for full history.

Get time values from Xen on x86. This means that gettimeofday should now return correct values, not seconds since boot

### ezjsonm-0.3.0: more helper functions

Released on 2014-10-24 as [0.3.0](https://github.com/mirage/ezjsonm/releases/tag/0.3.0). See <https://github.com/mirage/ezjsonm> for full history.

* Add sexpilb conversion functions
* Add functions to encode/decode non utf8 strings (using hex encoding)

### ocaml-hex-0.1.0: Initial release

Released on 2014-10-24 as [0.1.0](https://github.com/mirage/ocaml-hex/releases/tag/0.1.0). See <https://github.com/mirage/ocaml-hex> for full history.

### ocaml-git-1.3.0: Remove core_kernel dependency and use nocrypto

Released on 2014-10-20 as [1.3.0](https://github.com/mirage/ocaml-git/releases/tag/1.3.0). See <https://github.com/mirage/ocaml-git> for full history.

* Remove the dependency towards core_kernel
* Use ocaml-nocrypto instead of ocaml-sha1


### mirage-fs-unix-v1.1.3: Fixes in FS_unix.create and FS_unix.write

Released on 2014-10-16 as [v1.1.3](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.1.3). See <https://github.com/mirage/mirage-fs-unix> for full history.

* Fixes FS_unix.create and FS_unix.write

### ocaml-mstruct-1.3.1: Fix Mstruct.to_bigarray and add Cstruct conversion functions

Released on 2014-10-16 as [1.3.1](https://github.com/mirage/ocaml-mstruct/releases/tag/1.3.1). See <https://github.com/mirage/ocaml-mstruct> for full history.

* Add Mstruct.to_cstruct, Mstruct.of_cstruct and Mstruct.with_mstruct
* Fix Mstruct.to_bigarray to return the current window instead of the whole bigarray

### mirage-block-xen-v1.2.0: Higher throughput via indirect descriptors

Released on 2014-10-03 as [v1.2.0](https://github.com/mirage/mirage-block-xen/releases/tag/v1.2.0). See <https://github.com/mirage/mirage-block-xen> for full history.

* blkback: add 'force_close' to more forcibly tear down the device
* blkback: make 'destroy' idempotent
* blkback: measure ring utilisation; segments per request; total
  requests and responses (ok and error)
* blkback: support indirect descriptors (i.e. large block sizes)
* blkfront: if the 'connect' string is at all ambiguous, fail rather
  than risk using the wrong disk
* blkfront: use indirect segments if available

### mirage-xen-minios-v0.4: Fix ARM timers and add experimental demand paging

Released on 2014-09-26 as [v0.4](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.4). See <https://github.com/mirage/mirage-xen-minios> for full history.

* Fixes ARM timer interrupt by activating it at boot
* Add experimental support for demand paging to let MiniOS act as a page backend (primarily for vchan)

### mirage-fs-unix-v1.1.2: Fix quadratic behavior

Released on 2014-09-11 as [v1.1.2](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.1.2). See <https://github.com/mirage/mirage-fs-unix> for full history.

* Fix quadratic behavior (#5)

### ocaml-dns-v0.10.0: Mirage DNS resolver support and more examples

Released on 2014-08-28 as [v0.10.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.10.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Add `Dns_resolver_mirage` module for making stub resolution requests
  using the Mirage module types.
* `Dns.Resolvconf` parses `/etc/resolv.conf` entries using `Ipaddr.t`
  instead of `string` values now.
* Adapt `Dns_resolver` and `Dns_resolver_unix` to use `Ipaddr.t` more.
* Improve `mldig` to use `Ipaddr` more and add more RR printing to
  match the conventional `dig` tool behaviour.
* Expose `Dns.Packet.Not_implemented` exception rather than a pattern
  match failure.
* Depend on external `Base64` package instead of bundling one inside
  the `Dns` packed module.
* Add a local `opam` file for easier pinning.
* Add an `examples/` directory with a DNS forwarder sample (#21).


### ocaml-cow-v1.0.0: First stable release

Released on 2014-08-26 as [v1.0.0](https://github.com/mirage/ocaml-cow/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Fix OCaml 4.02 compatibility by not exposing a `Location` module
  in syntax extensions to avoid a namespace clash. We now rename them
  to `Xml_location` and `Css_location` and pack those instead.
* Fix BSD compatibility using `$(MAKE)` instead of `make` (since the
  GNU make binary is actually `gmake` on Free/Net/OpenBSD).
* Reduce the verbosity of the build by default.
* Travis: Add OCaml 4.02 and OPAM 1.2.0 tests


### ocaml-mbr-v0.2: First Mirage release

Released on 2014-08-18 as [v0.2](https://github.com/mirage/ocaml-mbr/releases/tag/v0.2). See <https://github.com/mirage/ocaml-mbr> for full history.

* add Mbr_partition: V1_LWT.BLOCK, for easy access to partitions via
  the standard Mirage block interface.
* use a polymorphic variant result type [`Ok of 'a | `Error of 'b]

### mirage-xen-minios-v0.3: Stability and performance improvements

Released on 2014-08-14 as [v0.3](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.3). See <https://github.com/mirage/mirage-xen-minios> for full history.

* Update to `openlibm-0.4` and `libminios-0.3`, which includes a larger stack size and stack overflow detection on ARM now.
* Build minios without debug mode by default, since this disabled all optimisations in earlier versions.

### ocaml-uri-v1.7.2: Functional mutator bug fixes

Released on 2014-08-10 as [v1.7.2](https://github.com/mirage/ocaml-uri/releases/tag/v1.7.2). See <https://github.com/mirage/ocaml-uri> for full history.

* Fix empty-but-existing query ("?") parsing bug
* Fix `with_userinfo` against hostless URI representation bug
* Fix `with_port` against hostless URI representation bug
* Fix `with_path` with relative path against hosted URI representation bug (#51)
* Fix `make` without host but with userinfo or port representation bug
* Fix `make` with host, userinfo, or port and relative path representation bug

In sum, the library will now try to guide the user to using an abstract value that is actually serializable.

### ocaml-cstruct-v1.4.0: Comprehensive bounds checking for all operations

Released on 2014-08-10 as [v1.4.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.4.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

Comprehensive addition of bounds checking to all cstruct operations (from @pqwy in #33).  The major API-facing changes are:
* Disallow negative indexing with all cstruct accessors.
* Disallow negative `sub` and `shift` operations.
* Make sure `of_bigarray` cannot create invalid `cstruct` values.

This may break some older `cstruct` consumers that assumed that negative shifts were allowed, and so the version has been bumped to 1.4.0.


### ocaml-cow-v0.10.1: Xml.of_string "" bugfix release

Released on 2014-08-10 as [v0.10.1](https://github.com/mirage/ocaml-cow/releases/tag/v0.10.1). See <https://github.com/mirage/ocaml-cow> for full history.

`Cow.Xml.of_string ""` was throwing `Invalid_argument` due to the assumption that the string to parse was not zero length in the check for a trailing ampersand. This release fixes that bug and turns debugging information on by default.

### ocaml-github-v0.8.6: Add git-create-release

Released on 2014-08-10 as [v0.8.6](https://github.com/avsm/ocaml-github/releases/tag/v0.8.6). See <https://github.com/avsm/ocaml-github> for full history.

* Fix `pull_action_type` `synchronize` tag typo (#33 from Philipp Gesang).
* Add a `git create-release` to create a GitHub release, including binary assets
  (#32 from Markus Mottl).


### mirage-net-xen-v1.1.3: Restore parallel writes to net ring

Released on 2014-08-08 as [v1.1.3](https://github.com/mirage/mirage-net-xen/releases/tag/v1.1.3). See <https://github.com/mirage/mirage-net-xen> for full history.

Revert the serialization in 1.1.2 as Xen/ARM (4.5 and backport to 4.4) has been fixed to support granting the same page multiple times. Backport is in https://github.com/mirage/xen-arm-builder.


### ocaml-conduit-v0.5.1: Enable Async SSL support

Released on 2014-08-07 as [v0.5.1](https://github.com/mirage/ocaml-conduit/releases/tag/v0.5.1). See <https://github.com/mirage/ocaml-conduit> for full history.

This release reenables Async SSL by default, since the upstream bug that prevented linking from working reliably has been fixed.


### ocaml-ctypes-0.3.3: ocaml-ctypes 0.3.3

Released on 2014-08-01 as [0.3.3](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.3.3). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.



### ocaml-dns-v0.9.1: Fix file descriptor leak in resolver

Released on 2014-07-29 as [v0.9.1](https://github.com/mirage/ocaml-dns/releases/tag/v0.9.1). See <https://github.com/mirage/ocaml-dns> for full history.

Fix file descriptor leak in resolver (#15, #16) by expanding `commfn` with a cleanup function.

### mirage-net-xen-v1.1.2: Writev blocking semantics improved

Released on 2014-07-23 as [v1.1.2](https://github.com/mirage/mirage-net-xen/releases/tag/v1.1.2). See <https://github.com/mirage/mirage-net-xen> for full history.

Wait for packets to be processed by the backend before returning from a `writev` call. Without this, the caller has no way to know when it's safe to reuse the buffer (#11).


### mirage-fs-unix-v1.1.1: Implement POSIX root directory semantics

Released on 2014-07-21 as [v1.1.1](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.1.1). See <https://github.com/mirage/mirage-fs-unix> for full history.

Traversal outside of the exposed POSIX directory is now prohibited. Additionally, the root directory is now its own parent, i.e. `/../ -> /`.

### mirage-tcpip-v1.1.6: More robust TCP options parsing

Released on 2014-07-20 as [v1.1.6](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.6). See <https://github.com/mirage/mirage-tcpip> for full history.

* Quieten down the stack logging rate by not announcing IPv6 packet discards.
* Raise exception `Bad_option` for unparseable or invalid TCPv4 options (#57).
* Fix linking error with module `Tcp_checksum` by lifting it into top library (#60).
* Add `opam` file to permit easier local pinning, and fix Travis to use this.


### mirage-xen-minios-v0.2: Initial public release

Released on 2014-07-18 as [v0.2](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.2). See <https://github.com/mirage/mirage-xen-minios> for full history.

This repository contains the scripts to install the library dependencies required
by the MirageOS Xen backend.  It contains:

* An unofficial fork of Mini-OS, a small operating system kernel that
  runs as a Xen guest. Mini-OS is part of Xen, but for convenience the
  non-Mini-OS parts have been deleted for this library.
  <https://github.com/talex5/xen/releases/tag/minios-v0.2>

* OpenLibM, from the upstream master, but forked in order to have a
  stable tag while waiting for an upstream release.
  <https://github.com/talex5/openlibm/releases/tag/v0.3.1-tal1>


### ocaml-vchan-v1.0.0: Stable release

Released on 2014-07-16 as [v1.0.0](https://github.com/mirage/ocaml-vchan/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-vchan> for full history.

* test VM: uses the V1_LWT.FLOW signature


### shared-memory-ring-1.1.0: Interface now supports xenstore ring reconnection

Released on 2014-07-16 as [1.1.0](https://github.com/mirage/shared-memory-ring/releases/tag/1.1.0). See <https://github.com/mirage/shared-memory-ring> for full history.

In order to reconnect to an existing (xenstore) ring after a restart we must avoid (i) removing data which we haven't persisted somewhere; and (ii) avoid writing the same chunk of data twice. We make this possible by exposing a 'type position' and using this in both 'read' and 'write'. The position represents the current offset in the data stream. The position is manually advanced by the client via the 'advance' function.

### cowabloga-v0.0.7: Support multiple authors

Released on 2014-07-12 as [v0.0.7](https://github.com/mirage/cowabloga/releases/tag/v0.0.7). See <https://github.com/mirage/cowabloga> for full history.

Add support for multi-author blog posts (#19 via @pqwy).

### ocaml-cstruct-v1.3.1: Bounds checks on single-byte views

Released on 2014-07-10 as [v1.3.1](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.3.1). See <https://github.com/mirage/ocaml-cstruct> for full history.

Also bounds test single-byte operations on views (#31 via @pqwy).


### mirage-v1.2.0: Simpler configuration and Entropy interface

Released on 2014-07-07 as [v1.2.0](https://github.com/mirage/mirage/releases/tag/v1.2.0). See <https://github.com/mirage/mirage> for full history.

The Mirage frontend tool now generates a Makefile with a `make depend`
target, instead of directly invoking OPAM as part of `mirage configure`.
This greatly improves usability on slow platforms such as ARM, since the
output of OPAM as it builds can be inspected more easily.  Users will now
need to run `make depend` to ensure they have the latest package set,
before building their unikernel with `make` as normal.

* Improve format of generated Makefile, and also colours in terminal output.
* Add `make depend` target to generated Makefile.
* Set `OPAMVERBOSE` and `OPAMYES` in the Makefile, which can be overridden.
* Add an `ENTROPY` device type for strong random sources (#256).


### ocaml-x509-0.1.0: Initial release

Released on 2014-07-07 as [0.1.0](https://github.com/mirleft/ocaml-x509/releases/tag/0.1.0). See <https://github.com/mirleft/ocaml-x509> for full history.

### ocaml-tls-0.1.0: Initial release

Released on 2014-07-07 as [0.1.0](https://github.com/mirleft/ocaml-tls/releases/tag/0.1.0). See <https://github.com/mirleft/ocaml-tls> for full history.

### mirage-entropy-0.1.6: event-driven and xen implementation

Released on 2014-07-06 as [0.1.6](https://github.com/mirage/mirage-entropy/releases/tag/0.1.6). See <https://github.com/mirage/mirage-entropy> for full history.

### ocaml-cstruct-v1.3.0: Sexp converters for Cstruct and improved bounds checking

Released on 2014-07-05 as [v1.3.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.3.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

* Add bounds checks for `Cstruct.BE/LE` functions that violate a view.
  Previously, only bounds errors on the underlying buffers would raise.
  Bug #25, reported by Mindy Preston in mirage/mirage-tcpip#56.
* Add 'Lwt_cstruct.complete' to ensure that `read`/`write` operatiosn
  run to completion.
* Add `Sexplib` conversion functions to `Cstruct.t` values (#27 #22).


### ocaml-uri-v1.7.1: Add support for IPv6 literals with zones

Released on 2014-07-05 as [v1.7.1](https://github.com/mirage/ocaml-uri/releases/tag/v1.7.1). See <https://github.com/mirage/ocaml-uri> for full history.

Add RFC6874 compliance for IPv6 literals with zones (#48 by @vbmithr).


### ocaml-ctypes-0.3.2: ocaml-ctypes 0.3.2

Released on 2014-07-04 as [0.3.2](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.3.2). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.

### mirage-entropy-0.1.4: rename modules, provide interfaces

Released on 2014-07-04 as [0.1.4](https://github.com/mirage/mirage-entropy/releases/tag/0.1.4). See <https://github.com/mirage/mirage-entropy> for full history.

### mirage-entropy-0.1.3: unbreak installation

Released on 2014-07-03 as [0.1.3](https://github.com/mirage/mirage-entropy/releases/tag/0.1.3). See <https://github.com/mirage/mirage-entropy> for full history.

### mirage-entropy-0.1.2: minor changes

Released on 2014-07-03 as [0.1.2](https://github.com/mirage/mirage-entropy/releases/tag/0.1.2). See <https://github.com/mirage/mirage-entropy> for full history.

use /dev/urandom instead of /dev/random on unix

### mirage-entropy-0.1.1: move to Makefile

Released on 2014-07-03 as [0.1.1](https://github.com/mirage/mirage-entropy/releases/tag/0.1.1). See <https://github.com/mirage/mirage-entropy> for full history.

no functional changes, just a switch to another build system

### ocaml-ctypes-0.3.1: ocaml-ctypes 0.3.1

Released on 2014-07-03 as [0.3.1](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.3.1). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.

### mirage-entropy-0.1.0: Initial release

Released on 2014-07-03 as [0.1.0](https://github.com/mirage/mirage-entropy/releases/tag/0.1.0). See <https://github.com/mirage/mirage-entropy> for full history.

Initial release of the mirage-entropy device

### mirage-tcpip-v1.1.5: Stability fixes to TCPv4 and DHCP handling

Released on 2014-07-01 as [v1.1.5](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.5). See <https://github.com/mirage/mirage-tcpip> for full history.

* Ensure that DHCP completes before the application is started, so that
  unikernels that establish outgoing connections can do so without a race.
  (fix from Mindy Preston in #53, followup in #55)
* Add `echo`, `chargen` and `discard` services into the `examples/`
  directory. (from Mindy Preston in #52).
* [tcp] Fully process the last `ACK` in a 3-way handshake for server connections.
  This ensures that a `FIN` is correctly transmitted upon application-initiated
  connection close. (fix from Mindy Preston in #51).



### irmin-0.8.3: Improve View.merge_path + dump graphs improvement

Released on 2014-06-25 as [0.8.3](https://github.com/mirage/irmin/releases/tag/0.8.3). See <https://github.com/mirage/irmin> for full history.

* Support backend specific protocols for push/pull
* The Irmin Git backend can now sync with remote Git repositories
* Simplify the organisation of the libraries: irmin, irmin.backend,
  irmin.server and irmin.unix (check how the example are compiled)
* Small refactoring to ease the use of the API. Now use `open Irmin_unix`
  at the top of your file and use less functor in your code (again,
  check the examples)

### ocaml-vchan-v0.9.7: The Mirage FLOW release

Released on 2014-06-18 as [v0.9.7](https://github.com/mirage/ocaml-vchan/releases/tag/v0.9.7). See <https://github.com/mirage/ocaml-vchan> for full history.

* cli: server: choose a sensible default xenstore path
* cli: server: set the xenstore permissions correctly
* cli: client: don't assume we have perms to read the directory
* Implement Mirage V1_LWT.FLOW signature

### ocaml-dns-v0.9.0: Fixes for Xen/Mirage backend

Released on 2014-06-17 as [v0.9.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.9.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Ensure that all `Dns.Buf.t` buffers are page-aligned, via `Io_page`.
* Remove a Unix dependency that snuck into the `Dns_resolver` portable core, by adding a timeout argument to the `commfn` type.
* Improve ocamldoc in `Dns_resolver_unix`.


### ocaml-xenstore-clients-0.9.4: Now supports XENSTORED_PATH and the xenbus device

Released on 2014-06-16 as [0.9.4](https://github.com/djs55/ocaml-xenstore-clients/releases/tag/0.9.4). See <https://github.com/djs55/ocaml-xenstore-clients> for full history.

0.9.4 (16-Jun-2014):
* use the xenbus device if the Unix domain socket isn't available
* respect the XENSTORED_PATH environment variable

### ocaml-uri-v1.7.0: Expose known services via values in Uri_services

Released on 2014-06-16 as [v1.7.0](https://github.com/mirage/ocaml-uri/releases/tag/v1.7.0). See <https://github.com/mirage/ocaml-uri> for full history.

Expose the list of known services in the `Uri_services` and `Uri_services_full` modules via new functions that list TCP, UDP and an association list of both.

This permits libraries to fold over the list of services in their own uses.


### ocaml-lazy-trie-1.1.0: sexplib

Released on 2014-06-15 as [1.1.0](https://github.com/mirage/ocaml-lazy-trie/releases/tag/1.1.0). See <https://github.com/mirage/ocaml-lazy-trie> for full history.

* Add sexplib serializers to the trie.

### ocaml-vchan-v0.9.6: Bugfix release

Released on 2014-06-15 as [v0.9.6](https://github.com/mirage/ocaml-vchan/releases/tag/v0.9.6). See <https://github.com/mirage/ocaml-vchan> for full history.

* depend on mirage-types.lwt rather than mirage

### mirage-1.1.3: Add FLOW signature

Released on 2014-06-15 as [1.1.3](https://github.com/mirage/mirage/releases/tag/1.1.3). See <https://github.com/mirage/mirage> for full history.

* Build OPAM packages in verbose mode by default.
* [types] Add FLOW based on TCPV4
* travis: build mirage-types from here, rather than 1.1.0

### ocaml-vchan-v0.9.5: Build Unix CLI by default

Released on 2014-06-14 as [v0.9.5](https://github.com/mirage/ocaml-vchan/releases/tag/v0.9.5). See <https://github.com/mirage/ocaml-vchan> for full history.

0.9.5 (2014-06-14)
* build the CLI by default

0.9.4 (2014-04-29):
* Update to mirage-1.1.0.

### irmin-0.8.2: Support backend-specific push/pull protocols

Released on 2014-06-11 as [0.8.2](https://github.com/mirage/irmin/releases/tag/0.8.2). See <https://github.com/mirage/irmin> for full history.

* Support backend specific protocols for push/pull
* The Irmin Git backend can now sync with remote Git repositories
* Simplify the organisation of the libraries: irmin, irmin.backend,
  irmin.server and irmin.unix (check how the example are compiled)
* Small refactoring to ease the use of the API. Now use `open Irmin_unix`
  at the top of your file and use less functor in your code (again,
  check the examples)

### ocaml-git-1.2.0: Compatibility with the Mirage's V1_LWT.FS signature

Released on 2014-06-09 as [1.2.0](https://github.com/mirage/ocaml-git/releases/tag/1.2.0). See <https://github.com/mirage/ocaml-git> for full history.

* Can consume Mirage's V1_LWT.FS signature to generate a
  persistent store. This allows to store Git repos directly
  inside raw block devices (no need of filesystem anymore).
* Minor API refactoring to abstract the unix layer cleanly
* Expose a filesystem functor to create filesystem backends
  independent of unix
* Simplify the ocamlfind packages: there's only git and git.unix

### mirage-fs-unix-v1.1.0: Add FS_unix (loopback implementation of V1_LWT.FS)

Released on 2014-06-09 as [v1.1.0](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-fs-unix> for full history.

### ocaml-cstruct-v1.2.0: Add `sexp` decorator for cenum values

Released on 2014-06-08 as [v1.2.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.2.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

Add a `sexp` optional decorator to `cenum` to output the values as s-expressions.
This is compatible with the `sexplib` convention.  The syntax is;

```
cenum foo64 {
  ONE64;
  TWO64;
  THREE64
} as uint64_t(sexp)
```

And `sexp_of_foo64` and `foo64_of_sexp` functions will also be available.
The representation of the Sexp is the string representation of the enum.


### ezxmlm-v1.0.1: Add XML sub-tree membership test function

Released on 2014-06-03 as [v1.0.1](https://github.com/avsm/ezxmlm/releases/tag/v1.0.1). See <https://github.com/avsm/ezxmlm> for full history.

* Add `has_member` function to test if a tag is present in sub-nodes (from #1)
* Add Travis CI scripts.
* Regenerate OASIS build files with 0.4.4 (better dynlink support)


### irmin-0.8.1: Javascript graphs & fix IrminMemory.create to create a shared store

Released on 2014-06-02 as [0.8.1](https://github.com/mirage/irmin/releases/tag/0.8.1). See <https://github.com/mirage/irmin> for full history.

* Fix the behavior of `IrminMemory.Make` to return an hanlder to a
  shared datastore instead of creating a fresh one. Add
  `IrminMemory.Fresh` to return a fresh in-memory datastore maker.
* The HTTP server now outputs some nice graph (using dagre-d3). Don't
  expect to display very large graphs
* More friendly tag names in the Git backend (no need to prefix
  everything by `refs/heads/` anymore)
* Partial support for recursive stores (WIP)

### ocaml-git-1.1.0: Basic push support (unix only for now on)

Released on 2014-06-02 as [1.1.0](https://github.com/mirage/ocaml-git/releases/tag/1.1.0). See <https://github.com/mirage/ocaml-git> for full history.

* Support for push (not optimized at all)
* Fix the generation of `.dot` file representing the Git repo
* Fix serialization of executable files in the cache
* Fix reading the total number of keys in a pack index file
* Use `ocaml-conduit` to set-up connections with remote repositories
* USe `ocaml-uri` to specify Git Remote Identifiers


### mirage-net-unix-v1.1.1: Improved error messages

Released on 2014-05-30 as [v1.1.1](https://github.com/mirage/mirage-net-unix/releases/tag/v1.1.1). See <https://github.com/mirage/mirage-net-unix> for full history.

* Improve error message for permission denied (#6).
* Fix the order of linking to ensure `io-page.unix` comes first.
  This works around a linking hack to ensure the C symbols load.


### irmin-0.8.0: Cleaner external API

Released on 2014-05-27 as [0.8.0](https://github.com/mirage/irmin/releases/tag/0.8.0). See <https://github.com/mirage/irmin> for full history.

* Spring clean-ups in the API. Separation in IrminBranch for
  fork/join operations, IrminSnapshot for snapshot/revert
  operations and IrminDump for import/export operations.
  The later two implementation can be derived automaticaly
  from a base IrminBranch implementation. The update and merge
  operations are supported on each backend
* IrminGit does not depend on unix anymore and can thus be
  compile to javascript or xen with mirage
* No need to have bin_io converter for contents anymore
* No need to have JSON converter for contents anymore
* No more IrminDispatch
* Add an optional branch argument to Irmin.create to use
  an already existing branch
* Fix order of arguments in Irmin.merge

### mirage-net-xen-v1.1.1: Better bounds checking for oversized frames

Released on 2014-05-27 as [v1.1.1](https://github.com/mirage/mirage-net-xen/releases/tag/v1.1.1). See <https://github.com/mirage/mirage-net-xen> for full history.

Do not send oversized frames to the backend Netfront (#9 from Edwin Torok).


### ocaml-ctypes-ocaml-ctypes-0.3: ocaml-ctypes 0.3

Released on 2014-05-22 as [ocaml-ctypes-0.3](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/ocaml-ctypes-0.3). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.

### ocaml-ctypes-0.3: ocaml-ctypes 0.3

Released on 2014-05-22 as [0.3](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.3). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.

### ocaml-github-v0.8.5: Fix optional schema field parsing

Released on 2014-05-08 as [v0.8.5](https://github.com/avsm/ocaml-github/releases/tag/v0.8.5). See <https://github.com/avsm/ocaml-github> for full history.

* The `master_branch` field in the `repo` is actually optional, to fix the schema to reflect this.

### irmin-0.7.0: Support for views, speed improvement

Released on 2014-05-02 as [0.7.0](https://github.com/mirage/irmin/releases/tag/0.7.0). See <https://github.com/mirage/irmin> for full history.

* Feature: support for in-memory transactions. They are built
  on top of views.
* Feature: add support for views: these are temporary stores with
  lazy reads + in-memory writes; they can be used to convert back
  and forth an OCaml value into a store, or to have a fast stagging
  area without the need to commit every operation to the store.
* Support custom messages in commit messages
* Improve the IrminMerge API
* Backend: add a 'dispatch' backend for combining multiple backends
  into one. This can be used to have a P2P store where there is
  well-defined mapping between keys and host (as a DHT).
* Fix: limit the number of simulteanous open files in the Git and
  the file-system backend
* Speed-up the in-memory store
* Speed-up the import/export codepath
* Speed-up the reads
* Speed-up IrminValue.Mux
* Deps: use ocaml-sha instead of cryptokit

### mirage-tcpip-v1.1.3: Expose IPV4 module in the STACKV4 functor

Released on 2014-04-29 as [v1.1.3](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.3). See <https://github.com/mirage/mirage-tcpip> for full history.

* Expose IPV4 through the STACKV4 interface.

This requires the corresponding mirage-types package in Mirage 1.1.2

### mirage-1.1.2: Improve STACKV4 module type, and EC2 deployment scripts

Released on 2014-04-29 as [1.1.2](https://github.com/mirage/mirage/releases/tag/1.1.2). See <https://github.com/mirage/mirage> for full history.

* Improvement to the Amazon EC2 deployment script.
* [types] Augment STACKV4 with an IPV4 module in addition to TCPV4 and UDPV4.
* Regenerate with OASIS 0.4.4 (which adds natdynlink support)

### ocaml-uri-v1.6.0: More compatible escape encoding, link fixes and remove Uri_IP

Released on 2014-04-28 as [v1.6.0](https://github.com/mirage/ocaml-uri/releases/tag/v1.6.0). See <https://github.com/mirage/ocaml-uri> for full history.

* Remove `Uri_IP` module, superseded by the `ipaddr` package (#30).
* Do not depend on `camlp4` for link-time, only compile time (#39).
* Add `with_scheme` and `with_userinfo` functional setters (#40).
* Always percent-escape semicolon in structured query encoding (#44).


### ocaml-cow-v0.10.0: Use `jsonm` library for all JSON handling

Released on 2014-04-27 as [v0.10.0](https://github.com/mirage/ocaml-cow/releases/tag/v0.10.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Remove JSON parsing in favour of using `jsonm` instead.  This is an interface change that will break any existing users of the JSON portions of Cow, but it's worth making this change before a 1.0 release of Cow.
* Stop testing OCaml 3.12.1 (although it may continue to work).


### ocaml-github-v0.8.4: Add `git-list-releases` binary

Released on 2014-04-26 as [v0.8.4](https://github.com/avsm/ocaml-github/releases/tag/v0.8.4). See <https://github.com/avsm/ocaml-github> for full history.

This sorts and displays a list of repository releases in chronological order.

### ocaml-cohttp-v0.11.2: Build fixes

Released on 2014-04-22 as [v0.11.2](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.11.2). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Fix Lwt Unix build by add a missing build-deps in `_oasis`

### ocaml-dns-v0.8.1: Support multiple zonefiles per server

Released on 2014-04-19 as [v0.8.1](https://github.com/mirage/ocaml-dns/releases/tag/v0.8.1). See <https://github.com/mirage/ocaml-dns> for full history.

* Add `process_of_zonebufs` to handle multiple zone files.
* Adapt `Dns_server_unix` to expose multiple zonebuf functions.


### ocaml-git-1.0.2: Propagate Zlib inflation errors

Released on 2014-04-19 as [1.0.2](https://github.com/mirage/ocaml-git/releases/tag/1.0.2). See <https://github.com/mirage/ocaml-git> for full history.

*  Catch, improve and propagate Zlib inflation errors (which usually on incomplete files)

### ocaml-cohttp-v0.11.1: Add Lwt SimpleHTTPServer, and bugfixes

Released on 2014-04-17 as [v0.11.1](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.11.1). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Remove an errant async_ssl reference left in the _oasis file that is
  now handled by the Conduit library (#116).
* Add an Lwt-based SimpleHTTPServer equivalent as `cohttp-server-lwt` (#108).
* `Cohttp.Connection.t` now exposes sexp accessor functions (#117).


### ocaml-conduit-v0.5.0: First public release

Released on 2014-04-13 as [v0.5.0](https://github.com/mirage/ocaml-conduit/releases/tag/v0.5.0). See <https://github.com/mirage/ocaml-conduit> for full history.

Async SSL is temporarily disabled in this release until a stub-generation version of the underlying library binding is available.

### ocaml-cohttp-v0.11.0: Thread safety and Async/Lwt SSL

Released on 2014-04-13 as [v0.11.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.11.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Remove dependency on `ocaml-re` in order to make library POSIX thread-safe.
* Shift most of the connection handling logic out to a Conduit library that
  worries about which SSL library to use, and fails if SSL is not available.
* Add Async-SSL support for both client and server (#102).
* Add Lwt-SSL support for the server side (the client side existed before).
* Fix buggy Async chunked POST handling.



### ocaml-github-v0.8.3: Add `git-sync-releases` and `git upload-release` binaries

Released on 2014-04-13 as [v0.8.3](https://github.com/avsm/ocaml-github/releases/tag/v0.8.3). See <https://github.com/avsm/ocaml-github> for full history.

This helps to synchronize Release metadata across two GitHub forks, and upload binary files to a Release.

### irmin-0.6.0: Support for merge and user-defined contents

Released on 2014-04-12 as [0.6.0](https://github.com/mirage/irmin/releases/tag/0.6.0). See <https://github.com/mirage/irmin> for full history.

* Support for user-defined contents (with custom merge operators)
* Support for merge operations
* Rename `IrminTree` to `IrminNode` to reflect the fact that we
  can support arbitrary immutable graphs (it's better if they are
  DAGs but that's not mandatory)
* Rename `IrminBlob` to `IrminContents` to reflect the fact that
  we also support structured contents (as JSON objects)
* Support for linking the library without linking to camlp4 as well (#23)

### ocaml-git-1.0.1: Escape invalid chars in path names

Released on 2014-04-10 as [1.0.1](https://github.com/mirage/ocaml-git/releases/tag/1.0.1). See <https://github.com/mirage/ocaml-git> for full history.

* Escape invalid chars in path names
* Do not link with camlp4 when using as a libray

### ocaml-github-v0.8.2: Deployment key and POSIX thread safety

Released on 2014-04-01 as [v0.8.2](https://github.com/avsm/ocaml-github/releases/tag/v0.8.2). See <https://github.com/avsm/ocaml-github> for full history.

0.8.2 (2014-04-01):
* Remove use of `Re_str` to add POSIX thread safety.
* Add deployment key support in the `Deploy_key` module.


### ocaml-uri-v1.5.0: POSIX thread safety

Released on 2014-04-01 as [v1.5.0](https://github.com/mirage/ocaml-uri/releases/tag/v1.5.0). See <https://github.com/mirage/ocaml-uri> for full history.

Doesn't depend on `Re_str` any more.

### mirage-tcpip-v1.1.2: DHCP option parsing fixes

Released on 2014-03-27 as [v1.1.2](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.2). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fix DHCP variable length option parsing for MTU responses, which
  in turns improves robustness on Amazon EC2 (fix from @yomimono 
  via mirage/mirage-tcpip#48)


### cowabloga-v0.0.6: More robust build dependencies

Released on 2014-03-26 as [v0.0.6](https://github.com/mirage/cowabloga/releases/tag/v0.0.6). See <https://github.com/mirage/cowabloga> for full history.

The `Re_str` dependency was not POSIX threadsafe and so has been removed from Cohttp dependencies.  This adds an explicit dependency on it for Cowabloga

### ocaml-crunch-v1.3.0: Deduplicate sectors for smaller crunch size

Released on 2014-03-09 as [v1.3.0](https://github.com/mirage/ocaml-crunch/releases/tag/v1.3.0). See <https://github.com/mirage/ocaml-crunch> for full history.

### ocaml-github-v0.8.1: Add new oAuth scopes

Released on 2014-03-07 as [v0.8.1](https://github.com/avsm/ocaml-github/releases/tag/v0.8.1). See <https://github.com/avsm/ocaml-github> for full history.

### ocaml-tuntap-v1.0.0: Improve IPv6 support and error messages

Released on 2014-03-02 as [v1.0.0](https://github.com/mirage/ocaml-tuntap/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-tuntap> for full history.

* Improve error messages to distinguish where they happen.
* Install otunctl command-line tool to create persistent tun/taps.
* Build debug symbols, annot and bin_annot files by default.
* getifaddrs now lists IPv6 as well, and return a new type.
* set_ipv6 is now called set_ipaddr, and will support IPv6 in the
  future (currently unimplemented).

### ocaml-github-v0.8.0: Latest cohttp support and stability improvements

Released on 2014-03-02 as [v0.8.0](https://github.com/avsm/ocaml-github/releases/tag/v0.8.0). See <https://github.com/avsm/ocaml-github> for full history.

* Port to cohttp.0.10.x interfaces.
* Make the `note` field in oAuth token creation mandatory to reflect GitHub API.
* Pull requests are now allowed to have `null` bodys (#31).


### irmin-0.5.1: Support for cohttp 0.10.*

Released on 2014-03-02 as [0.5.1](https://github.com/mirage/irmin/releases/tag/0.5.1). See <https://github.com/mirage/irmin> for full history.

### cowabloga-v0.0.5: Cohttp 0.10.x compatibility

Released on 2014-03-02 as [v0.0.5](https://github.com/mirage/cowabloga/releases/tag/v0.0.5). See <https://github.com/mirage/cowabloga> for full history.

Adapt Cowabloga API to the latest Cohttp API.

### ocaml-cohttp-v0.10.0: Interface cleanups before a 1.0 release

Released on 2014-03-02 as [v0.10.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.10.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Interface change: The `Request` and `Response` module types now explictly
  signal `Eof` and `Invalid` (for errors), to help the backend distinguish them.
* Interface change: Unify HTTP body handling across backends into a `Cohttp.Body`
  module.  This is extended by Async/Lwt implementations with their specific
  ways of handling bodies (Pipes for Async, or Lwt_stream for Lwt).
* [lwt] Interface change: HTTP client calls now raise Lwt exceptions rather
  than return an option type.  This permits better error handling in Lwt.
* [lwt] Interface change: The `Server` callback now always provides a `body`
  argument, since `Cohttp_lwt_body` now explicitly supports empty bodys.
* Add `Cohttp.Header.is_keep_alive` to test if a connection should be reused.
* [lwt] Respect the `keep-alive` header in the server request handling.
* [async] Add a `Body` that takes a `Pipe` or a `string`, similarly to Lwt.
* Install `cohttp-server` binary even if tests are disabled.
* Begin an `examples` directory with some simple uses of the library.


### ocaml-github-v0.7.1: Better toplevel and logging support

Released on 2014-02-28 as [v0.7.1](https://github.com/avsm/ocaml-github/releases/tag/v0.7.1). See <https://github.com/avsm/ocaml-github> for full history.

0.7.1 (2014-02-28):
* Log response bodies in the event of an API parsing failure. (#29)
* Expose `log_active` as a reference so it can be used from the toplevel. (#30)
* Add `Github.URI.pull_raw_diff` to point to the location of a pull request diff.


### mirage-platform-v1.1.1: Improve Xen evtchn scalability

Released on 2014-02-24 as [v1.1.1](https://github.com/mirage/mirage-platform/releases/tag/v1.1.1). See <https://github.com/mirage/mirage-platform> for full history.

* xen: support 4096 event channels (up from 8). Each device typically
  uses one event channel.


### irmin-0.5.0: Support non-UTF8 blobs and consistent support for watches across backends

Released on 2014-02-21 as [0.5.0](https://github.com/mirage/irmin/releases/tag/0.5.0). See <https://github.com/mirage/irmin> for full history.

* More consistent support for notifications. `irmin watch` works
  now for all backends.
* Support for different blob formats on the command-line
* Support for JSON blobs
* More flexible `irmin fetch` command: we can now choose the backend to
  import the data in
* Fix import of Git objects when the blobs were not imported first
* Support non-UTF8 strings as path name and blob contents (for all
  backends, including the JSON one)
* Speed-up the `slow` tests execution time
* Improve the output graph when objects of different kinds might have
  the same SHA1

### ocaml-dns-v0.8.0: IPv6 support and better portability

Released on 2014-02-21 as [v0.8.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.8.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Use `Ipaddr.V6` to restore IPv6/AAAA RR support.
* `process_query` now takes an output buffer so it doesn't have to
  overwrite the input buffer it just parsed.
* Add Travis continuous integration scripts.
* Regenerate with OASIS 0.4.1
* Split the `dns.lwt` into a portable `dns.lwt-core` that doesn't
  require Unix (from which a Mirage version can be built).  The only
  change to existing applications is that Unix-specific functions
  have shifted into `Dns_resolver_unix` or `Dns_server_unix`, with
  the module types for `PROCESSOR` and `CLIENT` unchanged.


### mirage-tcpip-v1.1.1: Bug fixes and adapt API to Mirage 1.1.1

Released on 2014-02-21 as [v1.1.1](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.1). See <https://github.com/mirage/mirage-tcpip> for full history.

* Catch and ignore top-level socket exceptions (#219).
* Set `SO_REUSEADDR` on listening sockets for Unix (#218).
* Adapt the Stack interfaces to the v1.1.1 mirage-types interface
  (see mirage/mirage#226 for details).


### mirage-1.1.1: Networking improvements

Released on 2014-02-21 as [1.1.1](https://github.com/mirage/mirage/releases/tag/1.1.1). See <https://github.com/mirage/mirage> for full history.

* Man page fixes for typos and terminology (#220).
* Activate backtrace recording by default (#225).
* Fixes in the `V1.STACKV4` to expose UDPv4/TCPv4 types properly (#226).


### ocaml-cstruct-v1.1.0: Add `to_bigarray`

Released on 2014-02-20 as [v1.1.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.1.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

Add a (sadly rather slow but sometimes necessary) function to convert a Cstruct back into a Bigarray slice of the right length and offset.

### io-page-v1.1.1: Improve portability on BSDs

Released on 2014-02-16 as [v1.1.1](https://github.com/mirage/io-page/releases/tag/v1.1.1). See <https://github.com/mirage/io-page> for full history.

* Improve portability on *BSD by not including `malloc.h` and
  just using `stdlib.h` instead.


### ocaml-uri-v1.4.0: Fix path encoding bugs

Released on 2014-02-16 as [v1.4.0](https://github.com/mirage/ocaml-uri/releases/tag/v1.4.0). See <https://github.com/mirage/ocaml-uri> for full history.

* Fix path and path_and_query encoding bugs (#35).
* Fix userinfo percent-encoding/delimiter bug (#35).
* Add optional scheme parameter to encoding_of_query.

### mirage-1.1.0: Combinator interface for configuration

Released on 2014-02-10 as [1.1.0](https://github.com/mirage/mirage/releases/tag/1.1.0). See <https://github.com/mirage/mirage> for full history.

The Mirage 1.1.0 release features a new combinator interface to make it easier to map device drivers in `config.ml` into concrete applications.  This breaks backwards compatibility with Mirage 1.0 configuration files, but the added benefit is significant, so we felt it was worthwhile.

The `types` directory also now contains the `V1` and `V1_LWT` module types used throughout the Mirage libraries.

### ocaml-mstruct-1.3.0: remove debug and duplicate bound checks in the hot path

Released on 2014-02-10 as [1.3.0](https://github.com/mirage/ocaml-mstruct/releases/tag/1.3.0). See <https://github.com/mirage/ocaml-mstruct> for full history.

* Remove debugging message in hot path
* Remove duplicated bound checks (which were already done by cstruct)
* Remove `Mstruct.dump`, replace it by `Mstruct.{hexdump,hexdump_to_buffer,debug}`
  to share the same API as `Cstruct`

### ocaml-cohttp-v0.9.16: Sexp support for most types

Released on 2014-02-10 as [v0.9.16](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.16). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Add some module type equalities in `Cohttp_lwt_unix` so that
  `Cohttp_lwt_unix.Server.Request.IO.ic` can be equivalen to `Lwt_io.input_channel`.
* Add sexp converters to most Cohttp types (#83).
* Improve Travis tests to cover more upstream users of Cohttp.
* Refactor build flags to let the portable Lwt-core be built independently of Lwt.unix.


### ocaml-git-1.0.0: First release

Released on 2014-02-10 as [1.0.0](https://github.com/mirage/ocaml-git/releases/tag/1.0.0). See <https://github.com/mirage/ocaml-git> for full history.

- Full support for the format of all the Git objects
- Partial support for the synchronisation protocols

### mirage-tcpip-v1.1.0: Rewritten interfaces that are now functorized over V1_LWT

Released on 2014-02-05 as [v1.1.0](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* Rewrite of the library as a set of functors that parameterize the
  stack across the `V1_LWT` module types from Mirage 1.1.x.  This removes
  the need to compile separate Xen and Unix versions of the stack.


### mirage-http-v1.1.0: Functorized interfaces for Mirage 1.1.x

Released on 2014-02-05 as [v1.1.0](https://github.com/mirage/mirage-http/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-http> for full history.

The release no longer needs a -unix and -xen compile, since it's just a functor that will be applied by the Mirage 1.1.x command line tool.

### cowabloga-v0.0.4: More improvements to add helper functions

Released on 2014-02-01 as [v0.0.4](https://github.com/mirage/cowabloga/releases/tag/v0.0.4). See <https://github.com/mirage/cowabloga> for full history.

An incremental release to add HTML and Zurb helper functions.

### xen-disk-v1.2.1: Add an example MMAP backend

Released on 2014-02-01 as [v1.2.1](https://github.com/mirage/xen-disk/releases/tag/v1.2.1). See <https://github.com/mirage/xen-disk> for full history.

* add MMAP backend, for testing
* change '--format' argument to '--backend'


### cowabloga-v0.0.3: More improvements to the live site (Google Analytics too)

Released on 2014-02-01 as [v0.0.3](https://github.com/mirage/cowabloga/releases/tag/v0.0.3). See <https://github.com/mirage/cowabloga> for full history.

* Add a `Link` module for keeping track of external articles.
* Fix blog template columns to work better on small devices.
* Add a `Feed` module that aggregates together all the other feeds (Blog/Wiki).
* Add a Google Analytics option to `Foundation.body`.


### ocaml-fat-0.10.1: Depend on unified Io_page library

Released on 2014-02-01 as [0.10.1](https://github.com/mirage/ocaml-fat/releases/tag/0.10.1). See <https://github.com/mirage/ocaml-fat> for full history.

Initial release that uses the Io_page library instead of the separate Xen and Unix ones.

### mirage-console-v1.0.2: Fix Xen console on resume and simplify build deps

Released on 2014-02-01 as [v1.0.2](https://github.com/mirage/mirage-console/releases/tag/v1.0.2). See <https://github.com/mirage/mirage-console> for full history.

* [xen] Fix console on resume by reattaching the ring.
* [xen] Switch to ocamlfind xen-{gnt,evtchn}.


### mirage-block-unix-1.2.1: Simplify build dependencies

Released on 2014-02-01 as [1.2.1](https://github.com/mirage/mirage-block-unix/releases/tag/1.2.1). See <https://github.com/mirage/mirage-block-unix> for full history.

1.2.1 (01-Feb-2013)
* Update to new io-page{,.unix} ocamlfind structure


### mirage-platform-v1.1.0: Reduction in build dependencies

Released on 2014-02-01 as [v1.1.0](https://github.com/mirage/mirage-platform/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-platform> for full history.

* Update to new io-page{,.unix} ocamlfind packages.
* Remove unused Netif module from Unix backend.
* Xen now depends on `xen-{evtchn,gnt}` packages.
* Add a `type 'a io` to make it easier to include

### mirage-net-xen-v1.1.0: Dependency simplifications

Released on 2014-01-31 as [v1.1.0](https://github.com/mirage/mirage-net-xen/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-net-xen> for full history.

1.1.0 (2013-02-01):
* Depend on the unified io-page library instead of io-page-xen.
* Depend on new `xen-event` and `xen-grant` packages.


### mirage-net-unix-v1.1.0: Depend on unified Io_page library

Released on 2014-01-31 as [v1.1.0](https://github.com/mirage/mirage-net-unix/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-net-unix> for full history.

### xen-disk-v1.2.0: Use Mirage BLOCK and mirage-block-xen.1.1.0

Released on 2014-01-30 as [v1.2.0](https://github.com/mirage/xen-disk/releases/tag/v1.2.0). See <https://github.com/mirage/xen-disk> for full history.

* build via OASIS and ocamlbuild
* update to use new xen-{evtchn,gnt} ocamlfind packages
* update to consume mirage-types BLOCK signature
* replace MMAP implementation with mirage-block-unix Block
* update to new blkback functor in mirage-block-xen v1.1.0


### mirage-block-xen-v1.1.0: Higher performance and less boilerplate

Released on 2014-01-30 as [v1.1.0](https://github.com/mirage/mirage-block-xen/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-block-xen> for full history.

* blkback is now functorised over Activations, Xenstore and the backing store. It now contains all the device connect and disconnect boilerplate
* blkback now coalesces requests, analyses them for data dependencies, and issues them in parallel

### io-page-v1.1.0: Reduce library dependencies

Released on 2014-01-30 as [v1.1.0](https://github.com/mirage/io-page/releases/tag/v1.1.0). See <https://github.com/mirage/io-page> for full history.

No functional change beyond removing a mirage-types dependency (but bumping version to reflect this change)

### mirage-www-1.0.0: Snapshot of the website that works with Mirage 1.0

Released on 2014-01-30 as [1.0.0](https://github.com/mirage/mirage-www/releases/tag/1.0.0). See <https://github.com/mirage/mirage-www> for full history.

### irmin-0.4.0: API changes and Git backend

Released on 2014-01-21 as [0.4.0](https://github.com/mirage/irmin/releases/tag/0.4.0). See <https://github.com/mirage/irmin> for full history.

* The command-line tool now looks in the environment for the variable
  `IRMIN` to configure its default backend
* Add a Git backend
* Add Travis CI scripts to the repo
* Use `Lwt_bytes` and `Lwt_unix` instead of the custom-made `IrminChannel`
* Use `bin_prot` instead of a custom binary protocol
* Major refactoring: `Value` is now `Blob`, `Revision` is now `Commit`
   and `Tag` becomes `Reference` (rational: consistency with Git names)
* Use `core_kernel` instead of building a custom `Identiable.S`
* Use `dolog` instead of a custom log library
* Use `mstruct` (mutable buffers on top of `cstruct`) which is now
  released independently

### ocaml-git-0.10.2: fix reading of reference files created by the Git command-line

Released on 2014-01-20 as [0.10.2](https://github.com/mirage/ocaml-git/releases/tag/0.10.2). See <https://github.com/mirage/ocaml-git> for full history.

* Strip the contents of references file (this fixes reading of reference files created by the Git command-line)
* Improve the pretty-printing of SHA1 values
* Add some info message when reading files in the local backend

### io-page-v1.0.0: Unify Xen/Unix into subpackages

Released on 2014-01-16 as [v1.0.0](https://github.com/mirage/io-page/releases/tag/v1.0.0). See <https://github.com/mirage/io-page> for full history.

This makes it easier to depend on Io_page by upstream libraries

### ocaml-uri-v1.3.13: Add sexp converters

Released on 2014-01-16 as [v1.3.13](https://github.com/mirage/ocaml-uri/releases/tag/v1.3.13). See <https://github.com/mirage/ocaml-uri> for full history.

Expose s-expression accessors for most of the Uri external interface, to make it possible to serialize it to human readable form easily.

### ocaml-git-0.10.1: Fix build and expose more functions

Released on 2014-01-14 as [0.10.1](https://github.com/mirage/ocaml-git/releases/tag/0.10.1). See <https://github.com/mirage/ocaml-git> for full history.

* Add missing files (fix build)
* Add `GitTypes.S.mem_reference`
* Add `GitTypes.S.remove_reference`
* Add `GitTypes.S.mem` to check if an object exists in the store

### mirage-1.0.4: Improved debugging and IDE support

Released on 2014-01-14 as [1.0.4](https://github.com/mirage/mirage/releases/tag/1.0.4). See <https://github.com/mirage/mirage> for full history.

The Makefile generated by `mirage configure` now includes debugging, symbols and annotation support for both the new-style binary annotations and the old-style `.annot` files.

### ocaml-git-0.10.0: fetch operation + in-memory store

Released on 2014-01-14 as [0.10.0](https://github.com/mirage/ocaml-git/releases/tag/0.10.0). See <https://github.com/mirage/ocaml-git> for full history.

* Support for in-memory stores
* Add `ogit cat-file`
* Add `ogit ls-remote`
* Add `ogit fetch`
* Add `ogit clone`
* Switch non-blocking IO using Lwt

### ocaml-cohttp-v0.9.15: Cookie improvements, API consistency and better header parsing

Released on 2014-01-11 as [v0.9.15](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.15). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Remove `Cohttp_mirage` libraries, which have now moved to `mirage/mirage-http-*` on GitHub.
* Add an "HTTP only" `Cookie` attribute (#69).
* Fix parsing of cookies with `=` in the values (#71).
* Add `Max-age` support for cookies (#70).
* Make the `Response` record fields mutable to match the `Request` (#67).
* Fix compilation with Async 109.58.00 (#77).
* Make Header handling case-insensitive (by forcing lowercase) (#75).
* Remove the `>>` operator as it was unused and had incorrect precedence (#79).


### ocaml-git-0.9.0: Initial release

Released on 2014-01-04 as [0.9.0](https://github.com/mirage/ocaml-git/releases/tag/0.9.0). See <https://github.com/mirage/ocaml-git> for full history.

The basic things seems to work OK. You can clone a remote repository, inspect the object files in in git repository, decompress the pack files, draw some nice graphs and generate the filesystem corresponding to a given commit.

What is missing before 1.0:
* partial clone (ie. pull and fetch)
* staging area
* index of files
* more testing
* more users

### ocaml-github-v0.7.0: Releases support, more scopes and better debug control

Released on 2014-01-03 as [v0.7.0](https://github.com/avsm/ocaml-github/releases/tag/v0.7.0). See <https://github.com/avsm/ocaml-github> for full history.

* Add a User.repos call to list a users repositories.
* Change repo type such that the field 'pushed_at' is now an option type.
* Accept optional page argument in Pull, Milestone, and Issue.
* Add `UserEmail`, `UserFollow` and `Notifications` scopes.
* Add `Releases` module to handle the release management addition to GitHub.
* Add `GITHUB_DEBUG` environment variable to make debugging output optional.
* Regenerate build files with OASIS 0.4.1.
* OCamldoc improvements for the `GitHub` module.


### ocaml-mstruct-1.2.0: Add little-endian primitives

Released on 2014-01-03 as [1.2.0](https://github.com/mirage/ocaml-mstruct/releases/tag/1.2.0). See <https://github.com/mirage/ocaml-mstruct> for full history.

* Export `Mstruct.index`
* Add `Mstruct.get_le_uint16` and `Mstruct.set_le_uint16`
* Add `Mstruct.get_le_uint32` and `Mstruct.set_le_uint32`
* Add `Mstruct.get_le_uint64` and `Mstruct.set_le_uint64`
* Rename `Mstruct.get_uint16` to `Mstruct.get_be_uint16`
* Rename `Mstruct.get_uint32` to `Mstruct.get_be_uint32`
* Rename `Mstruct.get_uint64` to `Mstruct.get_be_uint64`
* Rename `Mstruct.set_uint16` to `Mstruct.set_be_uint16`
* Rename `Mstruct.set_uint32` to `Mstruct.set_be_uint32`
* Rename `Mstruct.set_uint64` to `Mstruct.set_be_uint64`

### ocaml-mstruct-1.1.0: And to_string and of_string functions

Released on 2014-01-03 as [1.1.0](https://github.com/mirage/ocaml-mstruct/releases/tag/1.1.0). See <https://github.com/mirage/ocaml-mstruct> for full history.

* Add `Mstruct.to_string`
* Add `Mstruct.of_string`

### ocaml-mstruct-1.0.0: First release

Released on 2014-01-02 as [1.0.0](https://github.com/mirage/ocaml-mstruct/releases/tag/1.0.0). See <https://github.com/mirage/ocaml-mstruct> for full history.

### ocaml-lazy-trie-1.0.0: Initial release

Released on 2014-01-02 as [1.0.0](https://github.com/mirage/ocaml-lazy-trie/releases/tag/1.0.0). See <https://github.com/mirage/ocaml-lazy-trie> for full history.

### ocaml-uri-v1.3.12: Be less strict about bad percent encoding

Released on 2013-12-28 as [v1.3.12](https://github.com/mirage/ocaml-uri/releases/tag/v1.3.12). See <https://github.com/mirage/ocaml-uri> for full history.

* Be lenient about decoding incorrect encoded percent-strings (#31).
* Improve ocamldoc for `Uri.of_string`.
* Regenerate build files with OASIS 0.4.1.
* Add an `mldylib` to build the cmxs Natdynlink plugin properly (#29).


### cowabloga-v0.0.2: Continue breaking out the Mirage website by adding Wiki support

Released on 2013-12-24 as [v0.0.2](https://github.com/mirage/cowabloga/releases/tag/v0.0.2). See <https://github.com/mirage/cowabloga> for full history.

Still a very alpha library, but used by mirage-www

### ocaml-crunch-v1.2.3: Fix zero length file handling

Released on 2013-12-24 as [v1.2.3](https://github.com/mirage/ocaml-crunch/releases/tag/v1.2.3). See <https://github.com/mirage/ocaml-crunch> for full history.

### cowabloga-v0.0.1: initial public release

Released on 2013-12-22 as [v0.0.1](https://github.com/mirage/cowabloga/releases/tag/v0.0.1). See <https://github.com/mirage/cowabloga> for full history.

__ALPHA__ release of some of the Mirage website functionality moved out into a (fast moving) library.

### ocaml-cow-v0.9.1: XML parsing bug fix for empty attributes

Released on 2013-12-20 as [v0.9.1](https://github.com/mirage/ocaml-cow/releases/tag/v0.9.1). See <https://github.com/mirage/ocaml-cow> for full history.

XML attributes with an empty string were parsed incorrectly, but now fixed.

### ocaml-cow-v0.9.0: Unify Markdown libraries, clarify license to ISC

Released on 2013-12-20 as [v0.9.0](https://github.com/mirage/ocaml-cow/releases/tag/v0.9.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Remove all the Markdown variants except `Omd`, which now claims the `Cow.Markdown` module name.
* Clarify the repository license as ISC.
* Run some modules through `ocp-indent`.


### alcotest-0.2.0: Minor bug fixes

Released on 2013-12-19 as [0.2.0](https://github.com/samoht/alcotest/releases/tag/0.2.0). See <https://github.com/samoht/alcotest> for full history.

* Fix issues with redirections
* Display the full errors when only one test is selected

### mirage-1.0.3: Improved HTTP and FAT filesystem support

Released on 2013-12-18 as [1.0.3](https://github.com/mirage/mirage/releases/tag/1.0.3). See <https://github.com/mirage/mirage> for full history.

* Do not remove OPAM packages when doing `mirage clean` (#143)
* [xen] generate a simple main.xl, without block devices or network interfaces.
* The HTTP dependency now also installs `mirage-tcp-*` and `mirage-http-*`.
* Fix generated Makefile dependency on source OCaml files to rebuild reliably.
* Support `Fat_KV_RO` (a read-only k/v version of the FAT filesystem).
* The Unix `KV_RO` now passes through to the underlying filesystem instead of calling `crunch`, via `mirage-fs-unix`.

### mirage-http-v1.0.0: First public release

Released on 2013-12-18 as [v1.0.0](https://github.com/mirage/mirage-http/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-http> for full history.

### ocaml-fat-0.10.0: CLI performance improvements

Released on 2013-12-18 as [0.10.0](https://github.com/mirage/ocaml-fat/releases/tag/0.10.0). See <https://github.com/mirage/ocaml-fat> for full history.

* Using buffered I/O by default in the command-line tool speeds up archive manipulation significantly, especially on machines with spinning disks.

### mirage-block-unix-1.2.0: Bugfix release

Released on 2013-12-18 as [1.2.0](https://github.com/mirage/mirage-block-unix/releases/tag/1.2.0). See <https://github.com/mirage/mirage-block-unix> for full history.

* Fix a serious race condition exposed when multiple threads access
  the same block device
* Block.connect: open in buffered mode if the filename has prefix "buffered:".
  The default is still to use unbuffered (like mirage-block-xen)


### ocaml-fat-0.9.0: Add KV_RO support

Released on 2013-12-17 as [0.9.0](https://github.com/mirage/ocaml-fat/releases/tag/0.9.0). See <https://github.com/mirage/ocaml-fat> for full history.

0.9.0 (15-Dec-2013):
* add `Fat.KV_RO` which is a read-only subset of the filesystem.
* Regenerate build files with OASIS 0.4.0.

### mirage-fs-unix-v1.0.0: First public release

Released on 2013-12-17 as [v1.0.0](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-fs-unix> for full history.

### mirage-block-unix-1.1.0: Expose more low-level functions

Released on 2013-12-16 as [1.1.0](https://github.com/mirage/mirage-block-unix/releases/tag/1.1.0). See <https://github.com/mirage/mirage-block-unix> for full history.

* expose Block.getblksize
* update to OASIS 0.4.0

### ocaml-cohttp-v0.9.14: Better Server-Side Event support, complete HTTP codes and install a server binary

Released on 2013-12-15 as [v0.9.14](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.14). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Install a `cohttp-server` binary that serves local directory contents via a web server (#54).
* Add a `flush` function to the `IO` module type and implement in Lwt/Async/Mirage.
* Add option `flush` support in the Async and Lwt responders (#52).
* Autogenerate HTTP codes from @citricsquid's JSON representation of the HTTP RFCs.
* Always set `TCP_NODELAY` for Lwt/Unix server sockets for low-latency responses (#58).
* Added a Server-Side Events test-case from the HTML5 Doctor. See `lib_test/README.md`.
* Async.Server response now takes an optional `body` rather than a mandatory `body option` (#62).
* Regenerate build system using OASIS 0.4.0.


### ocaml-cow-v0.8.1: Bugfix to META file, Merlin editor support

Released on 2013-12-15 as [v0.8.1](https://github.com/mirage/ocaml-cow/releases/tag/v0.8.1). See <https://github.com/mirage/ocaml-cow> for full history.

* Fix META file to include `omd`.                                                                                                                                                 
* Improve ocamldoc in CSS module and document quotations in README.
* Add `merlin` editor file.

### irmin-0.3.0: switch to oasis

Released on 2013-12-13 as [0.3.0](https://github.com/mirage/irmin/releases/tag/0.3.0). See <https://github.com/mirage/irmin> for full history.

CHANGES:
* Fix a fd leak in the filesystem bakend
* Functorize the CRUD interface over the HTTP client implementation
* Use oasis to build the project
* Use the now released separately `ezjsonm` and `alcotest` libraries

### ezjsonm-0.2.0: Build json stream from string streams

Released on 2013-12-13 as [0.2.0](https://github.com/mirage/ezjsonm/releases/tag/0.2.0). See <https://github.com/mirage/ezjsonm> for full history.

This adds an optional dependency to lwt

CHANGES:
* Add a new module `Ezjsonm_lwt`, to convert string streams to json streams
* Expose `Ezjsonm.get_bool`

### ocaml-cow-v0.8.0: Proper Markdown support

Released on 2013-12-12 as [v0.8.0](https://github.com/mirage/ocaml-cow/releases/tag/v0.8.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Add Travis continuous integration scripts.
* Add `Omd_markdown` module based on the `omd` library.
* Note: The `Markdown` and `Markdown_github` modules are now deprecated and will be removed before 1.0.


### mirage-platform-v1.0.0: Xen fixes and cleanups

Released on 2013-12-12 as [v1.0.0](https://github.com/mirage/mirage-platform/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-platform> for full history.

* Set `Sys.os_type` to Unix in the Xen backend to help compatibility (#78).
* Suppress another dietlibc linker warning for vprintf in Xen.


### alcotest-0.1.0: Initial release

Released on 2013-12-12 as [0.1.0](https://github.com/samoht/alcotest/releases/tag/0.1.0). See <https://github.com/samoht/alcotest> for full history.

### ezjsonm-0.1.0: Initial release

Released on 2013-12-12 as [0.1.0](https://github.com/mirage/ezjsonm/releases/tag/0.1.0). See <https://github.com/mirage/ezjsonm> for full history.

### ocaml-cohttp-v0.9.13: Mirage 1.0 support and Lwt-core

Released on 2013-12-11 as [v0.9.13](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.13). See <https://github.com/mirage/ocaml-cohttp> for full history.

* The `cohttp.lwt-core` is now installed as an OS-independent Lwt library.
* Add support for Mirage 1.0, via `cohttp.mirage-unix` and `cohttp.mirage-xen`.
* Add a new `Cohttp.Connection` module to manage server's connections identifiers.
* Share the same configuration type for the different server implementations.
* Add `Accept_types` module to the `Cohttp` pack.


### mirage-net-xen-v0.9.0: First public release

Released on 2013-12-10 as [v0.9.0](https://github.com/mirage/mirage-net-xen/releases/tag/v0.9.0). See <https://github.com/mirage/mirage-net-xen> for full history.

Works with `V1.NETWORK` from mirage-types-0.5.0+

### mirage-block-xen-v1.0.0: First stable release

Released on 2013-12-10 as [v1.0.0](https://github.com/mirage/mirage-block-xen/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-block-xen> for full history.

### mirage-1.0.2: HTTP support and OPAM auto-installation fixes

Released on 2013-12-10 as [1.0.2](https://github.com/mirage/mirage/releases/tag/1.0.2). See <https://github.com/mirage/mirage> for full history.

* Add `HTTP` support.
* Fix `KV_RO` configuration for OPAM autoinstall.


### mirage-www-0.4.0: Snapshot as of 11th Dec 2013

Released on 2013-12-10 as [0.4.0](https://github.com/mirage/mirage-www/releases/tag/0.4.0). See <https://github.com/mirage/mirage-www> for full history.

This release uses the final beta 0.9.8 Mirage toolchain and is being archived in preparation for a switch to the Mirage 1.0 setup.

### ocaml-fat-0.8.0: Supports Mirage 1.0

Released on 2013-12-09 as [0.8.0](https://github.com/mirage/ocaml-fat/releases/tag/0.8.0). See <https://github.com/mirage/ocaml-fat> for full history.

* now works with mirage-block-xen

### mirage-tcpip-v0.9.5: Mirage 1.0 compatible version

Released on 2013-12-09 as [v0.9.5](https://github.com/mirage/mirage-tcpip/releases/tag/v0.9.5). See <https://github.com/mirage/mirage-tcpip> for full history.

This removes the socket interface temporarily in favour of a simple repository layout.

### xen-disk-1.1.0: Update following upstream API changes

Released on 2013-12-09 as [1.1.0](https://github.com/mirage/xen-disk/releases/tag/1.1.0). See <https://github.com/mirage/xen-disk> for full history.

Note the experimental VHD backend has been removed for now.

### ocaml-fat-0.7.0: Supports Mirage 1.0

Released on 2013-12-09 as [0.7.0](https://github.com/mirage/ocaml-fat/releases/tag/0.7.0). See <https://github.com/mirage/ocaml-fat> for full history.

'make uninstall' succeeds even if 'configure' hasn't been run.

### ocaml-cstruct-v1.0.1: Bug fix for Cstruct.shift

Released on 2013-12-09 as [v1.0.1](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.0.1). See <https://github.com/mirage/ocaml-cstruct> for full history.

Important bugfix for Cstruct.shift that affected the v1.0.0 release.  Use this release in preference.

### mirage-block-xen-0.5.0: Support Mirage 1.0

Released on 2013-12-08 as [0.5.0](https://github.com/mirage/mirage-block-xen/releases/tag/0.5.0). See <https://github.com/mirage/mirage-block-xen> for full history.

### ocaml-ipaddr-v1.0.0: First stable release

Released on 2013-12-08 as [v1.0.0](https://github.com/mirage/ocaml-ipaddr/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-ipaddr> for full history.

1.0.0 (2013-10-16):
* Add Travis-CI testing scripts.
* Include debug symbols and annot files by default.

0.2.3 (2013-09-20):
* Add `Ipaddr.V4.Prefix.bits` function to produce bits of prefix from prefix.

0.2.2 (2013-08-07):
* Add `Macaddr.make_local` function to create local unicast MAC
  addresses from an octet generation function.
* Add `Macaddr.get_oui` accessor to extract the Organizationally Unique
  Identifier as an integer.
* Add `Macaddr.is_local` predicate to test for a locally administered address.
* Add `Macaddr.is_unicast` predicate to test for a unicast MAC address.

0.2.1 (2013-08-01):
* Add `Ipaddr.V4.any`, `Ipaddr.V4.broadcast`, `Ipaddr.V4.localhost`
  special constant addresses.
* Add `Ipaddr.V4.Prefix.global` (0.0.0.0/0) subnet constant.
* Add `Ipaddr.V4.Prefix.network` function to produce subnet address from prefix.

0.2.0 (2013-08-01):
* Add `Macaddr` module for handling MAC-48 (Ethernet) addresses.
* `Ipaddr.Parse_error` now contains both the error condition and the
  failing input.
* Add ocamldoc-compatible comments on all interfaces.

0.1.1 (2013-07-31):
* Add loopback and link local addresses to the private blocks.
* Fix build system so Makefile is generated by OASIS.

0.1.0 (2013-07-24):
* Initial public release.
* Includes IPv4 and IPv4 CIDR prefix support.


### ocaml-crunch-v1.2.2: Use latest Mirage KV_RO interface, add Travis

Released on 2013-12-08 as [v1.2.2](https://github.com/mirage/ocaml-crunch/releases/tag/v1.2.2). See <https://github.com/mirage/ocaml-crunch> for full history.

### mirage-block-xen-0.4.0: Supports Mirage 1.0

Released on 2013-12-08 as [0.4.0](https://github.com/mirage/mirage-block-xen/releases/tag/0.4.0). See <https://github.com/mirage/mirage-block-xen> for full history.

### mirage-console-v1.0.1: Bugfix for Xen console

Released on 2013-12-08 as [v1.0.1](https://github.com/mirage/mirage-console/releases/tag/v1.0.1). See <https://github.com/mirage/mirage-console> for full history.

Improve stability of Xen console ring (doesn't affect the Unix backend at all)

### mirage-net-unix-v1.0.0: First stable release

Released on 2013-12-08 as [v1.0.0](https://github.com/mirage/mirage-net-unix/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-net-unix> for full history.

### mirage-net-unix-v0.9.0: First public release

Released on 2013-12-08 as [v0.9.0](https://github.com/mirage/mirage-net-unix/releases/tag/v0.9.0). See <https://github.com/mirage/mirage-net-unix> for full history.

### mirage-block-unix-v1.0.0: First stable release

Released on 2013-12-08 as [v1.0.0](https://github.com/mirage/mirage-block-unix/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-block-unix> for full history.

### mirage-console-v1.0.0: First stable release

Released on 2013-12-08 as [v1.0.0](https://github.com/mirage/mirage-console/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-console> for full history.

Initial public release of the library, with Xen and Unix backends.

### ocaml-fat-0.6.2: Supports Mirage 1.0

Released on 2013-12-08 as [0.6.2](https://github.com/mirage/ocaml-fat/releases/tag/0.6.2). See <https://github.com/mirage/ocaml-fat> for full history.

### ocaml-fat-0.6.1: Supports Mirage 1.0

Released on 2013-12-08 as [0.6.1](https://github.com/mirage/ocaml-fat/releases/tag/0.6.1). See <https://github.com/mirage/ocaml-fat> for full history.

Includes a simple command-line tool, 'fat' for manipulating disk images.

### shared-memory-ring-1.0.0: Supports Mirage 1.0

Released on 2013-12-08 as [1.0.0](https://github.com/mirage/shared-memory-ring/releases/tag/1.0.0). See <https://github.com/mirage/shared-memory-ring> for full history.

### mirage-console-v0.9.9: Breakout release from mirage-mlatform

Released on 2013-12-07 as [v0.9.9](https://github.com/mirage/mirage-console/releases/tag/v0.9.9). See <https://github.com/mirage/mirage-console> for full history.

* Install separate libraries for `mirage-console-unix` and `mirage-console-xen`.
* Update library dependencies for mirage-types-0.3.0
* Adapt to `V1.CONSOLE` interface.
* Initial public release, based on mirage/mirage-platform#0.9.8


### mirage-block-xen-0.3.1: Supports Mirage 1.0

Released on 2013-12-07 as [0.3.1](https://github.com/mirage/mirage-block-xen/releases/tag/0.3.1). See <https://github.com/mirage/mirage-block-xen> for full history.

Rename ocamlfind package to mirage-block-xen

### mirage-block-unix-0.2.1: Supports Mirage 1.0

Released on 2013-12-07 as [0.2.1](https://github.com/mirage/mirage-block-unix/releases/tag/0.2.1). See <https://github.com/mirage/mirage-block-unix> for full history.

### mirage-block-xen-0.3.0: Supports Mirage 1.0

Released on 2013-12-07 as [0.3.0](https://github.com/mirage/mirage-block-xen/releases/tag/0.3.0). See <https://github.com/mirage/mirage-block-xen> for full history.

### mirage-platform-v0.9.9: Disaggregate libraries in OS

Released on 2013-12-07 as [v0.9.9](https://github.com/mirage/mirage-platform/releases/tag/v0.9.9). See <https://github.com/mirage/mirage-platform> for full history.

* Fix uninstall target for Unix.
* Remove `tuntap` stubs from Unix module; they are in `ocaml-tuntap` now.
* Move `OS.Clock` out to a toplevel `Clock` module (the `mirage-clock` package).
* Move `OS.Io_page` out to a toplevel `Io_page` module (the `io-page` package).
* Update library dependencies to reduce them based on new functionality.
* Install library as `mirage-xen` or `mirage-unix` that can coexist.
* Suppress dietlibc linker warnings for sscanf/sprintf.


### ocaml-crunch-v1.2.1: Bugfix release for `V1.KV_RO` generation

Released on 2013-12-07 as [v1.2.1](https://github.com/mirage/ocaml-crunch/releases/tag/v1.2.1). See <https://github.com/mirage/ocaml-crunch> for full history.

### ocaml-fat-0.6.0: Compatible with mirage-types

Released on 2013-12-07 as [0.6.0](https://github.com/mirage/ocaml-fat/releases/tag/0.6.0). See <https://github.com/mirage/ocaml-fat> for full history.

* add a command-line tool for maniplating images ('fat')
* functorise over the mirage V1 BLOCK_DEVICE and IO_PAGE
* implements the mirage V1 type FS


### io-page-v0.9.9: Mirage-compatible release

Released on 2013-12-07 as [v0.9.9](https://github.com/mirage/io-page/releases/tag/v0.9.9). See <https://github.com/mirage/io-page> for full history.

Fix the installation of ocamlfind META files.

### ocaml-crunch-v1.2.0: Mirage 1.0 KV_RO support

Released on 2013-12-07 as [v1.2.0](https://github.com/mirage/ocaml-crunch/releases/tag/v1.2.0). See <https://github.com/mirage/ocaml-crunch> for full history.

### mirage-clock-v1.0.0: First stable release

Released on 2013-12-07 as [v1.0.0](https://github.com/mirage/mirage-clock/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-clock> for full history.

1.0.0 (07-Dec-2013):
* Remove unnecessary cstruct dependency.
* Install ocamlfind packages as `mirage-clock-xen` and `mirage-clock-unix`.
* Fix META file descriptions.
* Add Travis tests.


### ocaml-crunch-v1.1.2: Support filenames with no extension

Released on 2013-12-06 as [v1.1.2](https://github.com/mirage/ocaml-crunch/releases/tag/v1.1.2). See <https://github.com/mirage/ocaml-crunch> for full history.

### ocaml-crunch-v1.1.1: Bugfix release against 1.1.0

Released on 2013-12-06 as [v1.1.1](https://github.com/mirage/ocaml-crunch/releases/tag/v1.1.1). See <https://github.com/mirage/ocaml-crunch> for full history.

fix a regression in realpath detection from 1.1.0

### ocaml-crunch-v1.1.0: Support plain (non-Lwt) mode and new Mirage APIs

Released on 2013-12-06 as [v1.1.0](https://github.com/mirage/ocaml-crunch/releases/tag/v1.1.0). See <https://github.com/mirage/ocaml-crunch> for full history.

### ocaml-cstruct-v1.0.0: First stable release

Released on 2013-12-05 as [v1.0.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

Documentation and bounds checking improvements

### mirage-clock-v0.9.9: Ye Olde First Public Release

Released on 2013-12-05 as [v0.9.9](https://github.com/mirage/mirage-clock/releases/tag/v0.9.9). See <https://github.com/mirage/mirage-clock> for full history.

### mirage-block-unix-0.2.0: Now supports Mirage 1.0

Released on 2013-12-05 as [0.2.0](https://github.com/mirage/mirage-block-unix/releases/tag/0.2.0). See <https://github.com/mirage/mirage-block-unix> for full history.

### ocaml-fat-0.5.1: Support IO through devices with alignment requirements

Released on 2013-12-05 as [0.5.1](https://github.com/mirage/ocaml-fat/releases/tag/0.5.1). See <https://github.com/mirage/ocaml-fat> for full history.

This functorises over the memory allocator

### io-page-0.1.0: Preview release

Released on 2013-12-05 as [0.1.0](https://github.com/mirage/io-page/releases/tag/0.1.0). See <https://github.com/mirage/io-page> for full history.

Initial release to demonstrate the unified io-page API.

### mirage-decks-v0.9.4: Release that works with Mirage/Mirari 0.9.4

Released on 2013-12-04 as [v0.9.4](https://github.com/mirage/mirage-decks/releases/tag/v0.9.4). See <https://github.com/mirage/mirage-decks> for full history.

### mirage-block-unix-0.1.1: Add missing file

Released on 2013-12-02 as [0.1.1](https://github.com/mirage/mirage-block-unix/releases/tag/0.1.1). See <https://github.com/mirage/mirage-block-unix> for full history.

### ocaml-fat-0.5.0: Initial release

Released on 2013-12-02 as [0.5.0](https://github.com/mirage/ocaml-fat/releases/tag/0.5.0). See <https://github.com/mirage/ocaml-fat> for full history.

### mirage-block-unix-0.1.0: Initial release

Released on 2013-12-01 as [0.1.0](https://github.com/mirage/mirage-block-unix/releases/tag/0.1.0). See <https://github.com/mirage/mirage-block-unix> for full history.

### ocaml-cohttp-v0.9.12: Polishing the interfaces to a fine shine

Released on 2013-11-28 as [v0.9.12](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.12). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Improve documentation for `Cohttp.Header`.
* Expose Fieldslib setters and getters for most of the `Cohttp` types (#38).
* `Cohttp.Set_cookie.t` is no longer an abstract type to make it easier to update (#38).
* [Lwt] ignore SIGPIPE unconditionally if using the Lwt/Unix module (#37).
* Rename `Cookie` creation parameters for consistency (interface breaking, see #44).
* Fix transfer-length detection (regression from 0.9.11 in #42).
* Add Merin editor file (#41).


### mirage-block-xen-0.2.5: Fix build against cstruct 0.8.0

Released on 2013-11-10 as [0.2.5](https://github.com/mirage/mirage-block-xen/releases/tag/0.2.5). See <https://github.com/mirage/mirage-block-xen> for full history.

### mirage-platform-v0.9.8: OCaml 4.01 Xen support, experimental NS3 backend, bug fixes

Released on 2013-11-07 as [v0.9.8](https://github.com/mirage/mirage-platform/releases/tag/v0.9.8). See <https://github.com/mirage/mirage-platform> for full history.

* Add support for OCaml 4.01.0 in addition to the existing 4.00.1 runtime.
* Major refresh of the NS3 simulation backend, for latest APIs.
* Add `Netif` statistics counters per-packet.
* [xen] Fix multi-page ring support by granting the correct data pages.
* [unix] flush OS.Console file descriptor more often (#108). 
* Fix regression in `Io_page.string_blit` with non-zero src offset (#71).


### ocaml-cohttp-v0.9.11: Mini features: HTTP 1.0 improved, OPTIONS and Travis

Released on 2013-11-07 as [v0.9.11](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.11). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Request module: When sending a request, add the port information in the host header field if available.
* Request module: When parsing a request, add scheme, host and port information in the uri.
* TCP server: When creating the socket for the server, do not force PF_INET6 but take the sockaddr value.
* Add HTTP OPTIONS method.
* Use getaddrinfo instead of gethostbyname for DNS resolution.
* Async: improve HTTP/1.0 support (#35).
* Build with debug symbols, binary annotations by default.
* Add Travis CI test scripts.


### ocaml-cstruct-v0.8.1: More permissive grammar, and variable length buffers

Released on 2013-11-07 as [v0.8.1](https://github.com/mirage/ocaml-cstruct/releases/tag/v0.8.1). See <https://github.com/mirage/ocaml-cstruct> for full history.

* Trailing semicolons are allowed in cstruct field definitions.
* Buffer elements can be any primitive integer, not just `uint8`.


### ocaml-ctypes-ocaml-ctypes-0.2: ocaml-ctypes 0.2

Released on 2013-11-07 as [ocaml-ctypes-0.2](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/ocaml-ctypes-0.2). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.

### ocaml-mbr-v0.1: Preview release

Released on 2013-11-04 as [v0.1](https://github.com/mirage/ocaml-mbr/releases/tag/v0.1). See <https://github.com/mirage/ocaml-mbr> for full history.

### ezxmlm-v1.0.0: First public release

Released on 2013-11-02 as [v1.0.0](https://github.com/avsm/ezxmlm/releases/tag/v1.0.0). See <https://github.com/avsm/ezxmlm> for full history.

### ocaml-uri-v1.3.11: Add relative/relative parsing

Released on 2013-10-15 as [v1.3.11](https://github.com/mirage/ocaml-uri/releases/tag/v1.3.11). See <https://github.com/mirage/ocaml-uri> for full history.

* Add relative-relative URI resolution support.
* OCamldoc fixes.
* Add Travis continous build tests.


### ocaml-cstruct-v0.8.0: bug fixes, Travis and hexdump pretty printing

Released on 2013-10-14 as [v0.8.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v0.8.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

* Improved ocamldoc for BE/LE modules.
* Add Travis-CI test scripts and fix `test.sh` script compilation.
* Support int32/int64 constant values in cenum like `VAL = 0xffffffffl`, useful for 32-bit hosts.
* Check and raise error in case of negative offsets for blits (#4).
* Correctly preserve the sequence after a constant constructor is set during a `cenum` definition.
* Do not repeat the `sizeof_<field>` binding for every get/set field (should be no externally observable change).
* Add `Cstruct.hexdump_to_buffer` to make spooling hexdump output easier.
* Generate `hexdump_foo` and `hexdump_foo_to_buffer` prettyprinting functions for a `cstruct foo`.


### mirage-block-xen-0.2.4: Fix for unaligned reads

Released on 2013-10-13 as [0.2.4](https://github.com/mirage/mirage-block-xen/releases/tag/0.2.4). See <https://github.com/mirage/mirage-block-xen> for full history.

0.2.4 (13-Oct-2013)
* fix reading non-page aligned sectors


### ocaml-vchan-v0.9.3: Bug fix release 0.9.3

Released on 2013-10-09 as [v0.9.3](https://github.com/mirage/ocaml-vchan/releases/tag/v0.9.3). See <https://github.com/mirage/ocaml-vchan> for full history.

0.9.3 (2013-10-09):
* Fix an overflow in a client read from the vchan buffer.

0.9.2 (2013-10-02):
* Add Travis continuous integration scripts.
* Add explicit dependency on OCaml 4.00+

0.9.1 (2013-09-27):
* Remove 'blocking' parameter

0.9 (2013-08-23):
* Initial public release.


### mirage-platform-v0.9.7: Xen performance and stability improvements

Released on 2013-10-06 as [v0.9.7](https://github.com/mirage/mirage-platform/releases/tag/v0.9.7). See <https://github.com/mirage/mirage-platform> for full history.

* Add Travis continuous integration scripts.
* [xen] fix suspend/resume
* [xen] switch to interrupts (SCHEDOP_block) rather than polling (SCHEDOP_poll)
  to allow more than 128 event channels
* [xen] add Activations.after interface to help drivers avoid losing interrupts


### mirage-block-xen-0.2.3: Bugfix release

Released on 2013-10-05 as [0.2.3](https://github.com/mirage/mirage-block-xen/releases/tag/0.2.3). See <https://github.com/mirage/mirage-block-xen> for full history.

* testing via travis
* use new mirage-platform Activations.after interface

### ocaml-xenstore-1.2.5: Stable bugfix release

Released on 2013-10-04 as [1.2.5](https://github.com/mirage/ocaml-xenstore/releases/tag/1.2.5). See <https://github.com/mirage/ocaml-xenstore> for full history.

* Add Travis continuous integration scripts
* fix a spurious EQUOTA failure when processing transactions


### ocaml-vchan-0.9.2: Release 0.9.2

Released on 2013-10-02 as [0.9.2](https://github.com/mirage/ocaml-vchan/releases/tag/0.9.2). See <https://github.com/mirage/ocaml-vchan> for full history.

0.9.2 (2013-10-02):
* Add Travis continuous integration scripts.
* Add explicit dependency on OCaml 4.00+

0.9.1 (2013-09-27):
* Remove 'blocking' parameter

0.9 (2013-08-23):
* Initial public release.

### ocaml-tuntap-v0.7.0: Add FreeBSD support

Released on 2013-09-28 as [v0.7.0](https://github.com/mirage/ocaml-tuntap/releases/tag/v0.7.0). See <https://github.com/mirage/ocaml-tuntap> for full history.

* Add FreeBSD support.
* Add Travis continuous integration scripts.


### ocaml-cow-v0.7.0: Support XML base, and build improvements

Released on 2013-09-25 as [v0.7.0](https://github.com/mirage/ocaml-cow/releases/tag/v0.7.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Add an OPAM script that installs the right dependencies.
* Make native dynlink optional if not supported by the toolchain.
* Add support for `<xml:base>` in Atom feeds.


### ocaml-uri-v1.3.10: Fix toplevel usage

Released on 2013-09-05 as [v1.3.10](https://github.com/mirage/ocaml-uri/releases/tag/v1.3.10). See <https://github.com/mirage/ocaml-uri> for full history.

* Rename `Install_printer` to `Uri_top` to prevent conflict with other libraries with similar name (#24).


### ocaml-uri-v1.3.9: Support OCaml 3.12.1 again

Released on 2013-08-30 as [v1.3.9](https://github.com/mirage/ocaml-uri/releases/tag/v1.3.9). See <https://github.com/mirage/ocaml-uri> for full history.

1.3.9 (2013-08-30):
* Add back support for OCaml 3.12.1 by fixing the compiler-libs linking.


### ocaml-dns-v0.7.0: Use Ipaddr and functional processor interfaces

Released on 2013-08-26 as [v0.7.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.7.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Add path argument to `Resolv_conf in Dns_resolver.config.
* `Dns_resolver.t` is now a record type rather than a first-class module.
* Fix `mldig` server and port options.
* Change `Zone.load_zone` to `Zone.load` and make it functional over `Loader.db`.
* Use `Ipaddr.V4.t` addresses in favor of Cstruct or Uri_IP representations.
* Fix `RRSIG` signed type to be of the answer rather than the question.
* Fix `ANY` queries.
* Add `Buf` to provide a nickname for `char Bigarray`s.
* Change `Packet.{parse,marshal}` to use Buf.t rather than exposing Cstruct.t
* Change `Packet.parse` to remove name map parameter
* Factor protocol modules into `Protocol` with default DNS implementations
* Add first-class `PROCESSOR` module to `Dns_server` for contextual
  protocol extensions
* Change `Dns_server.listen` to accept processor
* Rename `Dns_server.listen_with_zonebuf` and `Dns_server.listen_with_zonefile`
  to `Dns_server.serve_with_zonebuf` and `Dns_server.serve_with_zonefile` resp.
* Add `processor_of_process`, `process_of_zonebuf`,
  `eventual_process_of_zonefile`, and `serve_with_processor` to `Dns_server`
* Rename `Query.query_answer` to `Query.answer`
* Add `Query.response_of_answer` and `Query.answer_of_response`
* Move `Dns_resolver.build_query` to `Query.create`
* By default, DNS packet IDs are randomly generated with Random
* `Dns_resolver` now supports simultaneous resolver protocol requests
* Fix reversed multiple TXT parse bug
* Move DNSSEC implementation to <//github.com/dsheets/ocaml-dnssec>


### mirage-platform-v0.9.5: Regression test improvements 

Released on 2013-08-09 as [v0.9.5](https://github.com/mirage/mirage-platform/releases/tag/v0.9.5). See <https://github.com/mirage/mirage-platform> for full history.

* Add the `mir-rt` regression runner to `scripts/` (not installed).
* Unhook `mir-run` from the build, as Mirari replaces it.
* [xen] Port Netif to use the `Macaddr` module from `ocaml-ipaddr`.


### mirage-tcpip-v0.9.4: Switch to external Ipaddr library

Released on 2013-08-09 as [v0.9.4](https://github.com/mirage/mirage-tcpip/releases/tag/v0.9.4). See <https://github.com/mirage/mirage-tcpip> for full history.

* Use the `Ipaddr` external library and remove the homebrew
  equivalents in `Nettypes`.


### ocaml-cow-v0.6.2: Improve code highlighting and XML parsing

Released on 2013-07-30 as [v0.6.2](https://github.com/mirage/ocaml-cow/releases/tag/v0.6.2). See <https://github.com/mirage/ocaml-cow> for full history.

* Fix code highlighting of integer literals with underscores.
* Fix XML parsing and printing for fragments and full documents.
* Fix handling of whitespaces in antiquotation attributes.


### ocaml-pcap-0.3.3: Renamed to pcap-format

Released on 2013-07-25 as [0.3.3](https://github.com/mirage/ocaml-pcap/releases/tag/0.3.3). See <https://github.com/mirage/ocaml-pcap> for full history.

### xen-disk-1.0.2: Build dependency change only

Released on 2013-07-25 as [1.0.2](https://github.com/mirage/xen-disk/releases/tag/1.0.2). See <https://github.com/mirage/xen-disk> for full history.

vhd -> vhd-disk -> vhd-format

### mirage-tcpip-v0.9.3: Network manager interface cleanups

Released on 2013-07-18 as [v0.9.3](https://github.com/mirage/mirage-tcpip/releases/tag/v0.9.3). See <https://github.com/mirage/mirage-tcpip> for full history.

* Changes in module Manager: Removed some functions from the `.mli
  (plug/unplug) and added some modifications in the way the Manager
  interacts with the underlying module Netif. The Netif.create function
  does not take a callback anymore.

### mirage-platform-v0.9.3: Xen grant table bug fixes, and FreeBSD support

Released on 2013-07-18 as [v0.9.3](https://github.com/mirage/mirage-platform/releases/tag/v0.9.3). See <https://github.com/mirage/mirage-platform> for full history.

* [xen] Prevent spinning in `Activations.run` when a thread is blocked and then awakened.
* [xen] Gnt.grant_table_index is now an int, was an int32.
* [xen] Cleaned some C stubs files, mainly page_stubs.c
* [xen] Improved module Netif: The function create do not take a callback anymore, hidden some private function from the .mli.
* [unix] Add support for building and running on FreeBSD.

### mirage-platform-v0.9.2: Xen stability and interface improvements

Released on 2013-07-09 as [v0.9.2](https://github.com/mirage/mirage-platform/releases/tag/v0.9.2). See <https://github.com/mirage/mirage-platform> for full history.

* [xen] Add Netif test to wait for a fixed number of ring slots > 0
* [xen] Add Evtchn.close to Xen backend.
* [xen] Disable tree-loop-distribute-patterns to workaround crash with
  gcc-4.8.  Temporary fix until we isolate the bug.
* [xen] Improved the interface of Io_page, implement some missing bits
  in Gnt.
* [xen] Several modules now have an interface similar to the one in
  the libxc bindings for OCaml. This makes it possible to write one
  application that can be compiled for the UNIX or the Xen backend.


### mirage-tcpip-v0.9.2: Improve TCP state machine

Released on 2013-07-09 as [v0.9.2](https://github.com/mirage/mirage-tcpip/releases/tag/v0.9.2). See <https://github.com/mirage/mirage-tcpip> for full history.

* Improve TCP state machine for connection teardown.
* Limit fragment number to 8, and coalesce buffers if it goes higher.
* Adapt to mirage-platform-0.9.2 API changes.

### ocaml-cow-0.6.1: Syntax highlighting and better XHTML output 

Released on 2013-07-03 as [0.6.1](https://github.com/mirage/ocaml-cow/releases/tag/0.6.1). See <https://github.com/mirage/ocaml-cow> for full history.

* Tweak CSS syntax highlighting of OCaml code to fit Anil's superior colour taste.
* Add a `Code.ocaml_fragment` to get just the syntax highlighted bits without the wrapper tags.
* Expose a `decl` option to make the `Xml.to_string` declaration prefix optional.
* Do not output a `<?xml` declaration in `Html.to_string`.


### ocaml-ctypes-ocaml-ctypes-0.1: ocaml-ctypes 0.1

Released on 2013-06-05 as [ocaml-ctypes-0.1](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/ocaml-ctypes-0.1). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

Initial release.

