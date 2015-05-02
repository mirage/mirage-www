### mirage-flow-1.0.1: Support for mirage-types 2.3.0

Released on 2015-04-28 as [1.0.1](https://github.com/mirage/mirage-flow/releases/tag/1.0.1). See <https://github.com/mirage/mirage-flow> for full history.

* Add `Fflow.error_message`

### mirage-block-volume-v0.10.0: Add support for wiping PVs

Released on 2015-04-28 as [v0.10.0](https://github.com/mirage/mirage-block-volume/releases/tag/v0.10.0). See <https://github.com/mirage/mirage-block-volume> for full history.

- PV wipe: this obscures the labels
- PV unwipe: this reveals the hidden labels, as an undo

### ocaml-tar-0.3.0: interoperability and portability improvements

Released on 2015-04-28 as [0.3.0](https://github.com/mirage/ocaml-tar/releases/tag/0.3.0). See <https://github.com/mirage/ocaml-tar> for full history.

- add Tar.Make functor which allows easier integration with `camlzip`
- always initialise tar header unused bytes to 0 (previously would use uninitialised data)
- modernise Travis CI scripts to use OPAM 1.2 workflow.

### mirage-block-volume-v0.9.2: Idempotent redo-log

Released on 2015-04-27 as [v0.9.2](https://github.com/mirage/mirage-block-volume/releases/tag/v0.9.2). See <https://github.com/mirage/mirage-block-volume> for full history.

* Fixes to ensure redo-log is idempotent. This has resulted in some interface changes.

### ocaml-cohttp-v0.17.1: Improved Async buffer handling

Released on 2015-04-24 as [v0.17.1](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.17.1). See <https://github.com/mirage/ocaml-cohttp> for full history.

* [async] Limit buffer size to a maximum of 32K in the Async backend
  (#330 from Stanislav Artemkin).
* Add `Cohttp.Conf.version` with the library version number included.
* Remove debug output from `cohttp-curl-async`.
* Add the beginning of a `DESIGN.md` document to explain the library structure.


### mirage-tcpip-v2.4.1: Merge between 2.4.0 and 2.3.1

Released on 2015-04-21 as [v2.4.1](https://github.com/mirage/mirage-tcpip/releases/tag/v2.4.1). See <https://github.com/mirage/mirage-tcpip> for full history.

### mirage-platform-v2.3.1: Fix uninstallation of Xen libraries

Released on 2015-04-19 as [v2.3.1](https://github.com/mirage/mirage-platform/releases/tag/v2.3.1). See <https://github.com/mirage/mirage-platform> for full history.

Fix uninstall of `mirage-xen-ocaml` (#126, patch from @hannesm)


### ocaml-cohttp-v0.17.0: Support more HTTP methods, Link support and stability improvements

Released on 2015-04-18 as [v0.17.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.17.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:
* `CONNECT` and `TRACE` methods added to `Code`.Exhaustive matches will need updating.

New features and bug fixes:
* `Link` header parsing has been added as `Cohttp.Link`, `Header.get_links` and `Header.add_links`
* `cohttp_server_*` now obeys `HEAD` requests and responds 405 to unknown methods
* `Cohttp_async.Server.response` type is now exposed as a `response * body` pair
* Failure to read a body in a pipelined response no longer terminates the stream
* Fix `cohttp_curl_lwt -X HEAD` sending empty chunked body (#313)
* Fix a bug which left extra `\r\n` in buffer at end of chunked reads
* Fix handling of request URI for query strings and `CONNECT` proxies (#308, #318)
* Fix precedence of `Host` header when request-URI is absolute URI
* Fix request URI path to be non-empty except for * requests (e.g. `OPTIONS *`)

### ocaml-conduit-v0.8.2: Make Mirage_TLS an optional dependency

Released on 2015-04-18 as [v0.8.2](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.2). See <https://github.com/mirage/ocaml-conduit> for full history.

Make TLS optional in `Conduit_mirage`, and disable it by default so that it is a developer-only option until it is properly released. It can be enabled by setting the `HAVE_MIRAGE_LWT` env variable.


### ocaml-conduit-v0.8.1: Plug Unix resource leaks and support latest Async_ssl

Released on 2015-04-17 as [v0.8.1](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.1). See <https://github.com/mirage/ocaml-conduit> for full history.

* Support Async_SSL version 112.24.00 and higher.
* Add a TLS echo server in `tests/async/`
* [lwt] Do not leak socket fd when a connect or handshake 
  operation fails (#56 via Edwin Torok).
* [async] Do not leak pipes in SSL handling (#54 from Trevor Smith).


### mirage-http-v2.2.0: Rename `HTTP` to `Cohttp_mirage` and expose the `Server` functor

Released on 2015-04-16 as [v2.2.0](https://github.com/mirage/mirage-http/releases/tag/v2.2.0). See <https://github.com/mirage/mirage-http> for full history.

* Do not user `lwt.syntax`
* Rename `HTTP` to `Cohttp_mirage` (#9)
* Expose `Cohttp_mirage_io`
* Expose a `Server` functor which depends only on mirage's `FLOW` (no dependency
  to `Conduit` anymore in this case)
* Modernize Travis CI scripts

### mirage-v2.4.0: Support latest tcpip, conduit and mirage-http. Remove `mirage run`, add `opam depext` and Makefile.user`

Released on 2015-04-16 as [v2.4.0](https://github.com/mirage/mirage/releases/tag/v2.4.0). See <https://github.com/mirage/mirage> for full history.

* Support `mirage-http.2.2.0`
* Support `conduit.0.8.0`
* Support `tcpip.2.4.0`
* Add time and clock parameters to IPv4 (#362, patch from @yomimono)
* Support for `ocaml-tls` 0.4.0.
* Conduit now takes an optional TLS argument, allowing servers to support
  encryption. (#347)
* Add the ability to specify `Makefile.user` to extend the generated
  `Makefile`. Also `all`, `build` and `clean` are now extensible make
  targets.
* Remove the `mirage run` command (#379)
* Call `opam depext` when configuring (#373)
* Add opam files for `mirage` and `mirage-types` packages
* Fix `mirage --version` (#374)
* Add a `update-doc` target to the Makefile to easily update the online
  documentation at http://mirage.github.io/mirage/

### mirage-block-volume-v0.9.1: With oasis generated files and without a bisect dependency.

Released on 2015-04-15 as [v0.9.1](https://github.com/mirage/mirage-block-volume/releases/tag/v0.9.1). See <https://github.com/mirage/mirage-block-volume> for full history.

No code change from v0.9.0, but following the release guidelines.

### mirage-block-volume-v0.9.0: First release

Released on 2015-04-10 as [v0.9.0](https://github.com/mirage/mirage-block-volume/releases/tag/v0.9.0). See <https://github.com/mirage/mirage-block-volume> for full history.

The first release of mirage-block-volume

### jitsu-0.1: v0.1

Released on 2015-04-10 as [0.1](https://github.com/MagnusS/jitsu/releases/tag/0.1). See <https://github.com/magnuss/jitsu> for full history.

First release.

### ocaml-cohttp-v0.16.1: Fix Uri Handling

Released on 2015-04-09 as [v0.16.1](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.16.1). See <https://github.com/mirage/ocaml-cohttp> for full history.

New features and bug fixes:
* Fix handling of request paths starting with multiple slashes (#308)


### ocaml-ctypes-0.4.1: ocaml-ctypes 0.4.1

Released on 2015-04-06 as [0.4.1](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.4.1). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.

### ocaml-cohttp-v0.16.0: Improved interface for headers, bug fixes for Uri, empty chunks, uninstalling binaries

Released on 2015-04-04 as [v0.16.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.16.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:
* Response.t and Request.t fields are no longer mutable
* [lwt] Fix types in `post_form` to be a `string * string list` instead
  of a `Header.t` (#257)
* Simplify the `Net` signature which needs to be provided for Lwt servers
  to not be required.  Only the Lwt client needs a `Net` functor argument
  to make outgoing connections. (#274)
* `Request.has_body` does not permit a body to be set for methods that
  RFC7231 forbids from having one (`HEAD`, `GET` and `DELETE`).

New features and bug fixes:
* Fix linking problem caused by sub-libraries using cohttp modules outside the
  cohttp pack.
* Added async client for S3. (#304)
* Fix String_io.read_line to trim '\r' from end of string (#300)
* Fix `cohttp-server-lwt` to correctly bind to a specific interface (#298).
* Add `Cohttp_async.request` to send raw, umodified requests.
* Supplying a `content-range` or `content-range` header in any client
  request will always override any other encoding preference (#281).
* Add a `cohttp-lwt-proxy` to act as an HTTP proxy. (#248)
* Extend `cohttp-server-async` file server to work with HTTPS (#277).
* Copy basic auth from `Uri.userinfo` into the Authorization header
  for HTTP requests. (#255)
* Install binaries via an OPAM `.install` file to ensure that they are
  reliably uninstalled. (#252)
* Use the `magic-mime` library to add a MIME type by probing filename
  during static serving in the Lwt/Async backends. (#260)
* Add `Cohttp.Header.add_opt_unless_exists` to set a header only if
  an override wasn't supplied, and to initialise a fresh Header value
  if none is present.
* Do not override user-supplied headers in `post_form` or `redirect`.
* `Request.make` does not inject a `transfer-encoding` header if there
  is no body present in the request (#246).
* `Server.respond` no longer overrides user-supplied headers that
  specify the `content-length` or `transfer-encoding` headers (#268).
* `cohttp_server_lwt` and `cohttp_server_async` now include sizes in
  directory listing titles
* Add `Header.add_multi` to initialise a header structure with multiple
  fields more efficiently (#272).
* Expose `IO.ic` and `IO.oc` types for `Cohttp_async` (#271).
* Skip empty body chunks in `Transfer_io.write` (#270).
* With the Lwt backend, `read` hangs if trying to fetch more than
  `Sys.max_string_length` (which can be triggered on 32-bit platforms).
  Read only a maximum that fits into a string (#282).
* `cohttp-curl-lwt` now takes http method as parameter (#288)


### ocaml-cstruct-v1.6.0: Add `fillv`, `memset` and comparison functions

Released on 2015-04-03 as [v1.6.0](https://github.com/mirage/ocaml-cstruct/releases/tag/v1.6.0). See <https://github.com/mirage/ocaml-cstruct> for full history.

* Add `memset` to set all the bytes of a cstruct value efficiently (#49)
* More useful `Invalid_argument` parameters (#48).
* Fix `to_sexp` to expose only the current view (#44 from David Kaloper).
* Add `compare` and `equal` (#23, #24 and #45 from David Kaloper).
* Add `fillv` to copy over a list of buffers (from Thomas Leonard).
* Shift to centralised Travis scripts.

### mirage-tcpip-v2.3.1: Permit excess trailing bytes in an IP frame

Released on 2015-03-31 as [v2.3.1](https://github.com/mirage/mirage-tcpip/releases/tag/v2.3.1). See <https://github.com/mirage/mirage-tcpip> for full history.

* Do not raise an assertion if an IP frame has extra trailing bytes (#221).


### ocaml-dns-v0.14.1: Fix namespace pollution, add composition functions, Async_kernel support

Released on 2015-03-30 as [v0.14.1](https://github.com/mirage/ocaml-dns/releases/tag/v0.14.1). See <https://github.com/mirage/ocaml-dns> for full history.

* Reduce namespace pollution in `name.ml` to avoid breaking with Cstruct 1.6.0+.
* Add a `Dns_server.compose` function to make it easier to build resolution pipelines (#58).
* Add a `Dns_server_mirage` functor (#55).
* Add `Dns_resolver.resolve_pkt` to support custom query packets (#49).
* Split out the experimental Async_resolver into a `Async_kernel` and Unix libraries.
  This introduces the `dns.async-unix` library.

### ocaml-conduit-v0.8.0: TLS compatibility

Released on 2015-03-24 as [v0.8.0](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.0). See <https://github.com/mirage/ocaml-conduit> for full history.

*  Add TLS client support for Mirage (#50)
* Do not overwrite the default name resolver for Mirage (#49)
* Add TLS support using the pure OCaml TLS stack (#46).
* Replace the Mirage `Make_flow` functor with `Dynamic_flow` that is
  easier to extend with more flow types.

### mirage-tcpip-v2.4.0: ARP improvement

Released on 2015-03-24 as [v2.4.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.4.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* ARP improvements (#118)

### mirage-bootvar-xen-0.2: v0.2

Released on 2015-03-19 as [0.2](https://github.com/mirage/mirage-bootvar-xen/releases/tag/0.2). See <https://github.com/mirage/mirage-bootvar-xen> for full history.

- `get` no longer raises exception
- add `get_exn` which raises `Parameter_not_found` on error
- return `'Ok of t | 'Error of msg` in `create` instead of raising exception on error
- remove debug output

### mirage-bootvar-xen-0.1: v0.1

Released on 2015-03-19 as [0.1](https://github.com/mirage/mirage-bootvar-xen/releases/tag/0.1). See <https://github.com/mirage/mirage-bootvar-xen> for full history.

First release

### ocaml-tls-0.4.0: solar eclipse - special edition release

Released on 2015-03-19 as [0.4.0](https://github.com/mirleft/ocaml-tls/releases/tag/0.4.0). See <https://github.com/mirleft/ocaml-tls> for full history.

* client authentication (both client and server side)
* server side SNI configuration (see sni.md)
* SCSV server-side downgrade prevention (contributed by Gabriel de Perthuis @g2p #5)
* remove RC4 ciphers from default config #8
* support for AEAD ciphers, currently CCM #191
* proper bounds checking of handshake fragments #255
* disable application data between CCS and Finished #237
* remove secure renegotiation configuration option #256
* expose epoch in mirage interface, implement 2.3.0 API (error_message)
* error reporting (type failure in engine.mli) #246
* hook into Lwt event loop to feed RNG #254

### ocaml-x509-0.3.0: solar eclipse - special edition release

Released on 2015-03-19 as [0.3.0](https://github.com/mirleft/ocaml-x509/releases/tag/0.3.0). See <https://github.com/mirleft/ocaml-x509> for full history.

* more detailed error messages (type certificate_failure modified)
* no longer Printf.printf debug messages
* error reporting: `Ok of certificate option | `Fail of certificate_failure
* fingerprint verification can work with None as host (useful for client authentication where host is not known upfront)
* API reshape: X509 is the only public module, X509.t is the abstract certificate

### mirage-platform-v2.3.0: split the `mirage-xen` package into 3

Released on 2015-03-17 as [v2.3.0](https://github.com/mirage/mirage-platform/releases/tag/v2.3.0). See <https://github.com/mirage/mirage-platform> for full history.

* Split `mirage-xen` into three opam packages: `mirage-xen-posix` (includes and mini-libc), `mirage-xen-ocaml` (OCaml runtime) and `mirage-xen` (bindings and OCaml OS libraries) (#125, patch from @hannesm)

### mirage-platform-v2.2.3: Add opam files and remove `page_stubs.c`

Released on 2015-03-16 as [v2.2.3](https://github.com/mirage/mirage-platform/releases/tag/v2.2.3). See <https://github.com/mirage/mirage-platform> for full history.

* Add opam files for `mirage-xen` and `mirage-unix` OPAM packages
* Remove page_stubs.c, now provided by io-page (#122, patch from @hannesm)

### io-page-v1.5.0: Fix equality and have self-contained stubs

Released on 2015-03-16 as [v1.5.0](https://github.com/mirage/io-page/releases/tag/v1.5.0). See <https://github.com/mirage/io-page> for full history.

* Fix equallity of io-pages (#17, patch from @hannesm)
* Import C stubs from mirage-platform (#18, patch from @hannesm)

### irmin-0.9.4: better concurrency properties

Released on 2015-03-16 as [0.9.4](https://github.com/mirage/irmin/releases/tag/0.9.4). See <https://github.com/mirage/irmin> for full history.

* Ensure that `Irmin.update` and `Irmin.merge` are atomic.
* Fix `Irmin.clone` of an empty branch
* Add `Irmin.RW.compare_and_test` that the backends now have to implement
  to guarantee atomicity of Irmin's high-level operations.
* Add `Irmin.Private.Lock` to provide per-handler, per-key locking. This
  can be used by backend to implement simple locking policies.
* Add `Lwt.t` to the return type of `Irmin.tag` and `Irmin.tag_exn`
* Do not throw [Not_found]. Now all the `_exn` function raise `Invalid_argument`
  (#144)
* Remove `Irmin.switch` and `Irmin.detach`
* Add `Irmin.history` to get the branch history as a DAG of heads (#140).
* Fix the computation of lcas (#160)

### ocaml-ctypes-0.4.0: ocaml-ctypes 0.4.0

Released on 2015-03-13 as [0.4.0](https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.4.0). See <https://github.com/ocamllabs/ocaml-ctypes> for full history.

See [CHANGES.md](https://github.com/ocamllabs/ocaml-ctypes/blob/master/CHANGES.md) for details.


### mirage-net-xen-v1.4.1: Close race condition on device connection

Released on 2015-03-12 as [v1.4.1](https://github.com/mirage/mirage-net-xen/releases/tag/v1.4.1). See <https://github.com/mirage/mirage-net-xen> for full history.

Wait for the backend network device to enter the `Connected` state before transmitting packets.  This fixes a race condition in a fast-booting unikernel that caused the first packet to be lost (#20, #23).


### mirage-v2.3.0: Interface cleanups and entropy support

Released on 2015-03-10 as [v2.3.0](https://github.com/mirage/mirage/releases/tag/v2.3.0). See <https://github.com/mirage/mirage> for full history.

* Remove the `IO_PAGE` module type from `V1`. This has now moved into the
  `io-page` pacakge (#356)
* Remove `DEVICE.connect` from the `V1` module types.  When a module is
  functorised over a `DEVICE` it should only have the ability to
  *use* devices it is given, not to connect to new ones. (#150)
* Add `FLOW.error_message` to the `V1` module types to allow for
  generic handling of errors. (#346)
* Add `IP.uipaddr` as a universal IP address type. (#361)
* Support the `entropy` version 0.2+ interfaces. (#359)
* Check that the `opam` command is at least version 1.2.0 (#355)
* Don't put '-classic-display' in the generated Makefiles. (#364)


### ocaml-fat-v0.10.3: Add explicit `connect` function, and modernise Travis scripts

Released on 2015-03-10 as [v0.10.3](https://github.com/mirage/ocaml-fat/releases/tag/v0.10.3). See <https://github.com/mirage/ocaml-fat> for full history.

* Add an explicit `connect` function to interfaces. (#39)
* MemoryIO.connect now takes an FS.t, not an FS.id. (#39)
* Use centralised Travis CI test scripts.
* Add local `opam` file for OPAM 1.2 pinning workflow.

### mirage-tcpip-v2.3.0: Support for Mirage 2.3.0's `connect` removal

Released on 2015-03-09 as [v2.3.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.3.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fix `STACKV4` for the `DEVICE` signature which has `connect` removed (in Mirage types 2.3+).


### mirage-entropy-v0.2.0: Support for xentropyd

Released on 2015-03-09 as [v0.2.0](https://github.com/mirage/mirage-entropy/releases/tag/v0.2.0). See <https://github.com/mirage/mirage-entropy> for full history.

* Do not wrap `Entropy_unix` in a functor as it is meant to be used directly.
* Xen: read entropy from a Xen PV device.  This is implemented by the `xentropyd` daemon.


### ocaml-crunch-v1.4.0: Add an explicit `connect` function to generated code

Released on 2015-03-09 as [v1.4.0](https://github.com/mirage/ocaml-crunch/releases/tag/v1.4.0). See <https://github.com/mirage/ocaml-crunch> for full history.

* Add an explicit `connect` function to the signature of generated code. (#13)
* Use centralised Travis CI scripts.


### mirage-console-v2.1.3: Simplify build and install `mirage-console-cli` tool

Released on 2015-03-08 as [v2.1.3](https://github.com/mirage/mirage-console/releases/tag/v2.1.3). See <https://github.com/mirage/mirage-console> for full history.

* Fix installation of Unix library defaults by splitting out the base Unix dependency and the Xenctrl ones.  This needs a new `--enable-xenctrl` flag that explicitly depends on the Xen libraries being installed. (#36)
* Install the `mirage-console-cli` executable if it is built.

### mirage-fs-unix-v1.1.4: Add explicit `connect` function, and modernise Travis scripts

Released on 2015-03-08 as [v1.1.4](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.1.4). See <https://github.com/mirage/mirage-fs-unix> for full history.

* Add explicit `connect` signature into interface (#8).
* Add an `opam` file for OPAM 1.2 pinning workflow.
* Add Travis CI unit test file.

### mirage-console-v2.1.2: Add explicit `connect` function, and modernise Travis scripts

Released on 2015-03-08 as [v2.1.2](https://github.com/mirage/mirage-console/releases/tag/v2.1.2). See <https://github.com/mirage/mirage-console> for full history.

* Add an explicit `connect` function to interface. (#34)
* Modernise Travis scripts with central sourcing.
* Only build Unix executable if relevant `xenctrl` libraries are installed.

### mirage-block-unix-v1.2.2: Add an explicit `connect` function, and OPAM pinning support

Released on 2015-03-08 as [v1.2.2](https://github.com/mirage/mirage-block-unix/releases/tag/v1.2.2). See <https://github.com/mirage/mirage-block-unix> for full history.

* Expose an explicit `connect` function in the interface signature. (#20)
* Modernise Travis scripts with centralised ones.
* Add local `opam` file for OPAM 1.2 workflow.


### mirage-block-xen-v1.3.1: Add `connect` method to interface

Released on 2015-03-07 as [v1.3.1](https://github.com/mirage/mirage-block-xen/releases/tag/v1.3.1). See <https://github.com/mirage/mirage-block-xen> for full history.

* Add an explicit `connect` to the interface signature (#35)


### mirage-net-xen-v1.4.0: Add an explicit `connect` function

Released on 2015-03-07 as [v1.4.0](https://github.com/mirage/mirage-net-xen/releases/tag/v1.4.0). See <https://github.com/mirage/mirage-net-xen> for full history.

* Add explicit `connect` function to interface signature (#19)

### mirage-net-unix-v2.2.0: Support tuntap persistent interfaces

Released on 2015-03-07 as [v2.2.0](https://github.com/mirage/mirage-net-unix/releases/tag/v2.2.0). See <https://github.com/mirage/mirage-net-unix> for full history.

* Leave the tuntap persistence flag unchanged (#9, from @infidel)
* Add explicit `connect` function to interface (#10)

### ocaml-cow-v1.2.1: Support new ezjsonm in syntax extension

Released on 2015-03-05 as [v1.2.1](https://github.com/mirage/ocaml-cow/releases/tag/v1.2.1). See <https://github.com/mirage/ocaml-cow> for full history.

* Fix compatibility of the `json` syntax extension with `ezjsonm` version 0.4 (#68)

### mirage-platform-v2.2.2: Add generic engine hooks and restore GC tracing support

Released on 2015-03-04 as [v2.2.2](https://github.com/mirage/mirage-platform/releases/tag/v2.2.2). See <https://github.com/mirage/mirage-platform> for full history.

* Add generic hooks to mainloop to support background tasks. (#120)
* [xen] Report trace events for GC again; this was disabled temporarily
  in the 2.2.0 release. (#119)

### mirage-net-macosx-v1.1.0: Interface compatibility improvements with newer Mirage libraries

Released on 2015-03-04 as [v1.1.0](https://github.com/mirage/mirage-net-macosx/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-net-macosx> for full history.

- Add an explicit `connect` function to interface (#1).
- Support the `Io_page` 1.4.0+ API. (#2).


### mirage-tcpip-v2.2.3: IPv6 and robustness improvements

Released on 2015-03-04 as [v2.2.3](https://github.com/mirage/mirage-tcpip/releases/tag/v2.2.3). See <https://github.com/mirage/mirage-tcpip> for full history.

* Add ICMPv6 error reporting functions (#101)
* Add universal IP address converters (#108)
* Add `error_message` functions for human-readable errors (#98)
* Improve debug logging for ICMP Destination Unreachable packets.
* Filter incoming frames by MAC address to stop sending unnecessary RSTs. (#114)
* Unhook unused modules `Sliding_window` and `Profiler` from the build. (#112)


### mirage-flow-1.0.0: Initial release

Released on 2015-02-26 as [1.0.0](https://github.com/mirage/mirage-flow/releases/tag/1.0.0). See <https://github.com/mirage/mirage-flow> for full history.

* Add `Fflow`(functional flows)
* Add `Lwt_io_flow` to convert between Mirage and Lwt flows

### ocaml-uri-v1.8.0: Add URI ordering and comparison functions, and bugfixes

Released on 2015-02-17 as [v1.8.0](https://github.com/mirage/ocaml-uri/releases/tag/v1.8.0). See <https://github.com/mirage/ocaml-uri> for full history.

* `Uri.with_port` no longer sets the host fragment to a blank value if both
   the host and port are empty (#63).
* `Uri.compare` imposes an ordering by host, scheme, port, userinfo, path,
  query, and finally fragment. (#55).
* Uri is now an `OrderedType` and can be used directly in Maps and Sets (#55).
* Remove deprecation warnings with OCaml 4.02.0+ (#58).
* Drop support for OCaml 3.12.1, and now require OCaml 4.00.1+.
* Modernise Travis scripts to use OPAM 1.2 workflow.


### ocaml-cohttp-v0.15.2: Stability improvements and utility functions

Released on 2015-02-15 as [v0.15.2](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.15.2). See <https://github.com/mirage/ocaml-cohttp> for full history.

* When transfer encoding is unknown, read until EOF when body size is unknown. (#241)
* Add some missing documentation to `Cohttp.S.IO` signature. (#233)
* Add `Cohttp.Header.mem` to check if a header exists.
* Add `Cohttp.Conf` module to expose the library version number. (#259)
* Add `Cohttp.Header.add_unless_exists` to update a key if it doesn't already exist. (#244)
* Add `Cohttp.Header.get_location` to retrieve redirection information. (#254)
* [async] Clean up the `Net.lookup` function to use `Or_error.t` instead of raising. (#247)
* [tests] Add more tests for `content-range` handling. (#249)


### mirage-xen-minios-v0.7.0: Disable stack protection on x86_64

Released on 2015-02-12 as [v0.7.0](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.7.0). See <https://github.com/mirage/mirage-xen-minios> for full history.

Stack protection doesn't work yet on x86_64, so explicitly disable it to prevent boot-time crashes on systems that enable it by default on their host toolchains (like Ubuntu).

### ocaml-magic-mime-v1.0.0: Initial public release

Released on 2015-02-08 as [v1.0.0](https://github.com/mirage/ocaml-magic-mime/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-magic-mime> for full history.

This library contains a database of MIME types that maps filename extensions
into MIME types suitable for use in many Internet protocols such as HTTP or
e-mail.  It is generated from the `mime.types` file found in Unix systems, but
has no dependency on a filesystem since it includes the contents of the
database as an ML datastructure.


### ocaml-cow-v1.2.0: Now with valid HTML5 Output

Released on 2015-02-06 as [v1.2.0](https://github.com/mirage/ocaml-cow/releases/tag/v1.2.0). See <https://github.com/mirage/ocaml-cow> for full history.

* When serializing HTML, only self-close void elements.
* New `Html.doctype` value of the HTML5 DOCTYPE.
* New `Html.output` and `Html.output_doc` functions for generic polyglot output.
* Atom support is now deprecated in favor of Syndic
* New `Html.img` constructor for easy creation of <img> tags
* New `Html.a` constructor for easy creation of <a> tags
* Deprecate function `Html.html_of_link` and type `Html.link`

### ocaml-git-1.4.10: Fix the smart HTTP protocol

Released on 2015-02-05 as [1.4.10](https://github.com/mirage/ocaml-git/releases/tag/1.4.10). See <https://github.com/mirage/ocaml-git> for full history.

* Fix support for the smart HTTP protocol (report by @talex5, mirage/irmin#138)


### ocaml-git-1.4.9: Remove `OGITTMPDIR`

Released on 2015-02-04 as [1.4.9](https://github.com/mirage/ocaml-git/releases/tag/1.4.9). See <https://github.com/mirage/ocaml-git> for full history.

* Remove the `OGITTMPDIR` and alway store temp files under  `git/tmp` (mirage/irmin#132)


### irmin-0.9.3: 

Released on 2015-02-04 as [0.9.3](https://github.com/mirage/irmin/releases/tag/0.9.3). See <https://github.com/mirage/irmin> for full history.

* Fix the invalidation of the view caches (report by @gregtatcam).
  This was causing some confusing issues where views' sub-keys where
  not properly updated to to their new values when the view is merged
  back to the store. The issues is a regression introduced in 0.9.0.
* Add post-commit hooks for the HTTP server.
* Add `Irmin.watch_tags` to monitor tag creation and desctructions.
* Fix `Irmin.push`
* Add `Irmin.with_hrw_view` to easily use transactions.
* Add a phantom type to `Irmin.t` to denote the store capabilities
  read-only, read-write or branch-consistent.
* The `~old` argument of a merge function can now be optional to
  signify that there is no common ancestor.
* Expose `Irmin.with_rw_view` to create a temporary, in-memory and
  mutable view of the store. This can be used to perform atomic
  operations in the store (ie. non-persistent transactions).
* Simplify the view API again
* Expose the task of previous commits. This let the user access
  the Git timestamp and other info such as the committer name (#90)
* The user-defined merge functions now takes an `unit -> 'a result
  Lwt.t` argument for `~old` (instead of `'a`). Evalutating the
  function will compute the least-common ancestors. Merge functions
  which ignore the `old` argument don't have to pay the cost of
  computing the lcas anymore.
* Expose `S.lcas` to get the least common ancestors
* Update to ocaml-git 1.4.6

### ezjsonm-0.4.1: avoid manual coercion 

Released on 2015-02-04 as [0.4.1](https://github.com/mirage/ezjsonm/releases/tag/0.4.1). See <https://github.com/mirage/ezjsonm> for full history.

* Use polymorphic variants subtyping to avoid manual coercion in the
  API (#11, patch from Julien Sagot)

### ocaml-git-1.4.8: Fix bug in LRU cache, flush the `cat-file` commands

Released on 2015-02-04 as [1.4.8](https://github.com/mirage/ocaml-git/releases/tag/1.4.8). See <https://github.com/mirage/ocaml-git> for full history.

* Fix LRU cache: SHA1 should be unique in the cache (regression
  introduced in 1.4.3). This was causing confusing read results
  under load.
* Reading objects now updates the LRU cache
* Fix a regression in `ogit cat-file` which were displaying nothing
  for small objects.


### ocaml-git-1.4.7: Fix for non-bare repositories, remove stdout/stderr messages

Released on 2015-02-03 as [1.4.7](https://github.com/mirage/ocaml-git/releases/tag/1.4.7). See <https://github.com/mirage/ocaml-git> for full history.

* Fix the filesystem updates for non-bare repositories (reported by @avsm)
* `Git.write_index` now takes an optional `index` argument
* Index entries should be fixed alphabetically
* Remove raw printf (#60)
* More flexibility on where to write temp files. The directory name can be
  configured by write calls, and the default is `OGITTMPDIR` if set,
  then `Filename.get_temp_dir_name` -- as it was in 1.4.5, see #51


### ocaml-nocrypto-0.3.1: The Ditch-Your-OS minor

Released on 2015-02-01 as [0.3.1](https://github.com/mirleft/ocaml-nocrypto/releases/tag/0.3.1). See <https://github.com/mirleft/ocaml-nocrypto> for full history.

Now with Mirage/Xen compatibility. Shout-out to @talex5!

### ocaml-fat-0.10.2: Narrow dependency on IO_PAGE signature

Released on 2015-01-31 as [0.10.2](https://github.com/mirage/ocaml-fat/releases/tag/0.10.2). See <https://github.com/mirage/ocaml-fat> for full history.

* Fixed destroy, which previously would overwrite the entry with
  uninitialised data, which might not set the deleted flag.
* Require only `get_buf` from `IO_PAGE`
* Fix travis.
* test: use OUnit's arg parser.
* return errors from size rather than raising Fs_error.

### ocaml-git-1.4.6: Improve LRU settings and add the `git.top` package

Released on 2015-01-29 as [1.4.6](https://github.com/mirage/ocaml-git/releases/tag/1.4.6). See <https://github.com/mirage/ocaml-git> for full history.

* Expose `Git.Value.Cache.set_size` to change the LRU cache size
* Reduce the default LRU cache size (in 1.4.4 it was set to 64k, now it's 512)
* More precise type for commit dates
* Add `git.top` to load toplevel printers for Git values


### mirage-v2.2.1: Fix external C library linking and command line bug fixes

Released on 2015-01-29 as [v2.2.1](https://github.com/mirage/mirage/releases/tag/v2.2.1). See <https://github.com/mirage/mirage> for full history.

* Fix logging errors when `mirage` output is not redirected. (#355)
* Do not reverse the order of C libraries when linking.  This fixes Zarith
  linking in Xen mode. (#341).
* Fix typos in command line help. (#352).


### mirage-block-xen-v1.3.0: Update to latest io-page 1.4.0 interface

Released on 2015-01-29 as [v1.3.0](https://github.com/mirage/mirage-block-xen/releases/tag/v1.3.0). See <https://github.com/mirage/mirage-block-xen> for full history.

* Update to `io-page.1.4.0` interface.
* Add an `opam` 1.2 file for more convenient development.
* Simplify travis configuration via centralised scripts.

### ocaml-dns-v0.14.0: Interface improvements for DNS packet manipulation

Released on 2015-01-29 as [v0.14.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.14.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Renamed `Packet.QM` to `Packet.Q_Normal` and `QU` to `Q_mDNS_Unicast` for
  clarity and added more detailed doc comments. Added constructor function
  `Packet.make_question` for convenience. (#41)
* Support `io-page` 1.3.0+ interface. (#40)


### io-page-v1.4.0: Add Cstruct to Io_page conversion function

Released on 2015-01-28 as [v1.4.0](https://github.com/mirage/io-page/releases/tag/v1.4.0). See <https://github.com/mirage/io-page> for full history.

* Add `of_cstruct_exn` as a safe way to turn a Cstruct back into an `Io_page.t`.
* Expose `page_size` constant in interface.


### ocaml-vchan-v2.0.2: Support the Io_page 1.3.0 interface

Released on 2015-01-27 as [v2.0.2](https://github.com/mirage/ocaml-vchan/releases/tag/v2.0.2). See <https://github.com/mirage/ocaml-vchan> for full history.

The `io-page` 1.3.0 API changed the type of the page to be private, and so this library now ensures that it allocates the grant pages via Io_page.  This is backwards compatible with older versions of Io_page.

### mirage-net-unix-v2.1.0: Support for Io_page 1.3.0

Released on 2015-01-27 as [v2.1.0](https://github.com/mirage/mirage-net-unix/releases/tag/v2.1.0). See <https://github.com/mirage/mirage-net-unix> for full history.

* Support `io-page` 1.3.0+ interface.
* Add local `opam` file for convenient OPAM 1.2 developer workflow.


### mirage-platform-v2.2.1: Fix modern GCC and Xen compilation

Released on 2015-01-27 as [v2.2.1](https://github.com/mirage/mirage-platform/releases/tag/v2.2.1). See <https://github.com/mirage/mirage-platform> for full history.

Fix Xen compilation with `gcc 4.8+` by disabling the stack protector and `-fno-tree-loop-distribute-patterns` (not compatible with MiniOS).  These missing flags were a regression from 2.1.3, which did include them.

### ocaml-conduit-v0.7.2: Add error message display function

Released on 2015-01-27 as [v0.7.2](https://github.com/mirage/ocaml-conduit/releases/tag/v0.7.2). See <https://github.com/mirage/ocaml-conduit> for full history.

* Add an `error_message` function to simplify error display (#38).
* Improvements to documentation (#37).

### io-page-v1.3.0: Make the `Io_page.t` type private 

Released on 2015-01-26 as [v1.3.0](https://github.com/mirage/io-page/releases/tag/v1.3.0). See <https://github.com/mirage/io-page> for full history.

* Make `Io_page.t` type private. Otherwise, any old array of bytes can be used as an `Io_page.t`. (#14)
* Switch to using the `Bytes` module instead of `String`.

### ocaml-dns-v0.13.0: Improved multicast DNS support

Released on 2015-01-26 as [v0.13.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.13.0). See <https://github.com/mirage/ocaml-dns> for full history.

* Add support for multicast DNS (RFC6762) in the trie. (#35 from Luke Dunstan)
  * mDNS doesn't use SOA nor delegation (RFC 6762 section 12), so some minor changes
    to Trie are required to handle this.
  * mDNS doesn't echo the questions in the response (RFC 6762 section 6), except
    in legacy mode, so a `bool` argument was added to `Query.response_of_answer`.
  * `Query.answer` still exists but now `Query.answer_multiple` is also available
    for answering multiple questions in one query to produce a single answer
    (RFC 6762 section 5.3). One caveat is that responses may exceed the maximum
    message length, but that is not really specific to mDNS. Also, in theory multiple
    questions might require multiple separate response messages in unusual cases,
    but that is complicated and the library does not deal with that yet.
  * `Query.answer_multiple` takes an optional function to allow the caller to control
    the `cache-flush` bit. This bit is only set for records that have been "confirmed
    as unique". Using a callback requires minimal changes here but puts the burden of
    maintaining uniqueness state elsewhere.
  * `Query.answer_multiple` takes an optional function to filter the answer, in order
    to support "known answer suppression" (RFC 6762 section 7.1). Again, using a callback
    requires minimal change to the core, but later on the mDNS-specific known answer
    suppression logic could move into the `Query` module if that turns out to be simpler.
  * A query for `PTR` returns additional records for `SRV` and `TXT`, to support efficient
    service discovery.
  * `Trie.iter` was added to support mDNS announcements.
* Switch to `Bytes` instead of `String` for eventual `-safe-string` support.
* Partially remove some error printing to stderr. (#36)

Unit tests were added for some of the changes above, including a test-only
dependency on `pcap-format`.


### mirage-net-xen-v1.3.0: Page pooling and stability fixes under high receive load

Released on 2015-01-24 as [v1.3.0](https://github.com/mirage/mirage-net-xen/releases/tag/v1.3.0). See <https://github.com/mirage/mirage-net-xen> for full history.

* When waiting for space in the transmit queue, we would sometimes fail
  to notice when space became available. (#15)
* Copy out-bound data into pre-shared pages for performance, security
  and simplicity. (#17)
* Use a centrally sourced Travis file and test OCaml 4.02+ as well.


### ocaml-vchan-v2.0.1: Improve configure script and error message functionality

Released on 2015-01-24 as [v2.0.1](https://github.com/mirage/ocaml-vchan/releases/tag/v2.0.1). See <https://github.com/mirage/ocaml-vchan> for full history.

* add an `error_message` function to convert a Vchan error
  into a human-readable string. (#60)
* Improve error messages from the `configure` output (#61).
* Use modern centrally sourced Travis script for OPAM 1.2.

### mirage-platform-v2.2.0: Add support for OCaml 4.02+ in Xen

Released on 2015-01-23 as [v2.2.0](https://github.com/mirage/mirage-platform/releases/tag/v2.2.0). See <https://github.com/mirage/mirage-platform> for full history.

This releases adds support for OCaml 4.02+ compilation, and changes the Xen
backend build for Mirage significantly by:

* removing the OCaml compiler runtime from the mirage-platform, which makes
  it simpler to work across multiple revisions of the compiler.  It now uses
  the `ocaml-src` OPAM package to grab the current switch's version of the
  OCaml runtime.
* split the Xen runtime build into discrete `pkg-config` libraries:
  * `mirage-xen-posix.pc` : in the `xen-posix/` directory, is the nano-posix
     layer built with no knowledge of OCaml
  * `mirage-xen-minios.pc`: defines the `__INSIDE_MINIOS__` macro to expose
     internal state via the MiniOS headers (for use only by libraries that
     know exactly what they are doing with the MiniOS)
  * `mirage-xen-ocaml.pc`: in `xen-ocaml/core/`, this builds the OCaml asmrun,
     Bigarray and Str bindings using the `mirage-xen-posix` layer.
  * `mirage-xen-ocaml-bindings.pc`: in `xen-ocaml/bindings/`, these are bindings
     required by the OCaml libraries to MiniOS.  Some of the bindings use MiniOS
     external state and hence use `mirage-xen-minios`, whereas others
    (`cstruct_stubs` and `barrier_stubs` are just OCaml bindings and so just
    use `mirage-xen-posix`).
  * `mirage-xen.pc`: depends on all the above to provide the same external
    interface as the current `mirage-platform`.

The OCaml code is now built using OASIS, since the C code is built entirely
separately and could be moved out into a separate OPAM package entirely.


### mirage-console-v2.1.1: Add an `error_message` for console messages

Released on 2015-01-23 as [v2.1.1](https://github.com/mirage/mirage-console/releases/tag/v2.1.1). See <https://github.com/mirage/mirage-console> for full history.

Add an `error_message` function to turn an `error` into a string.


### mirage-platform-v2.1.3: Improved reporting of top-level errors in Xen backend

Released on 2015-01-23 as [v2.1.3](https://github.com/mirage/mirage-platform/releases/tag/v2.1.3). See <https://github.com/mirage/mirage-platform> for full history.

* [xen] Fix error handling in `OS.Main.run` to enable a top-level
  exception to signal to the Xen toolstack that it crashed (versus a
  clean exit). This in turn lets `on_crash="preserve"` behaviour work
  better in Xen VM description files.
* Remove `mirage-xen.pc` file on uninstall.


### irmin-0.9.2: 0.9.0 bug-fix

Released on 2015-01-19 as [0.9.2](https://github.com/mirage/irmin/releases/tag/0.9.2). See <https://github.com/mirage/irmin> for full history.

* Fix `S.of_head` for the HTTP client (regression introduced in 0.9.0)
* Fix regression in displaying the store's graph over HTTP introduced by
  0.9.0.
* Fix regression in watch handling introduced in 0.9.0.
* Fix regressions in `Views` introduced in 0.9.0. (thx @buzzheavyyear for
  the report)
* Always add a commit when calling a update function (`Irmin.update`
  `Irmin.remove`, `Irmin.remove_rec`) even if the contents' store have
  not changed.
* The [head] argument of [Git_unix.config] now has a proper type.
* Expose synchronisation functions for basic Irmin stores.
* The user-provided merge function now takes optional values. The
  function is now called much more often during recursive merges
  (even if one of the 3 buckets of the 3-way merge function is not
  filled -- in that case, it uses `None`).
* Also expose the type of the keys in the type basic Irmin stores. Use
  `('key, 'value) Irmint.t` instead of `'value Irmin.t`.
* The user-defined `merge` functions now take the current filename being
  merged as an additional argument.
* The user-defined `Contents` should expose a `Path` sub-module. Keys of
  the resulting Irmin store will be of type `Path.t`.
* Fix `irmin init --help`. (#103)


### ocaml-git-1.4.5: Support packed references

Released on 2015-01-19 as [1.4.5](https://github.com/mirage/ocaml-git/releases/tag/1.4.5). See <https://github.com/mirage/ocaml-git> for full history.

* Support `packed-refs` files, to read references packed by `git gc` (reported
  by Gregory Tsipenyuk)
* Fix the filesystem backend when TMPDIR is not on the same partition as the
  Git repository (#51, patch from @vklquevs)

### ocaml-git-1.4.4: More protocol support, more stability

Released on 2015-01-12 as [1.4.4](https://github.com/mirage/ocaml-git/releases/tag/1.4.4). See <https://github.com/mirage/ocaml-git> for full history.

* Support the smart HTTP Git protocol (#26)
* Best-effort creation of files when expanding the index into the filesystem:
  Skip the invalid filenames and continue. Users are expected to sanitize
  their filenames if they want to use a non-bare repository (#11)
* Overwrite changed file when expanding the index into the filesystem (#4)
* Do not recompute the hash of blob files when expanding the index into the
  filesystem. This help fixing a speed issue with non-bare repo with lots of
  file.
* Rename `{write,read}_cache` to `{write,read}_index`
* Rename Cache to Index
* Expose the protocol capabilities to the client
* Support side-band-64k protocol capability (#44)
* Fix support for git+ssh (#39)
* Expose zlib compression level (#41)
* Maintain a cache of opened files (#29, Pierre Chambart)

### mirage-tcpip-v2.2.2: Restore ARP fixes

Released on 2015-01-11 as [v2.2.2](https://github.com/mirage/mirage-tcpip/releases/tag/v2.2.2). See <https://github.com/mirage/mirage-tcpip> for full history.

Fixes from 2.0.0 relating to ARP race conditions were lost in a merge conflict, and have now been restored.

### ocaml-cohttp-v0.15.1: Improved command-line tools and Lwt 2.4.7 support

Released on 2015-01-11 as [v0.15.1](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.15.1). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Lwt 2.4.7 renamed `blit_bytes_string` to `blit_to_bytes`, so depend
  on the newer API now. (#230)
* Use `cmdliner` in all of the Lwt client and server binaries.  This gives
  `cohttp-lwt-server` a nice Unix-like command-line interface now that
  can be viewed with the `--help` option. (#218 via Runhang Li)
* Improve `oasis` constraints and regenerate `opam` file (#229 via
  Christophe Troestler).


### shared-memory-ring-1.1.1: Traceability release

Released on 2015-01-09 as [1.1.1](https://github.com/mirage/shared-memory-ring/releases/tag/1.1.1). See <https://github.com/mirage/shared-memory-ring> for full history.

* add profiling/tracing support
* add a "Front.wait_for_free" function to wait for n free slots
* add opam file

### irmin-0.9.1: Support for Cohttp 0.14.0+ interface

Released on 2014-12-26 as [0.9.1](https://github.com/mirage/irmin/releases/tag/0.9.1). See <https://github.com/mirage/irmin> for full history.

This point release updates the Irmin HTTP layer to be compatible with Cohttp 0.14.0 and higher.

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

### irmin-0.9.0: Improved efficiency and removal of Core_kernel dependency

Released on 2014-12-20 as [0.9.0](https://github.com/mirage/irmin/releases/tag/0.9.0). See <https://github.com/mirage/irmin> for full history.

* Improve the efficiency of the Git backend
* Expose a cleaner API for the Unix backends
* Expose a cleaner public API
* Rename `Origin` into `Task` and use it pervasively through the API
* Expose a high-level REST API over HTTP (#80)
* Fix the Git backend to stop constantly overwrite `.git/HEAD` (#76)
* Add a limit on concurrently open files (#93, #75)
* Add `remove_rec` to remove directories (#74, #85)
* Remove dependency to `core_kernel` (#22, #81)
* Remove dependency to `cryptokit and `sha1` and use `nocrypto` instead
* Remove dependency to caml4
* Fix writing contents at the root of the store (#73)
* More efficient synchronization protocol between Irmin stores (#11)


### ocaml-git-1.4.3: Fix caching and concurrent operations

Released on 2014-12-19 as [1.4.3](https://github.com/mirage/ocaml-git/releases/tag/1.4.3). See <https://github.com/mirage/ocaml-git> for full history.

* Fix regression introduced in 1.4.3 appearing when
  synchronising big repositories (#38)
* Fix concurrent read/write by using an atomic rename (#35)
* Tree objects can also point to commits (@codinuum)
* Reduce allocation (@codinuum)
* Use LRU cache instead of an unbounde Hashtl
  (code imported for Simon Cruanes's CCache implementation)
* Remove the crazy unbounded caching in Git.FS. Use the LRU
  everywhere (#22)
* Fix fd leaking (#29)
* Update to dolog.1.0
* Remove dependency to camlp4
* Remove lots of warnings
* Move `Git_unix` and `Git_mirage` in their own subdirs as it
  was causing issues to oasis (#5, Simon Cruanes)
* Use `Bytes` instead of `String` (#5, Simon Cruanes)


### cowabloga-v0.0.9: Compatibility with Cohttp 0.14.x

Released on 2014-12-19 as [v0.0.9](https://github.com/mirage/cowabloga/releases/tag/v0.0.9). See <https://github.com/mirage/cowabloga> for full history.

Add compatibility with Cohttp 0.14.x APIs.

### ocaml-github-v0.9.4: Add bindings for organisation teams and repositories

Released on 2014-12-19 as [v0.9.4](https://github.com/mirage/ocaml-github/releases/tag/v0.9.4). See <https://github.com/mirage/ocaml-github> for full history.

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


### ezjsonm-0.4.0: Add intXX combinatores, bug fixes for option and unit types

Released on 2014-12-17 as [0.4.0](https://github.com/mirage/ezjsonm/releases/tag/0.4.0). See <https://github.com/mirage/ezjsonm> for full history.

* Clean-up the typed representation of serializable JSON
    (#5, report and patch from Rudi Grinberg)
* add int32/int64/triple combinators
* fix a bug with the option types
* fix the type of the `unit` combinator


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

Released on 2014-11-28 as [v0.9.3](https://github.com/mirage/ocaml-github/releases/tag/v0.9.3). See <https://github.com/mirage/ocaml-github> for full history.

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

Released on 2014-11-09 as [v0.9.2](https://github.com/mirage/ocaml-github/releases/tag/v0.9.2). See <https://github.com/mirage/ocaml-github> for full history.

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

Released on 2014-11-03 as [v0.9.1](https://github.com/mirage/ocaml-github/releases/tag/v0.9.1). See <https://github.com/mirage/ocaml-github> for full history.

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

Released on 2014-11-02 as [v0.9.0](https://github.com/mirage/ocaml-github/releases/tag/v0.9.0). See <https://github.com/mirage/ocaml-github> for full history.

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


