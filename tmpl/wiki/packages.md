## Packaging with jbuilder and topkg

This post describes the current state-of-the-art in building and releasing
Mirage libraries with
[jbuilder](https://github.com/janestreet/jbuilder) (to build)
and
[topkg](https://github.com/dbuenzli/topkg) (to release).

### Goals

We wish to

- make development and releasing of individual components as quick and as easy
  as possible
- use a similar structure across the Mirage suite of components to make it
  easier for new people (and automated tools) to work across more than one
  component at a time

### The tools

We make heavy use of the following tools:

- [opam](https://github.com/ocaml/opam): defines a notion of a package, with versioned dependencies on other
  packages inside a package repository.
  We use this to ensure that we have a compatible set of component versions installed
  for our current project.
- [jbuilder](https://github.com/janestreet/jbuilder): a build tool (like `make`) which knows how to build OCaml code
  incrementally and really quickly.
- [topkg](https://github.com/dbuenzli/topkg): a release tool which assists with tagging and uploading artefacts
  to github.

Internally we make heavy use of
[ocamlfind](http://projects.camlcity.org/projects/findlib.html)
but this is wrapped by jbuilder and opam.

### Conventions

We adopt the following conventions:

- we don't use opam's `depopts` to specify sub-libraries. Instead we create
  multiple `opam` packages via multiple `<name>.opam` files in the same repo.
  See [rgrinberg](http://rgrinberg.com/posts/optional-dependencies-considered-harmful/)'s
  post for a rationale
- we prefer to use the same name for both the `ocamlfind` package and the `opam` package. This is to avoid misunderstandings over whether you need to type `mirage-types.lwt` or `mirage-types-lwt` in the current context.
- we write `CHANGES.md` entries in the same style, to ensure they are parseable
  by `topkg`
- we do not enable warnings as errors in the repo; instead we turn these on for
  local developer builds only. This is to prevent released versions from breaking
  when a future compiler version is released.

### Package structure

A Mirage library should have

- `CHANGES.md`: containing a log of user-visible changes in each release.
  For example consider [mirage-tcpip.3.1.2](https://github.com/mirage/mirage-tcpip/blob/v3.1.2/CHANGES.md):
  it has a markdown `###` prefix before each release version and the date in
  `(YYYY-MM-DD)` form.
- `LICENSE.md`: describing the conditions under which the code can be used
  (the Mirage standard license is ISC).
  For example [mirage-tcpip.3.1.2](https://github.com/mirage/mirage-tcpip/blob/v3.1.2/LICENSE).
- `README.md`: describing what the code is for and linking to examples / docs /
  CI status. For example [mirage-tcpip.3.1.2](https://github.com/mirage/mirage-tcpip/blob/v3.1.2/README.md).
- one `<name>.opam` file per opam package defined in the repo.
  For example [mirage-block.1.1.0](https://github.com/mirage/mirage-block/blob/1.1.0/mirage-block.opam)
  and [mirage-block-lwt.1.1.0](https://github.com/mirage/mirage-block/blob/1.1.0/mirage-block-lwt.opam).
  These should have a github pages `doc:` link in order that `topkg` can detect
  the upstream repo.
- `Makefile`: contains `jbuilder` invocations including the `--dev` argument
  to enable warnings as errors for local builds.
  For example [mirage-block.3.1.2](https://github.com/mirage/mirage-block/blob/1.1.0/Makefile)
- `pkg/pkg.ml`: contains the glue between jbuilder and topkg.
  For example [mirage-block.3.1.2](https://github.com/mirage/mirage-block/blob/1.1.0/pkg/pkg.ml).
- one or more `jbuild` files: these describe how to build the libraries, executables
  and tests of your project.
  For example [mirage-block-unix.2.8.1/lib/jbuild](https://github.com/mirage/mirage-block-unix/blob/v2.8.1/lib/jbuild)
  links the main library against OCaml and C,
  while [mirage-block-unix.2.8.1/lib_test/jbuild](https://github.com/mirage/mirage-block-unix/blob/v2.8.1/lib_test/jbuild)
  defines 2 executables and associates one with an alias `runtest`, triggered by
  `make test` in the root.
- create an empty `doc/doc.odocl`. This is (hopefully only temporary) needed to
  release the documentation.


### Developing changes

It should be sufficient to

- `git clone` the repo
- `opam pin add <name> . -n`: to use the local opam metadata (in case it has changed
  from the last released version)
- `opam install --deps-only <name>`: to install any required dependencies

and then

- `make`: to perform an incremental build

### Releasing changes

Mirage releases are published via github. First log into your account and create
a github API token if you haven't already. Store it in a file (e.g. `~/.github/token`).
If on a multi-user machine, ensure the privileges are set to prevent other users
from reading it.

Before releasing anything it's a good idea to review the outstanding issues.
Perhaps some can be closed already? Maybe a `CHANGES.md` entry is missing?

When ready to go, create a branch from `master` and edit the `CHANGES.md` file
to list the interesting changes made since the last release. Make a PR for this
update. The CI will run which is a useful final check that the code still builds
and the tests still pass.
(It's
ok to skip this if the CI was working fine a few moments ago when you merged
another PR).

When the `CHANGES.md` PR is merged, pull it into your local `master` branch.

Read `topkg help release` to have an overview of the full release workflow.
You need to install `odoc`, `topkg-jbuilder` and `opam-publish` to be installed.
Run `opam-publish` once to generate a release token.

Type:

```
topkg tag
```
-- topkg will extract the latest version from the `CHANGES.md` file, perform
version substitutions and create a local tag.

Type:

```
topkg distrib
```
-- topkg will create a release tarball.

Install `odoc,` topkg-jbuilder Type:


```
topkg publish
```
-- topkg will push the tag, create a release and upload the release tarball.
It will also build the docs and push them online.

If you have the [multi-package release rules](https://github.com/mirage/mirage-block/blob/master/Makefile#L12) in your Makefile,
and assumning that you have a clone on `ocaml/opam-repository` in `../opam-repository`, you can then type:

```
make opam-pkg
```

-- this will add new files in your opam-repository clone. `git commit` and push them to your fork on GitHub
and open a new pull-request.

If you only have one package in your repository, you can simply write:

```
topkg tag && topk bistro
```
