## Package Quality

The MirageOS ecosystem of libraries is booming:

```
$ opam list -a | grep mirage | wc -l
      90
```

We now have various libraries covering all aspects of the OS: from network to
block device drivers -- at all aspects of the stack: from virtual network cards
to TLS or virtual block devices to virtual filesystems. These libraries also
span multiple hypervisors including Xen and (via solo5) KVM.

All of this is great: this means that as a MirageOS user, you can spend time
developing your own application instead of spending time re-implementing
something that the OS would usually do for you. There are of course still
gaps in the ecosystem, but things are getting better!

The next problem is knowing the level of confidence to attribute to each of
these libraries. Would be great to be able to answer questions such as:
Does the library has a good test coverage? Was it formally verified?
Was it used in production? In order to do this, I would like to introduce
the "MirageOS quality levels". Ideally this will live in a tool (e.g.
`mirage lint`) but to start we list the criteria that package aiming
for increased quality should follow.

### ![Level 1:](https://img.shields.io/badge/level-1-blue.svg) Follow Packaging Guidelines

See the [packaging guidelines](https://mirage.io/wiki/packaging) for more
details. In summary:

- The package should work well with [odig](http://erratique.ch/software/odig)
  e.g. `CHANGES.md`, `LICENSE.md` and `README.md` should exist.

- The package should work well with [topkg](http://erratique.ch/software/topkg),
  e.g. `pkg/pkg.ml` should exist.

- The use of [jbuilder](http://jbuilder.readthedocs.io/en/latest/) is
  strongly encouraged but not yet mandatory as 1.0.0 has not been
  officially released. However, we plan to enforce its use as soon as
  it is the case -- assuming that it has all the features needed for
  building MirageOS applications.

- Use proper names: same name for opam and ocamlfind package, and also ideally
  for the top-level module.

- All direct dependencies are specified in the opam file (e.g. sometimes some
  direct dependencies are included by transitivity -- this is not very stable
  and could break the package in the future if one of a transitive dependency
  is updated) (NOTE: should probably be added in the packaging guideline)

### ![Level 2](https://img.shields.io/badge/level-2-blue.svg) Define Package Scope

- Have well-identified maintainers. GitHub recently
  [introduced code owners](https://github.com/blog/2392-introducing-code-owners),
  which may be worth to use for some (of our core) libraries.

- Have a design document specifying the scope of the library (and esp. what is
  out of scope)

- Use the correct set of tags in opam metadata

- Have documentation

### ![Level 3:](https://img.shields.io/badge/level-3-blue.svg) Use Good Coding Style

- Have proper indentation (using ocp-indent + checked-in ocp-indent file).

- Use at most 80 columns (`ocp-indent` unfortunately doesn't check this).

- Follow [OCaml programming guidelines](https://ocaml.org/learn/tutorials/guidelines.html).

### ![Level 4:](https://img.shields.io/badge/level-4-blue.svg) Keep your Style Functional

- Avoid global mutable state.

- Use tail recursion.

- Use `-safe-string` (looks like this will be the default in 4.06).

- Avoid polymorphic equality and comparison -- when possible define your own
  specialized functions.

### ![Level 5:](https://img.shields.io/badge/level-4-blue.svg) Test

- Have unit tests (using alcotest) (ideally with coverage report).

### ![Level 6:](https://img.shields.io/badge/level-6-blue.svg) Keep Sane Dependencies

- Depends only on libraries released in opam.

- Provide pretty printers by using [fmt](http://erratique.ch/software/fmt/doc/Fmt.html).

- Do not expose any exceptions in the public interface, but use the
  [result](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html#TYPEresult)
  type and [rresult](http://erratique.ch/software/rresult/doc/Rresult.html)
  combinators.

- Use [logs](http://erratique.ch/software/logs/doc/Logs.html) for logging.

- Use [astring](http://erratique.ch/software/astring/doc/Astring.html) for
  string processing.

- Use [bos](http://erratique.ch/software/bos/doc/Bos.html) for operating system
  interaction.

- Use [fpath](http://erratique.ch/software/fpath/doc/Fpath.html) for file paths.

- Avoid the use of C bindings for no good reasons. A good reason would be to
  improve performance by an order of magnitude, or re-use an existing C library
  that has not been rewritten yet.

### ![Level 7:](https://img.shields.io/badge/level-7-blue.svg) Randomized Test

- Have randomized property-based testing. Using QuickCheck-like libraries or
  even better using fuzz testing (and crowbar) when the tooling will be ready.

### ![Level 8:](https://img.shields.io/badge/level-8-blue.svg) Count with Care

- Avoid integer overflows (basically every addition and subtraction, as well
  as multiplication needs to be guarded unless you know that an overflow can
  never happen (in this case, a comment should be suggested))

- Work on 32bit (esp. in regards to the last point)

### ![Level 9:](https://img.shields.io/badge/level-9-blue.svg) Used in Production

- Have a clear indication if the library is used in production (and if yes by
  which project).

- For distributed binaries: have a way to reproduce the exact set of packages
  needed to build the released version of the binary, for instance by vendoring
  opam metadata.

### ![Level 10:](https://img.shields.io/badge/level-10-blue.svg) Verify Formally

- Has been formally verified.
