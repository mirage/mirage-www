### ocaml-cohttp-v0.19.0: Support Lwt 2.5.0 and assorted interface cleanups

Released on 2015-08-05 as [v0.19.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.19.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

Compatibility breaking interface changes:
* Remove `read_form` from the `Request/Response/Header` interfaces
  as this should be done in `Body` handling instead (#401).

New features and bug fixes:
* Remove `IO.write_line` as it was unused in any interfaces.
* Do not use the `lwt` camlp4 extension. No observable external difference.
* Do not return a code stacktrace in the default 500 handler.
* Add `Cohttp.Header.compare` (#411)
* Fix typos in CLI documentation (#413 via @moonlightdrive)
* Use the Lwt 2.5.0 buffer API.
* `Cohttp_lwt.read_response` now has a non-optional `closefn` parameter (#400).
* Add a `Cohttp_lwt_s` module that contains all the Lwt module types
  in one convenient place (#397).

### alcotest-0.4.4: Fix regressions

Released on 2015-07-31 as [0.4.4](https://github.com/mirage/alcotest/releases/tag/0.4.4). See <https://github.com/mirage/alcotest> for full history.

* Fix of the format of log filenames
* Fix a regression in 0.4.* which were hiding error messages when using wrong
  command-line arguments

### ocaml-dns-v0.15.3: Critical Dns_server_unix.listen regression bugfix

Released on 2015-07-30 as [v0.15.3](https://github.com/mirage/ocaml-dns/releases/tag/v0.15.3). See <https://github.com/mirage/ocaml-dns> for full history.

0.15.3 (2015-07-30):
* Fix regression in 0.15.2 which prevented `Dns_server_unix.listen` from
  answering more than one query (#80 from @MagnusS)


### ocaml-cow-v1.2.2: Fix int32 support in JSON syntax

Released on 2015-07-30 as [v1.2.2](https://github.com/mirage/ocaml-cow/releases/tag/v1.2.2). See <https://github.com/mirage/ocaml-cow> for full history.

* Fix int32 conversion to float in JSON syntax (#76, by Antoine Luciani)
* Fix a regression introduced in 1.2.0 in `make test` (#72 by @dsheets)
* Modernize `.travis.yml` to use `ocaml-travisci-skeleton` (by @dsheets)
* Remove direct dependency on re (#71, by @rgrinberg)
* Add a `.merlin` file (#70, by @rgrinberg)

### mirage-tcpip-v2.6.0: Better ARP

Released on 2015-07-30 as [v2.6.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.6.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* ARP now handles ARP frames, not Ethernet frames with ARP payload
  (#164, by @hannesm)
* Check length of received ethernet frame to avoid cstruct exceptions
  (#117, by @hannesm)
* Pull arpv4 module out of ipv4. Also add unit-tests for the newly created
  ARP library  (#155, by @yomimono)

### mirage-v2.6.0: Better ARP and tar-formatted block devices

Released on 2015-07-29 as [v2.6.0](https://github.com/mirage/mirage/releases/tag/v2.6.0). See <https://github.com/mirage/mirage> for full history.

* Better ARP support. This needs `mirage-tcpip.2.6.0` (#419, by @yomimono)
  - [mirage-types] Remove `V1.IPV4.input_arp`
  - [mirage-types] Expose `V1.ARP` and `V1_LWT.ARP`
  - Expose a `Mirage.arp` combinator
* Provide noop configuration for default_time (#435, by @yomimono)
* Add `Mirage.archive` and `Mirage.archive_of_files` to support attaching files
  via a read-only tar-formatted BLOCK (#432, by @djs55)
* Add a .merlin file (#428, by @Drup)


### mirage-flow-1.0.3: support latest lwt

Released on 2015-07-29 as [1.0.3](https://github.com/mirage/mirage-flow/releases/tag/1.0.3). See <https://github.com/mirage/mirage-flow> for full history.

* Support lwt 2.5.0


### alcotest-0.4.3: Flush display and UTF8 documentation strings

Released on 2015-07-28 as [0.4.3](https://github.com/mirage/alcotest/releases/tag/0.4.3). See <https://github.com/mirage/alcotest> for full history.

* Flush formatter for `Alcotest.check` (#27, by @edwintorok)
* Handle UTF8 for test documentation strings (#5)

### mirage-seal-0.4.2: Support for case-sensitive filesystems

Released on 2015-07-28 as [0.4.2](https://github.com/mirage/mirage-seal/releases/tag/0.4.2). See <https://github.com/mirage/mirage-seal> for full history.

* preserve case for data and keys dirs (#18, by @lnmx)

### mirage-block-volume-v0.12.0: Even more debugability

Released on 2015-07-23 as [v0.12.0](https://github.com/mirage/mirage-block-volume/releases/tag/v0.12.0). See <https://github.com/mirage/mirage-block-volume> for full history.

* Update to use the new tracing ability of shared-block-ring
* Set creation_time, creation_host on LVs


### mirage-xen-minios-v0.8.0: Depend on minios-xen opam package

Released on 2015-07-23 as [v0.8.0](https://github.com/mirage/mirage-xen-minios/releases/tag/v0.8.0). See <https://github.com/mirage/mirage-xen-minios> for full history.

* Use Mini-OS 0.7.
* New releases of Mini-OS will no longer require this package to be updated.

### mirage-fs-unix-v1.2.0: Remove use of `Sys.command` and much consistent semantics

Released on 2015-07-22 as [v1.2.0](https://github.com/mirage/mirage-fs-unix/releases/tag/v1.2.0). See <https://github.com/mirage/mirage-fs-unix> for full history.

* Remove the use of unescaped `Sys.command` (#12, by @hannesm)
* Add tests for read, write, mkdir, size; make them pass (#10, by @yomimono)

### ocaml-tar-v0.4.1: Bugfix release

Released on 2015-07-21 as [v0.4.1](https://github.com/mirage/ocaml-tar/releases/tag/v0.4.1). See <https://github.com/mirage/ocaml-tar> for full history.

- Tar_mirage now works on top of BLOCK devices with sector sizes < 4096 

### mirage-seal-0.4.1: HSTS headers

Released on 2015-07-21 as [0.4.1](https://github.com/mirage/mirage-seal/releases/tag/0.4.1). See <https://github.com/mirage/mirage-seal> for full history.

* When serving https, send a HSTS header (#5, #16 by @hannesm)

### ocaml-tar-v0.4.0: Added Mirage support

Released on 2015-07-19 as [v0.4.0](https://github.com/mirage/ocaml-tar/releases/tag/v0.4.0). See <https://github.com/mirage/ocaml-tar> for full history.

- add tar.mirage in ocamlfind, containing Tar_mirage which
  exposes a BLOCK device as a KV_RO

### mirage-seal-0.4.0: Add HTTP to HTTPS redirection

Released on 2015-07-17 as [0.4.0](https://github.com/mirage/mirage-seal/releases/tag/0.4.0). See <https://github.com/mirage/mirage-seal> for full history.

* Add redirection from HTTP to HTTPS (#5, #14 by @Drup)
* Add a Dockerfile

### irmin-0.9.8: Mirage support

Released on 2015-07-17 as [0.9.8](https://github.com/mirage/irmin/releases/tag/0.9.8). See <https://github.com/mirage/irmin> for full history.

* Fix wrong interaction of in-memory views and temporary branches in the store
  (#237)
* Fix `Irmin.update_tag` for HTTP clients
* Initial MirageOS support. Expose `Mirage_irmin.KV_RO` to surface an
  Irmin store as a read-only key/value store implementing `V1_LWT.KV_RO
  (#107)
* Expose `Irmin_git.Memory_ext. This allows the Git memory backend to be
  configured with a non-empty conduit context.
* Expose `Irmin.SYNC`
* Transmit client tasks to the HTTP server on DELETE too (#227, @dsheets)
* Do note expose private types in the public interface (#234, @koleini)
* Fix missing zero padding for date pretty-printing (#228, @dsheets)
* Update the tests to use `ocaml-git.1.6.0`
* Improve the style of the HTTP commit graph.
* Constraint the string tags to contain only alpha-numeric characters
  and few mores (`-`, `_`, '.' and `/`) (#186)
* Fix a race condition in `Irmin.clone`. (#221)
* Escpate double quotes in the output of commit messages to workaround
  HTML display issues. (#222)

### mirage-v2.5.1: Make FS.page_aligned_buffer less abstract in mirage-types

Released on 2015-07-17 as [v2.5.1](https://github.com/mirage/mirage/releases/tag/v2.5.1). See <https://github.com/mirage/mirage> for full history.

* [mirage-types] Expose `V1_LWT.FS.page_aligned_buffer = Cstruct.t`


### ocaml-git-1.6.2: Support 32bit architectures

Released on 2015-07-17 as [1.6.2](https://github.com/mirage/ocaml-git/releases/tag/1.6.2). See <https://github.com/mirage/ocaml-git> for full history.

* Support 32 bit platform by avoiding creating large strings. This also improve
  the performance of reading and synchronizin large pack files
  (#103, @gregtatcam)

### ocaml-git-1.6.1: Bug fixes in the smart HTTP protocol

Released on 2015-07-14 as [1.6.1](https://github.com/mirage/ocaml-git/releases/tag/1.6.1). See <https://github.com/mirage/ocaml-git> for full history.

* Fix a bug in `ogit pull` using the smart HTTP protocol when the HTTP temporary
  buffer could sometimes be overfill.
* Avoid closing twice the same fd in the smart HTTP protocol.
* Avoid the GC to close a fd while we are still using a channel built on top of
  it -- this affects the smart HTTP protocol only.
* Add an opam file for the `mirage-git` package.

### ocaml-conduit-v0.8.6: Add `Conduit_mirage.Context`

Released on 2015-07-14 as [v0.8.6](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.6). See <https://github.com/mirage/ocaml-conduit> for full history.

* Add a `Conduit_mirage.Context`, a functor for creating HTTP(s) conduit
  contexts (with a DNS resolver).

### ocaml-conduit-v0.8.5: Fix client-side https resolution for Conduit_mirage

Released on 2015-07-12 as [v0.8.5](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.5). See <https://github.com/mirage/ocaml-conduit> for full history.

* Fix client-side `https://` resolution for `Conduit_mirage`

### ocaml-cohttp-v0.18.3: HTTP pipelining and DELETE improvements

Released on 2015-07-12 as [v0.18.3](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.18.3). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Allow `DELETE` requests to have request bodies (#383).
* Improve the Lwt client `callv` for HTTP/1.1 pipelined
  requests (#379 via Török Edwin).

### ocaml-git-1.6.0: Fix regressions in `Sync.clone`, fix reading hashes in `.git/HEAD`, change API to reset the store and start to improve 32bit support

Released on 2015-07-11 as [1.6.0](https://github.com/mirage/ocaml-git/releases/tag/1.6.0). See <https://github.com/mirage/ocaml-git> for full history.

* Allow some references to contain pointer to other references (#96)
* Improve the support for 32bit architectures (#97)
* Add `Reference.pp_head_contents` and `Reference.equal_head_contents`.
* Remove `Store.clear` and replace it by `Memory.clear`, `Memory.clear_all`
  and `FS.remove`. This let users have a finer control over the memory
  consumption of the program over time (related to #90)
* Rename all `pp_hum` functions into `pp`.
* Fix regression in `Sync.fetch` and add unit-tests (running only in slow mode).
* Fix reading of `.git/HEAD` when the contents is a commit hash.
* Depends on `Stringext` for all the extra string function needed.

### ocaml-git-1.5.3: Fix listing of packed references

Released on 2015-07-10 as [1.5.3](https://github.com/mirage/ocaml-git/releases/tag/1.5.3). See <https://github.com/mirage/ocaml-git> for full history.

* Fix listing of packed references (#98)

### ocaml-nocrypto-0.5.1: Several Species of Small Furry Animals

Released on 2015-07-07 as [0.5.1](https://github.com/mirleft/ocaml-nocrypto/releases/tag/0.5.1). See <https://github.com/mirleft/ocaml-nocrypto> for full history.

* Refuse to enable acceleration if the current host does not support it.
* Honor the `nocrypto-inhibit-modernity` opam variable.

### mirage-tcpip-v2.5.1: Fix regression which causes slow-downs on packet loss, close connection cleanly and extract the channels out

Released on 2015-07-07 as [v2.5.1](https://github.com/mirage/mirage-tcpip/releases/tag/v2.5.1). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fix regression introduced in 2.5.0 where packet loss could lead to the
  connection to become very slow (#157, MagnusS, @talex5, @yomimono and
  @balrajsingh)
* Improve the tests: more logging, more tracing and compile to native code when
  available, etc (@MagnusS and @talex5)
* Do not raise `Invalid_argument("Lwt.wakeup_result")` everytime a connection
  is closed. Also now pass the raised exceptions to `Lwt.async_exception_hook`
  instead of ignoring them transparently, so the user can decide to shutdown
  its application if something wrong happens (#153, #156, @yomomino and @talex5)
* The `channel` library now lives in a separate repository and is released
  separately (#159, @samoht)

### irmin-0.9.7: Fix regression in the Git backend, add HTTP API versionning

Released on 2015-07-06 as [0.9.7](https://github.com/mirage/irmin/releases/tag/0.9.7). See <https://github.com/mirage/irmin> for full history.

* Add a version check for HTTP client and server. The client might add the
  version in the HTTP headers using the `X-IrminVersion` header - the server
  might decide to enfore the version check or not. The server always reply
  with its version in the JSON reply, using a `version` field. The client
  might use that information to bail out nicely instead of failing because
  of some random unmarshalling errors due to API changes (#167)
* Fix a regression in 0.9.5 and 0.9.6 when inserting new child in Git trees.
  This could cause a tree to have duplicate childs having the same names,
  which would confuse the merge functions, make `git fsck` and `git gc`
  complain a lot (with good reasons) and do some fency things with git
  index. The regression has been introduced while trying to fix #190 (the fix
  is in #229)


### mirage-http-v2.5.0: less dependencies

Released on 2015-07-05 as [v2.5.0](https://github.com/mirage/mirage-http/releases/tag/v2.5.0). See <https://github.com/mirage/mirage-http> for full history.

* Depends on `channel` instead of the full `tcpip` stack

### ocaml-dns-v0.15.2: Mirage bugfixes and Lwt improvements

Released on 2015-07-04 as [v0.15.2](https://github.com/mirage/ocaml-dns/releases/tag/v0.15.2). See <https://github.com/mirage/ocaml-dns> for full history.

0.15.2 (2015-07-04):
* Fix incorrect mirage dependency on tcpip
* Improve clarity and formatting of Lwt use
* Remove lwt camlp4 dependency
* Now requires lwt >2.4.7

### mirage-channel-1.0.0: Initial release

Released on 2015-07-03 as [1.0.0](https://github.com/mirage/mirage-channel/releases/tag/1.0.0). See <https://github.com/mirage/mirage-channel> for full history.

* Extract `channel/` from [mirage-tcpip](https://github.com/mirage/mirage-tcpip)

### irmin-0.9.6: Fix slice serialisation and race in watch initialisation

Released on 2015-07-03 as [0.9.6](https://github.com/mirage/irmin/releases/tag/0.9.6). See <https://github.com/mirage/irmin> for full history.

* Fix the datamodel: it is not possible to store data in intermediate nodes
  anymore (#209)
* Fix serialization of slices (#204)
* Do not fail silently when the synchronisation fails (#202)
* Fix a race in the HTTP backend between adding a watch and updating the store.
  In some cases, the watch callback wasn't able to see the first few updates
  (#198)
* Fix a race for all the on-disk backends between adding a watch and updating
  the store. This is fixed by making `Irmin.Private.Watch.listen_dir` and
  `Irmin.Private.Watch.set_listen_dir_hook` synchronous.
* Update the tests to use `alcotest >= 0.4`. This removes the dependency towards
  `OUnit` and `nocrypto` for the tests.
* Make the file-locking code a bit more robust


### alcotest-0.4.2: Better looking outputs

Released on 2015-07-03 as [0.4.2](https://github.com/mirage/alcotest/releases/tag/0.4.2). See <https://github.com/mirage/alcotest> for full history.

* Improve the result outputs

### ocaml-git-1.5.2: Fix serialization of dates, support shallow packs, fix (?) memory leak, etc

Released on 2015-07-03 as [1.5.2](https://github.com/mirage/ocaml-git/releases/tag/1.5.2). See <https://github.com/mirage/ocaml-git> for full history.

* Fix handling of empty paths (#89)
* Fix the serialization of dates in commit objects
* Expose `Git.Packed_value.PIC.pretty`
* Improve the efficiency of `Git_unix.FS.remove`
* Support shallow packs (#81)
* Fix an mmap leak introduced in `1.5.*` (#90)
* Remove the dependency to OUnit for the tests
* Improve the pretty printers and the output of `ogit`


### alcotest-0.4.1: Fix error reporting

Released on 2015-07-02 as [0.4.1](https://github.com/mirage/alcotest/releases/tag/0.4.1). See <https://github.com/mirage/alcotest> for full history.

* Fix regression introduced in 0.4.0: display the error if there is only one error
* Add a testable combinator for options.

### ocaml-tls-0.6.0: sanity and fixes

Released on 2015-07-02 as [0.6.0](https://github.com/mirleft/ocaml-tls/releases/tag/0.6.0). See <https://github.com/mirleft/ocaml-tls> for full history.

from CHANGES:
* API: dropped 'perfect' from forward secrecy in Config.Ciphers:
  fs instead of pfs, fs_of instead of pfs_of
* API: type epoch_data moved from Engine to Core
* removed Cstruct_s now that cstruct (since 1.6.0) provides
  s-expression marshalling
* require at least 1024 bit DH group, use FFDHE 2048 bit DH group
  by default instead of oakley2 (logjam)
* more specific alerts:
  - UNRECOGNIZED_NAME: if hostname in SNI does not match
  - UNSUPPORTED_EXTENSION: if server hello has an extension not present in
    client hello
  - ILLEGAL_PARAMETER: if a parse error occured
* encrypt outgoing alerts
* fix off-by-one in handling empty TLS records: if a record is less than 5
  bytes, treat as a fragment. exactly 5 bytes might already be a valid
  application data frame


### ocaml-x509-0.4.0: all the PKCS!!!11!!!

Released on 2015-07-02 as [0.4.0](https://github.com/mirleft/ocaml-x509/releases/tag/0.4.0). See <https://github.com/mirleft/ocaml-x509> for full history.

from our CHANGES:
* certificate signing request support (PKCS10)
* basic CA functionality (in CA module): create and sign certificate signing requests
* PEM encoding of X.509 certificates, RSA public and private keys, and certificate signing requests
* new module Extension contains X509v3 extensions as polymorphic variants
* expose distinguished_name as polymorphic variant
* type pubkey is now public_key
* function cert_pubkey is now public_key
* functions supports_usage, supports_extended_usage are now in Extension module
* types key_usage, extended_key_usage are now in Extension module
* Encoding.Pem.Cert has been renamed to Encoding.Pem.Certificate
* Encoding.Pem.PK has been renamed to Encoding.Pem.Private_key (now uses type private_key instead of Nocrypto.Rsa.priv)


### ocaml-dns-v0.15.1: Fix critical DNS resolver timeout bug causing unexpected exceptions

Released on 2015-07-02 as [v0.15.1](https://github.com/mirage/ocaml-dns/releases/tag/v0.15.1). See <https://github.com/mirage/ocaml-dns> for full history.

0.15.1 (2015-07-02):
* Fix critical DNS resolver timeout bug causing unexpected exceptions

### ocaml-nocrypto-0.5.0: The Faster-Than-Light Release

Released on 2015-07-02 as [0.5.0](https://github.com/mirleft/ocaml-nocrypto/releases/tag/0.5.0). See <https://github.com/mirleft/ocaml-nocrypto> for full history.

The highlight of this release is the use of AES-NI.

RNG APIs were changed to make them more flexible.

From the `CHANGES.md`:

>0.5.0 (2015-07-02):
* support for AES-NI and SSE2
* support RSA-OAEP and RSA-PSS
* drop ctypes for internal C calls
* generate smaller secret exponents for DH, making operations on large groups much faster
* support dynamic switching of RNG algorithms and decouple `Rng` from `Fortuna`
* module for injectring entropy into RNG on pure Unix (optional)
* `Nocrypto_entropy_lwt.initialize` no longer needs to be synchronized on
* renamed module signatures and modules containing only signatures from `T` to `S`
* changes to `CTR`, `CBC`, `Rsa` and `Dh` APIs



### mirage-flow-1.0.2: Fix build dependencies

Released on 2015-06-30 as [1.0.2](https://github.com/mirage/mirage-flow/releases/tag/1.0.2). See <https://github.com/mirage/mirage-flow> for full history.

* Add explicit dependency to OUnit

### alcotest-0.4.0: Remove dependency to OUnit, add `TESTABLE` combinators

Released on 2015-06-29 as [0.4.0](https://github.com/mirage/alcotest/releases/tag/0.4.0). See <https://github.com/mirage/alcotest> for full history.

* Simplify the use of the library by removing global states -- now calling
  the `run` function multiple times is much more consistent.
* Remove the direct dependency to `OUnit`. Programs using `OUnit` and `Alcotest`
  should continue to work.
* Add a `TESTABLE` signature and a `check` function to check invariants in
  the tested libraries.


### ocaml-uri-v1.9.1: Fix `with_password None` bug

Released on 2015-06-26 as [v1.9.1](https://github.com/mirage/ocaml-uri/releases/tag/v1.9.1). See <https://github.com/mirage/ocaml-uri> for full history.

1.9.1 (2015-06-26):
* Fix `with_password None` when no userinfo present (#78 from Hezekiah M. Carty)


### alcotest-0.3.3: Add a JSON output, allow to call multiple `run` in a program.

Released on 2015-06-22 as [0.3.3](https://github.com/mirage/alcotest/releases/tag/0.3.3). See <https://github.com/mirage/alcotest> for full history.

* Control `--show-errors` using the ALCOTEST_SHOW_ERRORS env variable (#9)
* Add an `and_exit` optional argument to `Alcotest.run` to control
  the exit behavior of the main test function (#4)
* Fix the output of `--version`
* Add a `--json` argument to show the test results as a JSON object
  (#14, by @leowzukw)
* Expose `Alcotest.result` to turn a test into a result

### ocaml-cohttp-v0.18.2: Fix 204 code response headers

Released on 2015-06-19 as [v0.18.2](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.18.2). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Do not add content encoding for 204's (#375)

### ocaml-git-1.5.1: filesystem expansion and remote refs fixes

Released on 2015-06-18 as [1.5.1](https://github.com/mirage/ocaml-git/releases/tag/1.5.1). See <https://github.com/mirage/ocaml-git> for full history.

* Fix filesystem expansion when a filen ame becomes a directory name or when
  a directory name becomes a file name (#87)
* Fix the order of entries in the tree objects (#86)
* Fix the compilation of tests (#85)
* Fetch all remote refs on synchronize (#83, by @AltGr)

### mirage-seal-0.3.1: More memory

Released on 2015-06-17 as [0.3.1](https://github.com/mirage/mirage-seal/releases/tag/0.3.1). See <https://github.com/mirage/mirage-seal> for full history.

* increase default memory to 32MB from 16 (#11, by @yomimono)

### ocaml-git-1.5.0: Improve the pack file API, support conduit 0.8.4, support for short hashes, add mirage sync support

Released on 2015-06-12 as [1.5.0](https://github.com/mirage/ocaml-git/releases/tag/1.5.0). See <https://github.com/mirage/ocaml-git> for full history.

* Compatibility with `cohttp.0.18.` (#80 by @rgrinberg)
* Simplify the mirage sync API to use `conduit 0.8.4` (breaking API changes)
* Change `ogit cat-file` to behave exactly as `git cat-file`
  The previous command is renamed to `ogit cat` (#75 by @codinuum)
* `ogit` now supports short hashes instead of full SHA1 (#75 by @codinuum)
* Add `Git.Pack.Raw.read` to read raw pack files (#75 by @codinuum)
* `Git.Pack_index.t` now uses a cache of entries. This is more efficient
  than the previous representation (#75 by @codinuum)
* Add `Git.Pack_index.mem` to find an entry in the pack index cache
  (#75 by @codinuum)
* Add `Git.Pack_index.find_offset` to find an offset in the pack index
  cache (#75 by @codinuum)
* Add `Git.Packed_value.to_value` to unpack a value stored in a pack file
  (#75 by @codinuum)
* Support synchronisation for MirageOS unikernels (#70)

### mirage-seal-0.3.0: Add `--no-tls`

Released on 2015-06-12 as [0.3.0](https://github.com/mirage/mirage-seal/releases/tag/0.3.0). See <https://github.com/mirage/mirage-seal> for full history.

* Add a `--no-tls` option to not use TLS to serve static files over HTTP only.
* Add Travis CI tests


### irmin-0.9.5: New watch API, fixes to export, views, lca computation. Remove Snapshots.

Released on 2015-06-11 as [0.9.5](https://github.com/mirage/irmin/releases/tag/0.9.5). See <https://github.com/mirage/irmin> for full history.

* Fix `Irmin.export` for the HTTP backend (#196, patch from Alex Zatelepin)
* Fix a race in `Irmin.export` (#196, patch from Alex Zatelepin)
* Add `Task.empty` (the empty task) and `Task.none` (the empty task constructor)
* Completely rewrite the notification mechanism. All the watch functions now
  take a callback as argument and return a de-allocation function. The callbacks
  receive a heads values (the last and current ones) and diff values. (#187)
  - Add `Irmin.watch_head` to watch for the changes of the current branch's head
  - Add `Irmin.watch_tags` to watch for the changes of all the tags in the store
  - Add `Irmin.watch_key` to watch for the changes of the values associated to a
    given key (this is not recursive anymore).
  - Add `View.watch_path` to watch for the changes in a subtree. The function
    return views and the user can use `View.diff` to compute differences between
    views if needed.
* Transfer the HTTP client task to the server to make the commit messages
  relative to the client state (and not the server's) (#136)
* Fix `View.remove` to clean-up empty directories (#190)
* Fix the ordering of tree entries in the Git backend (#190)
* Allow to create a new head from a view and a list of parents with
  `View.make_head` (#188)
* Allow to create an empty temporary branch with `Irmin.empty` (#161)
* Use a pure OCaml implementation of SHA1, do not depend on nocrypto anymore
  (#183, by @talex5)
* Remove `Irmin.Snapshot`. Nobody was using it and it can be easily replaced by
  `Irmin.head`, `Irmin.watch_head` and `Irmin.update_head`.
* Change signature of `Irmin.iter` to include the values and move it into
  the `Irmin.RO` signature.
* Add `Irmin.fast_forward_head` (#172)
* Add `Irmin.compare_and_set_head` (#171)
* Simplify the RW_MAKER signature (#158)
* Fix Irmin_git.RW_MAKER (#159)
* Improve the efficiency of the LCA computation (#174, with @talex5 help)
* By default, explore the full graph when computing the LCAs. The previous
  behavior was to limit the depth of the exploration to be 256 by default.


### mirage-v2.5.0: TLS release

Released on 2015-06-10 as [v2.5.0](https://github.com/mirage/mirage/releases/tag/v2.5.0). See <https://github.com/mirage/mirage> for full history.

* Change the type of the `Mirage.http_server` combinator. The first argument
  (the conduit server configuration) is removed and should now be provided
  at compile-time in `unikernel.ml` instead of configuration-time in
  `config.ml`:

    ```ocaml
(* [config.ml] *)
(* in 2.4 *) let http = http_server (`TCP (`Port 80)) conduit
(* in 2.5 *) let http = http_server conduit

(* [unikernel.ml] *)
let start http =
(* in 2.4 *) http (S.make ~conn_closed ~callback ())
(* in 2.5 *) http (`TCP 80) (S.make ~conn_closed ~callback ())
    ```

* Change the type of the `Mirage.conduit_direct` combinator.
  Previously, it took an optional `vchan` implementation, an optional
  `tls` immplementation and an optional `stackv4` implemenation. Now,
  it simply takes a `stackv4` implementation and a boolean to enable
  or disable the `tls` stack. Users who want to continue to use
  `vchan` with `conduit` should now use the `Vchan` functors inside
  `unikernel.ml` instead of the combinators in `config.ml`. To
  enable the TLS stack:

    ```ocaml
(* [config.ml] *)
let conduit = conduit_direct ~tls:true (stack default_console)

(* [unikernel.ml] *)
module Main (C: Conduit_mirage.S): struct
  let start conduit =
    C.listen conduit (`TLS (tls_config, `TCP 443)) callback
end
    ```

* [types] Remove `V1.ENTROPY` and `V1_LWT.ENTROPY`. The entropy is now
  handled directly by `nocrypto.0.4.0` and the mirage-tool is only responsible to
  call the `Nocrypto_entropy_{mode}.initialize` function.

* Remove `Mirage.vchan`, `Mirage.vchan_localhost`, `Mirage.vchan_xen` and
  `Mirage.vchan_default`. Vchan users need to adapt their code to directly
  use the `Vchan` functors instead of relying on the combinators.
* Remove `Mirage.conduit_client` and `Mirage.conduit_server` types.
* Fix misleading "Compiling for target" messages in `mirage build`
  (#408 by @lnmx)
* Add `--no-depext` to disable the automatic installation of opam depexts (#402)
* Support `@name/file` findlib's extended name syntax in `xen_linkopts` fields.
  `@name` is expanded to `%{lib}%/name`
* Modernize the Travis CI scripts


### mirage-http-v2.4.0: Support cohttp 0.18

Released on 2015-06-10 as [v2.4.0](https://github.com/mirage/mirage-http/releases/tag/v2.4.0). See <https://github.com/mirage/mirage-http> for full history.

* Support cohttp 0.18 (#13, by @rgrinberg)


### mirage-tcpip-v2.5.0: Strip trailing bits from packets, fix windows parameters for out-of-order packets, add a Log module

Released on 2015-06-10 as [v2.5.0](https://github.com/mirage/mirage-tcpip/releases/tag/v2.5.0). See <https://github.com/mirage/mirage-tcpip> for full history.

* The test runs now produce `.pcap` files (#141, by @MagnusS)
* Strip trailing bytes from network packets (#145, by @talex5)
* Add tests for uniform packet loss (#147, by @MagnusS)
* fixed bug where in case of out of order packets the ack and window were set
  incorrectly (#140, #146)
* Properly handle RST packets (#107, #148)
* Add a `Log` module to control at runtime the debug statements which are
  displayed (#142)
* Writing in a PCB which does not have the right state now returns an error
  instead of blocking (#150)

### alcotest-0.3.2: Add a logo, a simple example, and try to not fail if the output file does not exist

Released on 2015-06-08 as [0.3.2](https://github.com/mirage/alcotest/releases/tag/0.3.2). See <https://github.com/mirage/alcotest> for full history.

* Do not fail if the output file does not exist
* Add a simple example (#10, by @leowzukw)
* Add a logo (#12, by @leowzukw)

### ocaml-conduit-v0.8.4: Support ocaml-tls in mirage, rework the mirage API

Released on 2015-06-08 as [v0.8.4](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.4). See <https://github.com/mirage/ocaml-conduit> for full history.

* Full support for `ocaml-tls.0.5.0`
* Breaking API change for mirage-conduit. Now all the flows are dynamic,
  the functors are becoming first-class values so no big functor to build
  first.

### mirage-profile-v0.5: mirage-profile 0.5

Released on 2015-06-08 as [v0.5](https://github.com/mirage/mirage-profile/releases/tag/v0.5). See <https://github.com/mirage/mirage-profile> for full history.

Note: the traces produced by this release can only be read using mirage-trace-viewer version 0.2 or later. Getting all of the new events requires my Lwt `tracing-async` branch, which I will merge soon after this release.

Changes since 0.4:

- Report absolute counter values. This allows the reader to see the correct value even if they don't have the start of the trace.

- Add new callback thread types (`on_success`, `on_terminate`, etc). Requires new Lwt.

- Add `Trace.should_resolve`. Application code can call this to hint that a particular thread is expected to resolve (return or fail). The viewer will check that the thread resolved and highlight it if not (without this, unresolved threads are difficult to see).

- Record `note_try_read` event (requires new Lwt). This indicates that one thread is waiting for another one. The trace viewer will render this as a yellow arrow if the thread never resolved.

- Allow getting and setting the absolute value of a counter. Before, you could only record a delta. Note: calling `Counter.increase` now calculates the new value and records that, so you don't need to update existing code.

- Don't abort on unknown thread types. Makes it easier to add new types to Lwt.

- Link to Mirage tracing documentation.

- Updated Lwt repository link in README. Reported by Mindy Preston.

### mirage-trace-viewer-0.2: mirage-trace-viewer 0.2

Released on 2015-06-08 as [0.2](https://github.com/talex5/mirage-trace-viewer/releases/tag/0.2). See <https://github.com/talex5/mirage-trace-viewer> for full history.

- If a thread attempts to read from another one, but it never completes, show a yellow arrow at the attempt so it's clear why it didn't complete (requires new mirage-profile and lwt).

- If a thread is marked as "should_resolve" (requires new mirage-profile) then mark it as failed if it never resolved and set its end time to the end of the trace to make it more visible.

- Double-click a thread to highlight it. This makes it easier to keep track of it when moving around. It also highlights any thread which this one merges into, and any threads which merge into this one, recursively.

- The metric lines are now more visible, with a black outline.

- The GTK viewer has a right-click pop-up menu and the HTML viewer has a corresponding side panel that can be opened by clicking the new hamburger icon in the bottom left.

- Display of metric lines can be toggled, either all at once by pressing Space or individually via the menu/panel.

- You can restrict the default metrics shown when using the HTML viewer API.

- You can search for threads with a label matching some string (keyboard short-cut: '/').

- Some metrics now share their scales. e.g. tcp-to-ip and tcp-ackd-segs share a single scale. By default, the scale name is the metric name with any trailing '#...' part removed. So, 'tx_window#445' and 'tx_window#446' (the transmit window for two separate TCP connections) will share the same scale.

- Trace files can now report absolute counter values, not just deltas (requires new mirage-profile). Scales now always go down to zero.

- There are some new callback thread types (on_success, on_failure, etc; requires new mirage-profile and lwt). Previously, events from such callbacks were shown against the thread that registered the callback. This could cause redraw glitches if that thread ended before the callback events occured.

- Don't abort on unknown thread types (allows upgrading the format more easily).

- Draw failed threads in red.

- Fix positioning of metric lines.

- Updated opam file to use new configure option name. Reported by Luke Dunstan. Closes #3.

- Adapt to latest io-page (Thomas Gazagnaire).

- Install the xen pluggin (Thomas Gazagnaire).


### mirage-net-unix-v2.2.2: Workaround Linux 3.19 bug by forcing non-blocking tuntap

Released on 2015-06-08 as [v2.2.2](https://github.com/mirage/mirage-net-unix/releases/tag/v2.2.2). See <https://github.com/mirage/mirage-net-unix> for full history.

Force non-blocking mode in the tun file descriptor to workaround a Linux 3.19+ kernel bug (see mirage/ocaml-tuntap#15). Requires tuntap 1.3.0+ for the corresponding fix.


### ocaml-tuntap-v1.3.0: Avoid need for root, support persistent and IPv6 interfaces, and Linux 3.19+

Released on 2015-06-07 as [v1.3.0](https://github.com/mirage/ocaml-tuntap/releases/tag/v1.3.0). See <https://github.com/mirage/ocaml-tuntap> for full history.

* Do not leak a file descriptor per tun interface (#12 via Justin Cormack)
* Avoid the need for root access for persistent interfaces by not calling
  `SIOCSIFFLAGS` if not needed (#13 via Justin Cormack).
* Use centralised Travis scripts.
* Work around OS X bug in getifaddrs concerning lo0@ipv6 (#14)
* Force a default of non-blocking for the Linux tuntap file descriptor.
  This works around a kernel bug in 3.19+ that results in 0-byte reads
  causing processes to spin (https://bugzilla.kernel.org/show_bug.cgi?id=96381).
  Workaround is to open the device in nonblock mode, via Justin Cormack.
* `set_ipaddr` renamed to `set_ipv4` since it can only set IPv4 addresses.
* Improved `getifaddrs` interface to an association list iface -> addr.
* Dropped OCaml < 4.01.x support.
* Added convenience functions `gettifaddrs_v{4,6}`, `v{4,6}_of_ifname`.
* Do not change the `persist` setting if unspecified when
  opening a new tun interface (#9 from Luke Dunstan).

### ocaml-cohttp-v0.18.1: HTTP header parsing bug fixes

Released on 2015-06-05 as [v0.18.1](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.18.1). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Remove trailing whitespace from headers (#372)
* Don't reverse order of list valued headers (#372)


### ocaml-mbr-v0.3: Support new Mirage 2.3+

Released on 2015-06-04 as [v0.3](https://github.com/mirage/ocaml-mbr/releases/tag/v0.3). See <https://github.com/mirage/ocaml-mbr> for full history.

- Expose a connect function for mirage-types > 2.3
- Fix bounds checks
- Add unit tests
- Fix integer overflow
- Add opam file

### ocaml-cohttp-v0.18.0: Top level printers, Async callv, bug fixes

Released on 2015-06-02 as [v0.18.0](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.18.0). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Add Cohttp_async.Client.callv. Allows for making requests while reusing an
  HTTP connection (#344) 
* Responses of status 1xx/204/304 have no bodies and cohttp should not attempt
  to read them (#355)
* Add top level printers. See cohttp.top findlib package (#363)
* Add `Header.to_string` (#362)
* Fix chunk truncation in chunked transfer encoding (#360)

Compatibility breaking interface changes:
* Remove `Request`/`Response` modules outside of Cohttp pack (#349)


### mirage-http-v2.3.0: Simplify the `Client` signature, works with conduit 0.8.4

Released on 2015-06-02 as [v2.3.0](https://github.com/mirage/mirage-http/releases/tag/v2.3.0). See <https://github.com/mirage/mirage-http> for full history.

* Simplify the `Client` signature to be a simple module. It is not
  a functor depending on `Conduit` anymore and the context is now
  more explicit.
* Expose type equalities for `IO.conn` in the `Server` functor
* Adapt to conduit 0.8.4


### mirage-seal-0.2.0: Add content-types headers, support latest conduit

Released on 2015-06-02 as [0.2.0](https://github.com/mirage/mirage-seal/releases/tag/0.2.0). See <https://github.com/mirage/mirage-seal> for full history.

* Add content-type header to responses from sealed kernel (#7 by @mattgray)
* Support conduit 0.8.4

### ocaml-github-v1.0.0: Stable LTS API

Released on 2015-06-01 as [v1.0.0](https://github.com/mirage/ocaml-github/releases/tag/v1.0.0). See <https://github.com/mirage/ocaml-github> for full history.

1.0.0 included many breaking changes and major new features. For a full list of changes, see the file CHANGES in the repository or distribution.

`atdgen >=1.5.0` and `yojson >=1.2.0` are now required for their `tag_field` support. `cohttp >=0.17.0` is now required for its `Link` header support.

Many functions now return an `'a Response.t Monad.t` instead of an `'a Monad.t`. This is a future-proofing mechanism to enable progressive disclosure of API call metadata such as headers, redirects, endpoint polling, and so on.

Many functions now return a `'a Stream.t` which lazily encapsulates a series of API requests when collections may be too large to fit into a single response (#46).

Two-factor authentication is now supported.

`Monad.map`, `Monad.(>|=)`, and `Monad.embed : 'a Lwt.t -> 'a Monad.t` were added. `Monad.(>>~)` was added to bind and project an `'a Response.t Monad.t` value.

`git-jar save` was removed after the Authorizations API response changes of 2015-04-20. `git-jar make` now requires a cookie name and defaults to that for the token note. `git-jar revoke` now accepts either a cookie name or a token ID. A `git-jar` token file permissions security vulnerability was fixed.

A `Github.Message` exception was added and is now raised when GitHub returns an API error. `API.string_of_message` was added for human consumption of those structured errors.

A number of rate limit query (`Rate_limit`) and caching (`API.get_rate*`) features were added.

The `Search` module was added in order to access GitHub's repository search API. The `git-search` jar command was added to expose this to users.

The `Event` module was added which gives users easy access to a variety of event sources. A new jar command, `git-list-events`, has been added to print events for a repo. A new test binary, `parse_events`, has been added which downloads and attempts to parse archived event data.

Several bugs with issue listing (#49, #53) were fixed and a new jar command, `git-list-issues`, was introduced.

A command line tool for gist manipulation was added.


### mirage-block-unix-v2.0.0: NetBSD and preliminary rumprun support

Released on 2015-05-27 as [v2.0.0](https://github.com/mirage/mirage-block-unix/releases/tag/v2.0.0). See <https://github.com/mirage/mirage-block-unix> for full history.

* Incompatible API change: Block.blkgetsize takes an extra argument (a file descriptor)
* Support NetBSD through DIOCGMEDIASIZE
* Support rumprun by avoiding re-opening files, instead we use file descriptors internally

### ocaml-cohttp-v0.17.2: Much better handling of large fixed size bodies

Released on 2015-05-24 as [v0.17.2](https://github.com/mirage/ocaml-cohttp/releases/tag/v0.17.2). See <https://github.com/mirage/ocaml-cohttp> for full history.

* Remove dependency on the Lwt Camlp4 syntax extension (#334).

* Add `make github` target to push documentation to GitHub Pages
  (#338 from Jyotsna Prakash).

* [async] Add `Cohttp_async.Server.close` to shutdown server (#337).

* Add Async integration tests and consolidate Lwt tests using the
  new framework (#337).

* Fix allocation of massive buffer when handling fixed size http bodies (#345)

### mirage-platform-v2.3.2: Support cstruct 1.6.0

Released on 2015-05-21 as [v2.3.2](https://github.com/mirage/mirage-platform/releases/tag/v2.3.2). See <https://github.com/mirage/mirage-platform> for full history.

* [xen] Synchronize Cstruct C stubs with version 1.6.0.


### ocaml-uri-v1.9.0: Verbatim query strings, URN support, colon-handling, Uri_services updates

Released on 2015-05-15 as [v1.9.0](https://github.com/mirage/ocaml-uri/releases/tag/v1.9.0). See <https://github.com/mirage/ocaml-uri> for full history.

1.9.0 (2015-05-15):
* Colon (":") is no longer percent-encoded in path segments
* URNs are now supported (#67)
* Relative paths with colons in first segment have "./" prepended in to_string
* Add Uri.empty, the zero length URI reference
* Uri_services now includes service aliases (e.g. www, www-http, http)
* Uri_services now includes chargen and git
* Add `Uri.canonicalize` for scheme-specific normalization (#70)
* Add `Uri.verbatim_query` to extract literal query string (#57)
* Add `Uri.equal`
* Add `Uri.user` and `Uri.password` accessors for subcomponents of userinfo (#62)
* Add `Uri.with_password` functional setter for password subcomponent of userinfo
* Fix file scheme host normalization bug which introduced empty host (#59)

### ocaml-dns-v0.15.0: Name module improvements

Released on 2015-05-14 as [v0.15.0](https://github.com/mirage/ocaml-dns/releases/tag/v0.15.0). See <https://github.com/mirage/ocaml-dns> for full history.

0.15.0 (2015-05-14):
* Name.domain_name has been renamed to Name.t and is now abstract
* Name.domain_name_to_string has been renamed to Name.to_string
* Name.string_to_domain_name has been deprecated for Name.of_string
* Name.parse_name has been renamed to Name.parse
* Name.marshal_name has been renamed to Name.marshal
* Name.hashcons_charstring has been renamed to Name.hashcons_string
* Name.hashcons_domainname has been renamed to Name.hashcons
* Name.canon2key has been renamed to Name.to_key
* Name.for_reverse has been replaced by Name.of_ipaddr
* Name.of_ipaddr accepts a Ipaddr.t and produces a name suitable for reverse DNS
* We now require >= ipaddr.2.6.0 to support Name.of_ipaddr
* uri 1.7.0+ is now required for its uri.services service registry
* Named service lookups are now supported in zone files
* Dig string serializations are now in Dns.Dig (#61 from Heidi Howard)

### mirage-seal-0.1.0: Initial release

Released on 2015-05-05 as [0.1.0](https://github.com/mirage/mirage-seal/releases/tag/0.1.0). See <https://github.com/mirage/mirage-seal> for full history.

### mirage-tcpip-v2.4.3: Fix an infinite loop in `Channel.read_line`

Released on 2015-05-05 as [v2.4.3](https://github.com/mirage/mirage-tcpip/releases/tag/v2.4.3). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fix infinite loop in `Channel.read_line` when the line does not contain a CRLF
  sequence (#131)


### ocaml-conduit-v0.8.3: Set TCP_NODELAY on unix domain sockets

Released on 2015-05-04 as [v0.8.3](https://github.com/mirage/ocaml-conduit/releases/tag/v0.8.3). See <https://github.com/mirage/ocaml-conduit> for full history.

* Partial support for `ocaml-tls.0.5.0`
* setsockopt TCP_NODELAY fails on a Unix domain socket (#63 by @djs55)

### ocaml-x509-0.3.1: partial PKCS8 support

Released on 2015-05-02 as [0.3.1](https://github.com/mirleft/ocaml-x509/releases/tag/0.3.1). See <https://github.com/mirleft/ocaml-x509> for full history.

* unencrypted PKCS8 private key support #49

### ocaml-tls-0.5.0: temporarily stable

Released on 2015-05-02 as [0.5.0](https://github.com/mirleft/ocaml-tls/releases/tag/0.5.0). See <https://github.com/mirleft/ocaml-tls> for full history.

* updates to extension enum (contributed by Dave Garrett #264)
* removed entropy feeding (done by nocrypto) #265
* Tls_lwt file descriptor lifecycle: not eagerly close file descriptors #266

### ocaml-nocrypto-0.4.0: The Effervescing Elephant

Released on 2015-05-02 as [0.4.0](https://github.com/mirleft/ocaml-nocrypto/releases/tag/0.4.0). See <https://github.com/mirleft/ocaml-nocrypto> for full history.

* module for injecting entropy into RNG on Unix/Lwt (optional)
* module for injecting entropy into RNG on Mirage/Xen (optional; depends on mirage-entropy-xen)
* API changes in Rng
* do not 0-pad DH public and shared representations
* more named DH groups

If you edit `src/dh.ml`, you just might find @hannesm is hiding in there!

### mirage-entropy-0.3.0: Internally unstable

Released on 2015-05-02 as [0.3.0](https://github.com/mirage/mirage-entropy/releases/tag/0.3.0). See <https://github.com/mirage/mirage-entropy> for full history.

* Remove `mirage-entropy-unix` from the repository; it now only contains `mirage-entropy-xen`.
* Add internal entropy harvesting via timing and CPU RNG if available.
* Temporarily disable `xentropyd`.
* The API is no longer `V1.ENTROPY` compatible.

Thanks to @talex5!

### ocaml-asn1-combinators-0.1.2: 

Released on 2015-05-02 as [0.1.2](https://github.com/mirleft/ocaml-asn1-combinators/releases/tag/0.1.2). See <https://github.com/mirleft/ocaml-asn1-combinators> for full history.

A minor release. `cstruct-1.6.0` compatible.

### mirage-block-volume-v0.11.0: Reliability and debugability

Released on 2015-04-30 as [v0.11.0](https://github.com/mirage/mirage-block-volume/releases/tag/v0.11.0). See <https://github.com/mirage/mirage-block-volume> for full history.

* Erase the redo log when it is created
* Update to shared-block-ring.2.0.0
* Avoid using bisect by default

### mirage-vnetif-0.1: v0.1

Released on 2015-04-30 as [0.1](https://github.com/MagnusS/mirage-vnetif/releases/tag/0.1). See <https://github.com/MagnusS/mirage-vnetif> for full history.

First release

### mirage-tcpip-v2.4.2: Fix a memory leak in `Channel` and add `Alcotest` framework

Released on 2015-04-29 as [v2.4.2](https://github.com/mirage/mirage-tcpip/releases/tag/v2.4.2). See <https://github.com/mirage/mirage-tcpip> for full history.

* Fix a memory leak in `Channel` (#119, by @yomimono)
* Add basic unit-test for channels (#119, by @yomimono)
* Add alcotest testing templates
* Modernize Travis CI scripts


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

### alcotest-0.3.1: Fix OCaml 4.01 regression support and and Travis tests

Released on 2015-04-14 as [0.3.1](https://github.com/mirage/alcotest/releases/tag/0.3.1). See <https://github.com/mirage/alcotest> for full history.

* Fix OCaml 4.01.0 and earlier support (regressed in 0.3.0).
* Add Travis CI tests.


### alcotest-0.3.0: Fix backtrace and use Bytes instead of String

Released on 2015-04-13 as [0.3.0](https://github.com/mirage/alcotest/releases/tag/0.3.0). See <https://github.com/mirage/alcotest> for full history.

* Fix backtrace handling (#2 by @dsheets)
* Use `Bytes` module instead of `String`


### mirage-block-volume-v0.9.0: First release

Released on 2015-04-10 as [v0.9.0](https://github.com/mirage/mirage-block-volume/releases/tag/v0.9.0). See <https://github.com/mirage/mirage-block-volume> for full history.

The first release of mirage-block-volume

### jitsu-0.1: v0.1

Released on 2015-04-10 as [0.1](https://github.com/mirage/jitsu/releases/tag/0.1). See <https://github.com/mirage/jitsu> for full history.

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

### mirage-nat-0.2.4: 

Released on 2015-04-02 as [0.2.4](https://github.com/yomimono/mirage-nat/releases/tag/0.2.4). See <https://github.com/yomimono/mirage-nat> for full history.

### mirage-nat-0.2.2: 0.2.2

Released on 2015-04-02 as [0.2.2](https://github.com/yomimono/mirage-nat/releases/tag/0.2.2). See <https://github.com/yomimono/mirage-nat> for full history.

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


### ocaml-git-1.4.11: Fix the smart HTTP protocol

Released on 2015-03-11 as [1.4.11](https://github.com/mirage/ocaml-git/releases/tag/1.4.11). See <https://github.com/mirage/ocaml-git> for full history.

* Fix multi round-trips in the smart HTTP protocol. This fixes
  depth-limited clones (#71) and fetches.
* Create the `git.http` library for abstracting away bits of the
  smart HTTP protocol.
* Add `User-Agent` in the headers of the smart HTTP protocol. This
  makes `bitbucket.org` happy. (#66, patch from @vklquevs)


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
* New `Html.img` constructor for easy creation of `<img>` tags
* New `Html.a` constructor for easy creation of `<a>` tags
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


