### mirage-tcpip-v1.1.3: Expose IPV4 module in the STACKV4 functor

Released on 2014-04-29 as [v1.1.3](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.3). See <https://github.com/mirage/mirage-tcpip> for full history.

* Expose IPV4 through the STACKV4 interface.

This requires the corresponding mirage-types package in Mirage 1.1.2

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


### ocaml-cohttp-v0.11.1: Add Lwt SimpleHTTPServer, and bugfixes

Released on 2014-04-17 as [v0.11.1](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.11.1). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Remove an errant async_ssl reference left in the _oasis file that is
  now handled by the Conduit library (#116).
* Add an Lwt-based SimpleHTTPServer equivalent as `cohttp-server-lwt` (#108).
* `Cohttp.Connection.t` now exposes sexp accessor functions (#117).


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

### ocaml-cohttp-v0.9.16: Sexp support for most types

Released on 2014-02-10 as [v0.9.16](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.9.16). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Add some module type equalities in `Cohttp_lwt_unix` so that
  `Cohttp_lwt_unix.Server.Request.IO.ic` can be equivalen to `Lwt_io.input_channel`.
* Add sexp converters to most Cohttp types (#83).
* Improve Travis tests to cover more upstream users of Cohttp.
* Refactor build flags to let the portable Lwt-core be built independently of Lwt.unix.


### mirage-tcpip-v1.1.0: Rewritten interfaces that are now functorized over V1_LWT

Released on 2014-02-05 as [v1.1.0](https://github.com/mirage/mirage-tcpip/releases/tag/v1.1.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* Rewrite of the library as a set of functors that parameterize the
  stack across the `V1_LWT` module types from Mirage 1.1.x.  This removes
  the need to compile separate Xen and Unix versions of the stack.


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

### io-page-v1.0.0: Unify Xen/Unix into subpackages

Released on 2014-01-16 as [v1.0.0](https://github.com/mirage/io-page/releases/tag/v1.0.0). See <https://github.com/mirage/io-page> for full history.

This makes it easier to depend on Io_page by upstream libraries

### ocaml-uri-v1.3.13: Add sexp converters

Released on 2014-01-16 as [v1.3.13](https://github.com/mirage/ocaml-uri/releases/tag/v1.3.13). See <https://github.com/mirage/ocaml-uri> for full history.

Expose s-expression accessors for most of the Uri external interface, to make it possible to serialize it to human readable form easily.

### mirage-1.0.4: Improved debugging and IDE support

Released on 2014-01-14 as [1.0.4](https://github.com/mirage/mirage/releases/tag/1.0.4). See <https://github.com/mirage/mirage> for full history.

The Makefile generated by `mirage configure` now includes debugging, symbols and annotation support for both the new-style binary annotations and the old-style `.annot` files.

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

### ocaml-cow-v0.8.0: Proper Markdown support

Released on 2013-12-12 as [v0.8.0](https://github.com/mirage/ocaml-cow/releases/tag/v0.8.0). See <https://github.com/mirage/ocaml-cow> for full history.

* Add Travis continuous integration scripts.
* Add `Omd_markdown` module based on the `omd` library.
* Note: The `Markdown` and `Markdown_github` modules are now deprecated and will be removed before 1.0.


### mirage-platform-v1.0.0: Xen fixes and cleanups

Released on 2013-12-12 as [v1.0.0](https://github.com/mirage/mirage-platform/releases/tag/v1.0.0). See <https://github.com/mirage/mirage-platform> for full history.

* Set `Sys.os_type` to Unix in the Xen backend to help compatibility (#78).
* Suppress another dietlibc linker warning for vprintf in Xen.


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


