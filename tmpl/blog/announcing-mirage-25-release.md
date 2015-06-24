Last summer, we introduced [Mirage
v2.0](/blog/announcing-mirage-20-release): that release improved
portability of unikernels by supporting [ARM
device](/blog/introducing-xen-minios-arm); introduced a new way of
coordinate distributed clusters of unikernels using Irmin, a prototype of
[Git-like distributed, branchable storage](/blog/introducing-irmin); and
improved security with the separate release of OCaml-TLS, the
[transport layer security (TLS) in pure
OCaml](/blog/introducing-ocaml-tls).

Today we announce the new release of MirageOS v2.5, which incorporates
numerous bug-fixes, major stability improvements (especially in the
network stack) and a first-class support for the SSL/TLS in the
MirageOS configuration language. This allows developers to easily
build and deploy secure unikernel services. We will dive into the
details of the release in the next few days, by looking at the results
of the [Piñata](http://ownme.ipredator.se) security bounty, a new
workflow to build secure static websites and the some insights about
how we achieve getting our entropy right even in virtualised
environment.

The full list of changes is available on the [release](/releases) page and
the breaking API changes now have their [own page](/wiki/breaking-changes).

As usual, MirageOS 2.5.0 and the its ever-growing collection of
libraries is packaged with the [OPAM](http://opam.ocaml.org) package
manager, so just follow the [installation instructions](/wiki/install)
to try it and run `opam install mirage` to install the command-line
tool. To update from a previously installed version of MirageOS,
simply use the normal workflow to upgrade your packages by using `opam
update -u`. However, be aware that existing `config.ml` files using
the `conduit` and `http` constructors might need to be updated, see
the [API changes](/wiki/breaking-changes).

We would love to hear your feedback on that release: use either on our [issue
tracker](https://github.com/mirage/mirage/issues) or [our mailing
lists](/community).
