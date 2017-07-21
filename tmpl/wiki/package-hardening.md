## Package hardening

The MirageOS ecosystem of libraries is booming:

```
$ opam list -a | grep mirage | wc -l
      90
```

We now have various libraries covering all aspect of the OS: from network to
block device drivers -- at all levels of the stack: from virtual network cards
to TLS or virtual block devices to virtual filesystem. These libraries also
span multiple hypervisors such Xen as well as KVM (via solo5).

All of this is great: this means that as a MirageOS user, you can spend time
developping your own application instead of spending time re-implementing
something that the OS would usually do for you. There are of course still
gaps in the ecosystem, but this is getting better that it used to be.

The next problem is knowing the level of confidence to attribute to each of
these libraries. Would be great to be able to answer questions such as:
Does the library has a good test coverage? Was it formally verifired?
Was it used in production? In order to do this, I would like to introduce
the "MirageOS hardining process". Ideally this will live in a tool (e.g.
`mirage lint`) but to start we list the criteria that such an hardened
package should follow.

### Project Linting

- have well-identified maintainers
- use the correct set of tags in opam metadata
- use proper names: same name for ocaml and ocamlfind package, and also ideally
  for the top-level module (see next point).
- use module alias and proper namespaces (to avoid name-clashes)
- have documentation
- have a clear LICENSE file
- use Jbuilder to build, in order to have short feedback loops when fixing bugs
  spawning multiple packages
- use topkg to release, in order to ease the task of the release manager
- have proper indentation (usgin ocp-indent + checked-in ocp-indent file)
- use at most 80 collumns
- for binaries and packages: have a way to gather the licenses of all the
  dependencies (so for example advertising clauses can be respected)

### Project Confidence

- have unit tests (using alcotest) (ideally with coverage report)
- have fuzz tests (using crowbar)
- depends only on libraries released in opam
- is released in opam
- for binaries: have a way to reproduce the build at a later date (by vendoring
  opam metadata?)
- have a clear indication if the library is used in production (and if yes by
  which project)
- bonus: has been formally verified