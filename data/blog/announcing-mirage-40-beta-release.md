---
updated: 2022-02-10 17:00
authors:
- name: Thomas Gazagnaire
  uri: https://gazagnaire.org
subject: Announcing MirageOS 4.0.0 Beta Release
permalink: announcing-mirage-40-beta-release
---

**On behalf of the Mirage team, I am delighted to announce the beta release of MirageOS 4.0!**

[MirageOS](https://mirage.io) is a library operating system that constructs unikernels for secure, high-performance network applications across a variety of hypervisor and embedded platforms. For example, OCaml code can be developed on a standard OS, such as Linux or macOS, and then compiled into a fully standalone, specialised unikernel that runs under a Xen or KVM hypervisor. The MirageOS project also supplies several protocol and storage implementations written in pure OCaml, ranging from TCP/IP to TLS to a full Git-like storage stack.

The beta of the MirageOS 4.00 release contains:
- `mirage.4.0.0~beta`: the CLI tool;
- `ocaml-freestanding.0.7.0`: a libc-free OCaml runtime;
- and `solo5.0.7.0`: a cross-compiler for OCaml.

They are all available in `opam` by using:
```
opam install 'mirage>=4.0'
```

*Note*: you need to explicitly add the `4.0>=0` version here, otherwise `opam` will select the latest `3.*` stable release. For a good experience, check that at least version `4.0.0~beta3` is installed.

## New Features

This new release of MirageOS adds systematic support for cross-compilation to all supported unikernel targets. This means that libraries that use C stubs (like Base, for example) can now seamlessly have those stubs cross-compiled to the desired target.  Previous releases of MirageOS required specific support to accomplish this by adding the stubs to a central package.

MirageOS implements cross-compilation using *Dune Workspaces*, which can take a whole collection of OCaml code (including all transitive dependencies) and compile it with a given set of C and OCaml compiler flags. This workflow also unlocks support for familiar IDE tools (such as `ocaml-lsp-server` and Merlin) while developing unikernels in OCaml. It makes day-to-day coding much faster because builds are decoupled from configuration and package updates. This means that live-builds, such as Dune's watch mode, now work fine even for exotic build targets!

A complete list of features can be found on the [MirageOS 4 release page](https://mirage.io/docs/mirage-4).

## Cross-Compilation and Dune Overlays

This release introduces a significant change in the way MirageOS projects are compiled based on Dune Workspaces. This required implementing a new developer experience for Opam users in order to simplify cross-compilation of large OCaml projects.

That new tool, called [opam-monorepo](https://github.com/ocamllabs/opam-monorepo) (née duniverse), separates package management from building the resulting source code. It is an Opam plugin that:
- creates a lock file for the project dependencies
- downloads and extracts the dependency sources locally
- sets up a Dune Workspace so that `dune build` builds everything in one go.

[![asciicast](https://asciinema.org/a/rRf6s8cNyHUbBsDDfZkBjkf7X.svg)](https://asciinema.org/a/rRf6s8cNyHUbBsDDfZkBjkf7X?speed=2)

`opam-monorepo` is already available in Opam and can be used on many projects which use `dune` as a build system. However, as we don't expect the complete set of OCaml dependencies to use `dune`, we MirageOS maintainers are committed to maintaining patches to build the most common dependencies with `dune`. These packages are hosted in a separate [dune-universe/mirage-opam-overlays](https://github.com/mirage/opam-overlays) repository, which can be used by `opam-monorepo` and is enabled by default when using the Mirage CLI tool.

## Next Steps

Your feedback on this beta release is very much appreciated. You can follow the tutorials on https://mirage.io/wiki/mirage-4, our self-hosted staging site using MirageOS 4. Issues are very welcome on https://github.com/mirage/mirage/issues, or come find us on Matrix in the MirageOS channel: [#mirageos:matrix.org](https://matrix.to/#/#mirageos:matrix.org).

The **final release** will happen in about a month. This release will incorporate your early feedback. It will also ensure the existing MirageOS ecosystem is compatible with MirageOS 4 by reducing the overlay packages to the bare minimum. We also plan to write more on `opam-monorepo` and all the new things MirageOS 4.0 will bring.
