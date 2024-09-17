---
updated: 2022-03-28
authors:
- name: Thomas Gazagnaire
  uri: https://gazagnaire.org
subject: Announcing MirageOS 4.0.0
permalink: announcing-mirage-40
---

**On behalf of the MirageOS team, I am delighted to announce the release
  of MirageOS 4.0.0!**

Since its first release in 2013, MirageOS has made steady progress
towards deploying self-managed internet infrastructure. The
project’s initial aim was to self-host as many services as possible
aimed at empowering internet users to deploy infrastructure securely
to own their data and take back control of their privacy. MirageOS can
securely deploy [static website
hosting](https://github.com/robur-coop/unipi) with “Let’s Encrypt”
certificate provisioning and a [secure SMTP
stack](https://github.com/mirage/ptt) with security
extensions. MirageOS can also deploy decentralised communication
infrastructure like [Matrix](https://github.com/mirage/ocaml-matrix),
[OpenVPN servers](https://github.com/robur-coop/openvpn), and [TLS
tunnels](https://github.com/robur-coop/tlstunnel) to ensure data privacy
or [DNS(SEC) servers](https://github.com/mirage/ocaml-dns) for better
authentication.

The protocol ecosystem now contains [hundreds of libraries](https://github.com/mirage/) and services
millions of daily users. Over these years, major commercial users have
joined the projects. They rely on MirageOS libraries to keep their
products secure. For instance, the MirageOS networking code powers
[Docker Desktop’s
VPNKit](https://www.docker.com/blog/how-docker-desktop-networking-works-under-the-hood/),
which serves the traffic of millions of containers daily. [Citrix
Hypervisor](https://www.citrix.com/fr-fr/products/citrix-hypervisor/)
uses MirageOS to interact with Xen, the hypervisor that powers most of
today’s public
cloud. [Nitrokey](https://www.nitrokey.com/products/nethsm) is
developing a new hardware security module based on
MirageOS. [Robur](https://robur.coop/) develops a unikernel
orchestration system for fleets of MirageOS
unikernels. [Tarides](https://tarides.com/) uses MirageOS to improve
the [Tezos](https://tezos.com/) blockchain, and
[Hyper](https://hyper.ag/) uses MirageOS to build sensor analytics and
an automation platform for sustainable agriculture.

In the coming weeks, our blog will feature in-depth technical content
for the new features that MirageOS brings and a tour of
the existing community and commercial users of MirageOS. Please reach out
If you’d like to tell us about your story.

## Install MirageOS 4

The easiest way to install MirageOS 4 is by using the [opam package
manager](https://opam.ocaml.org/) version 2.1. Follow the
[installation guide](https://mirage.io/docs/install) for more details.

```
$ opam update
$ opam install 'mirage>4'
```

*Note*: if you upgrade from MirageOS 3, you will need to manually clean
the previously generated files (or call `mirage clean` before
upgrading). You would also want to read [the complete list of API
changes](https://mirage.io/docs/breaking-changes). You can see
unikernel examples in
[mirage/mirage-skeleton](https://github.com/mirage/mirage-skeleton),
[robur-coop/unikernels](https://github.com/robur-coop/unikernels) or
[tarides/unikernels](https://github.com/tarides/unikernels).

## About MirageOS

MirageOS is a library operating system that constructs unikernels for
secure, high-performance, low-energy footprint applications across
various hypervisor and embedded platforms. It is available as an
open-source project created and maintained by the [MirageOS Core
Team](https://mirage.io/community). A unikernel
can be customised based on the target architecture by picking the
relevant MirageOS libraries and compiling them into a standalone
operating system, strictly containing the functionality necessary
for the target. This minimises the unikernel’s footprint, increasing
the security of the deployed operating system.

The MirageOS architecture can be divided into operating system
libraries, typed signatures, and a metaprogramming compiler. The
operating system libraries implement various functionalities, ranging
from low-level network card drivers to full reimplementations of the
TLS protocol, as well as the Git protocol to store versioned data. A
set of typed signatures ensures that the OS libraries are consistent
and work well in conjunction with each other. Most importantly,
MirageOS is also a metaprogramming compiler that can input OCaml
source code along with its dependencies, and a deployment target
description to generate an executable unikernel, i.e., a
specialised binary artefact containing only the code needed to run on
the target platform. Overall, MirageOS focuses on providing a small,
well-defined, typed interface with the system components of the target
architecture.

## What’s New in MirageOS 4?

The MirageOS4 release focuses on better integration with existing
ecosystems. For instance, parts of MirageOS are now merged into the
OCaml ecosystem, making it easier to deploy OCaml applications into a
unikernel. Plus, we improved the cross-compilation support, added more
compilation targets to MirageOS (for instance, we have an experimental
bare-metal [Raspberry-Pi 4
target](https://github.com/mirage/mirage/pull/1253), and made it
easier to integrate MirageOS with C and Rust libraries.

This release introduces a significant change in how MirageOS compiles
projects. We developed a new tool called
[opam-monorepo](https://github.com/ocamllabs/opam-monorepo) that
separates package management from building the resulting source
code. It creates a lock file for the project’s dependencies, downloads
and extracts the dependency sources locally, and sets up a [dune
workspace](https://dune.readthedocs.io/en/stable/dune-files.html#dune-workspace-1),
enabling `dune build` to build everything simultaneously. The MirageOS
4.0 release also contains improvements in the `mirage` CLI tool, a new
libc-free OCaml runtime (thus bumping the minimal required version of
OCaml to 4.12.1), and a cross-compiler for OCaml. Finally, MirageOS
4.0 now supports the use of familiar IDE tools while developing
unikernels via Merlin, making day-to-day coding much faster.

Review a complete list of features on the [MirageOS 4 release
page](https://mirage.io/docs/mirage-4). And check out [the breaking
API changes](https://mirage.io/docs/breaking-changes).

## About Cross-Compilation and opam overlays

This new release of MirageOS adds systematic support for
cross-compilation to all supported unikernel targets. This means that
libraries that use C stubs (like Base, for example) can now seamlessly
have those stubs cross-compiled to the desired target. Previous
releases of MirageOS required specific support to accomplish this by
adding the stubs to a central package. MirageOS 4.0 implements
cross-compilation using [Dune
workspaces](https://dune.readthedocs.io/en/stable/dune-files.html#dune-workspace-1),
which can take a whole collection of OCaml code (including all
transitive dependencies) and compile it with a given set of C and
OCaml compiler flags.

The change in how MirageOS compiles projects that accompanies this
release required implementing a new developer experience for Opam
users, to simplify cross-compilation of large OCaml projects.

A new tool called
[opam-monorepo](https://dune.readthedocs.io/en/stable/dune-files.html#dune-workspace-1)
separates package management from building the resulting source
code. It is an opam plugin that:
- creates a lock file for the project’s dependencies
- downloads and extracts the dependency sources locally
- sets up a Dune workspace so that `dune build` builds everything in one
go.

`opam-monorepo` is already available in opam and can be used
on many projects which use Dune as a build system. However, as we
don’t expect the complete set of OCaml dependencies to use Dune, we
MirageOS maintainers are committed to maintaining patches that build
the most common dependencies with dune. These packages are hosted in two
separate Opam repositories:
- [dune-universe/opam-overlays](https://github.com/dune-universe/opam-overlays)
  adds patched packages (with a `+dune` version) that compile with
  Dune.
- [dune-universe/mirage-opam-overlays](https://github.com/dune-universe/mirage-opam-overlays)
  add patched packages (with a `+dune+mirage` version) that fix
  cross-compilation with Dune.

When using the `mirage` CLI tool, these repositories are enabled by default.

## In Memory of Lars Kurth

<img src="https://xenproject.org/wp-content/uploads/sites/79/2020/01/LarsK_0.jpg" width="180" heigth="180"></img>

We dedicate this release of MirageOS 4.0 to [Lars
Kurth](https://xenproject.org/2020/01/31/saying-goodbye-to-lars-kurth-open-source-advocate-and-friend/).
Unfortunately, he passed away early in 2020, leaving a big hole in our
community. Lars was instrumental in bringing the Xen Project to
fruition, and we wouldn’t be here without him.
