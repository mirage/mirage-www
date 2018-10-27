## Package Quality

NOTE: this is WIP
TODO: where to get the badges, where to put them? an opam tag and README.md link?

The MirageOS ecosystem of libraries is booming:

```
$ opam list -a | grep mirage | wc -l
      95
```

We now have various libraries covering all aspects of the OS: from network to
block device drivers -- at all aspects of the stack: from virtual network cards
to TLS or virtual block devices to virtual filesystems. These libraries also
span multiple hypervisors including Xen and (via solo5) KVM.

All of this is great: this means that as a MirageOS user, you can spend time
developing your own application instead of spending time re-implementing
something that the OS would usually do for you. There are of course still
gaps in the ecosystem, but things are getting better!

A MirageOS unikernel contains an unmodified OCaml runtime, but the `Unix` module
is intentionally! not implemented on MirageOS, neither is the `Str` or `Threads`
module. Any OCaml library depending directly or indirectly on these is not
usable with MirageOS.

Only a very small set of C functions are implemented in the MirageOS lower
layers (such as
[ocaml-freestanding](https://github.com/mirage/ocaml-freestanding)). If an
OCaml library uses external libraries written in C via OCaml's C foreign
function interface, this library will likely not work on MirageOS since the
C functions are missing. It is possible to use C functions on MirageOS, but
the build system of such a library needs to "cross-compile" the C functions for
the different virtualization technologies.
Examples include
[mirage-entropy](https://github.com/mirage/mirage-entropy),
[checkseum](https://github.com/mirage/checkseum),
[digestif](https://github.com/mirage/digestif),
[bigstringaf](https://github.com/inhabitedtype/bigstringaf)
and [nocrypto](https://github.com/mirleft/ocaml-nocrypto) (which
uses [gmp](https://gmplib.org) via [zarith](https://github.com/ocaml/zarith) and
the gmp-freestanding and gmp-xen package in opam-repository),

A problem is how to know the level of confidence to attribute to a MirageOS
library. Would be great to be able to answer questions such as:
Does this library work with MirageOS?
Does the library has a good test coverage? Was it formally verified?
Was it used in production? In order to do this, we are introducing
the "MirageOS quality tags". Ideally this will live in a tool (e.g.
`mirage lint`) but to start we list the criteria that package aiming
for increased quality should follow.

### ![ready:](https://img.shields.io/badge/mirageos-ready-orange.svg) usable with MirageOS

The OCaml library is packaged with [opam](https://opam.ocaml.org), and released
to the [opam repository](https://github.com/ocaml/opam-repository).

In addition, the library follows our [packaging guidelines](https://mirage.io/wiki/packaging).

Checks to be in this level:
- The commands `opam lint` and `dune-release lint` or `topkg lint` return no
  error.
- The metadata files `CHANGES.md`, `LICENSE.md` and `README.md` exist
- The use of [dune](http://dune.readthedocs.io/en/latest/) is
  strongly encouraged but not yet mandatory.
- Immutable strings, since 4.06.0 default (`-safe-string`).
- The not available modules `Unix`, `Str` and `Threads` are not referenced.
- Either there are no C dependencies or the build system cross-compiles to
  MirageOS targets.
- If a side-effecting computation, such as network access, random, etc. is
  required, an implementation using the [mirage-types](https://github.com/mirage/mirage-types)
  interfaces is provided in a sublibrary (e.g. [tls-mirage](https://github.com/mirleft/ocaml-tls/tree/master/mirage).

## ![integrated:](https://img.shields.io/badge/mirageos-tested-yellow.svg) follows our best practises

MirageOS follows software development best practises. The library has to
follow the [OCaml programming guidelines](https://ocaml.org/learn/tutorials/guidelines.html).

For some functionality in MirageOS we agreed on OCaml libraries:
- A MirageOS unikernel should have a unified logging configuration of log level
  and subsystems. We use the [logs](http://erratique.ch/software/logs/doc/Logs.html)
  library for logging, which nicely separates the log source from the log reporter.
  The [mirage-logs](https://github.com/mirage/mirage-logs) contains command-line
  logging source and level support, a
  [syslog reporter](https://github.com/hannesm/logs-syslog) is integrated.
- If a library reports metrics, e.g. it uses a cache or wants to measure
  durations between request and response. The
  [metrics](https://github.com/mirage/metrics) is used.

Recommended OCaml libraries:
- Use [lwt](http://ocsigen.org/lwt/) for asynchronous tasks.
- Use [ipaddr](https://github.com/mirage/ocaml-ipaddr) for Internet Protocol
  addresses.
- Use [astring](http://erratique.ch/software/astring/doc/Astring.html) for
  string processing.
- Provide pretty printers by using
  [fmt](http://erratique.ch/software/fmt/doc/Fmt.html).
- Have unit tests (using [alcotest](https://github.com/mirage/alcotest)),
  ideally with automatedcoverage report output.
- [Ptime](http://erratique.ch/software/ptime/doc/Ptime.html) for POSIX time
  computations.
- [Duration](https://github.com/hannesm/duration) converts time units
  (milliseconds, seconds, ..)
- [Randomconv](https://github.com/hannesm/randomconv) converting bytes to
  number ranges.

Code best pracises:
- Avoid polymorphic equality and comparison -- when possible define your own
  specialized functions.
- Avoid global mutable state.
- Use tail recursion.
- Do not expose any exceptions in the public interface, but use the
  [result](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html#TYPEresult)
  type and [rresult](http://erratique.ch/software/rresult/doc/Rresult.html)
  combinators.

Style best practises
- Have proper indentation (using ocp-indent + checked-in ocp-indent file).
- Use at most 80 columns (`ocp-indent` unfortunately doesn't check this).

The scope of the library is well-defined and documented. The API is documented,
especially regarding failure semantics. It is accessible online (e.g.
[docs.mirage.io](https://docs.mirage.io)) and can be generated using
[odig](http://erratique.ch/software/odig).

## ![automated:](https://img.shields.io/badge/mirageos-automated-yellow-green.svg) automated with continuous integration

The library uses continuous integration systems to catch issues early:
- The [ocaml-ci-scripts](https://github.com/ocaml/ocaml-ci-scripts) contain
  Travis and AppVeyor integration.

## ![approved:](https://img.shields.io/badge/mirageos-approved-green.svg) approved MirageOS library

- Has well-identified maintainers. GitHub recently
  [introduced code owners](https://github.com/blog/2392-introducing-code-owners),
  which may be worth to use for some (of our core) libraries.

- Avoid the use of C bindings for no good reasons. A good reason would be to
  improve performance by an order of magnitude, or re-use an existing C library
  that has not been rewritten yet.

- Has randomized property-based testing. Using QuickCheck-like libraries or
  fuzz testing (e.g. [crowbar](https://github.com/stedolan/crowbar/), automated
  fuzz testing with [bun](https://github.com/yomimono/ocaml-bun) and
  [ppx_deriving_crowbar](https://github.com/yomimono/ppx_deriving_crowbar/)).

- Avoid integer overflows: basically every addition and subtraction, as well
  as multiplication needs to be guarded unless you know that an overflow can
  never happen (in this case, a comment should be suggested).

- Work on 32bit (esp. in regards to the last point), tested by CI.

- Is reproducible by having a way to reproduce the exact binary result. See
  [reproducible builds](https://reproducible-builds.org/) for further information.
  OCaml produces reproducible binaries. A reproducible MirageOS unikernel needs
  to record the exact version of its opam package dependencies, and each opam
  package needs to be reproducible.

- Have a clear indication if the library is used in production (and if yes by
  which project).

TODO: 'received external security audit'
TODO: 'YYY' for libraries we use on our infrastructure since TTT and know their behaviour
TODO: end-to-end testing

## ![verified:](https://img.shields.io/badge/mirageos-verified-purple.svg) Formally verified

- Has been formally verified with a proof assistant.
