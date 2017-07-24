## Package hardening

The MirageOS ecosystem of libraries is booming:

```
$ opam list -a | grep mirage | wc -l
      90
```

We now have various libraries covering all aspect of the OS: from network to
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
the "MirageOS hardening process". Ideally this will live in a tool (e.g.
`mirage lint`) but to start we list the criteria that such an hardened
package should follow.

### Project Paperwork

- Have well-identified maintainers. GitHub recently
  [introduced code owners](https://github.com/blog/2392-introducing-code-owners),
  which may be worth to use for some (of our core) libraries.

- Have a design document specifying the scope of the library (and esp. what is
  out of scope)

- Use the correct set of tags in opam metadata

- Use proper names: same name for opam and ocamlfind package, and also ideally
  for the top-level module (see next point).

- Use module alias instead of packs to define proper namespaces
  (to avoid name-clashes)

- Have documentation

- Have a clear LICENSE file

- Use [topkg](https://github.com/dbuenzli/topkg) to release, in order to ease
  the task of the release manager(s).

- Have proper indentation (using ocp-indent + checked-in ocp-indent file)

- Use at most 80 columns (`ocp-indent` unfortunately doesn't check this)

- Follow [OCaml programming guidelines](https://ocaml.org/learn/tutorials/guidelines.html)

- Ideally, use [Jbuilder](https://github.com/janestreet/jbuilder) to build,
  in order to have short feedback loops when fixing bugs spanning multiple
  packages.

### Code Good Practice

- Provide pretty printers by using [fmt](http://erratique.ch/software/fmt/doc/Fmt.html)

- Do not expose any exceptions in the public interface, but use the
  [result](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html#TYPEresult)
  type and [rresult](http://erratique.ch/software/rresult/doc/Rresult.html)
  combinators!

- Use [logs](http://erratique.ch/software/logs/doc/Logs.html) for logging

- Use [astring](http://erratique.ch/software/astring/doc/Astring.html) for
  string processing

- Use [bos](http://erratique.ch/software/bos/doc/Bos.html) for operating system
  interaction

- Use [fpath](http://erratique.ch/software/fpath/doc/Fpath.html) for file paths

- Avoid integer overflows (basically every addition and subtraction, as well
  as multiplication needs to be guarded unless you know that an overflow can
  never happen (in this case, a comment should be suggested))

- Work on 32bit (esp. in regards to the last point)

- Avoid global mutable state

- Be aware of non-tail recursive functions

- Be aware of polymorphic equality drawbacks -- when possible define your own
  specialized functions.

### Project Confidence

- All direct dependencies are specified in the opam file (e.g. sometimes some
  direct dependencies are included by transitivity -- this is not very stable
  and could break the package in the future if one of a transitive dependency
  is updated)

- Use `-safe-string` (looks like this will be the default in 4.06)

- Have unit tests (using alcotest) (ideally with coverage report)

- Have fuzz tests (using crowbar)

- Depends only on libraries released in opam

- Is released in opam

- For distributed binaries: have a way to reproduce the exact set of packages
  needed to build the released version of the binary, for instance by vendoring
  opam metadata.

- have a clear indication if the library is used in production (and if yes by
  which project)

- bonus: has been formally verified
