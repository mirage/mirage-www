Welcome to the MirageOS 4 release page. No official announcement has been made, 
but the current work is available as a bleeding-edge repository.

You can follow the advances in the release process through the 
[tracking issue](https://github.com/mirage/mirage/issues/1217).

### What's new ?

The main change is a deep modification on how unikernels are built. One of the 
purposes of MirageOS is to orchestrate a build a system in order to produce the desired
unikernel binary. Until MirageOS 4, the build system was `ocamlbuild`. Now, we switched 
to `dune`. Following a global shift to the `dune` build system, this enables us many 
features that were slowing down the MirageOS development workflow.

- **Monorepos**: unikernel sources are locally fetched to be compiled by `dune`. This 
  implies that one can locally edit theses sources to test changes, before sending them
  to the upstream repository. It replaces the usual `opam pin ...` / edit sources /
  `opam reinstall ...` workflow.

  The monorepos are built using the [opam-monorepo](https://github.com/ocamllabs/opam-monorepo) 
  tool, consisting in two steps. First a lockfile is generated, performing the 
  dependency resolution and locking packages to specific versions. Then the lockfile is 
  used to locally fetch the sources.

- **Cross-compilation**: one of the problems of MirageOS 3.x was the difficulty to create
  new targets into the ecosystem, especially cross-archicture targets. Because opam 
  installs packages for the host architecture, one would have to create a parallel 
  repository in which packages are cross-compiled, such as 
  [opam-cross-android](https://github.com/ocaml-cross/opam-cross-android) or 
  [opam-cross-esp32](https://github.com/well-typed-lightbulbs/opam-cross-esp32). That 
  _parallel world_ idea has also been implemented using `esy`: see 
  [reason-mobile](https://github.com/EduardoRFS/reason-mobile).

  The MirageOS 4 solution takes advantage of the dune _workspaces_ feature, which 
  defines a global compilation environment (OCaml compiler, C compiler, flags and 
  environment variables) to be used to build all the sources that are locally available.
  As a consequence, porting a new target to Mirage 4 will only rely on having a 
  _freestanding_ (i.e. OS-free) OCaml compiler. 

- **Reproducible workflow**: because lockfiles are used to fetch the unikernel sources,
  we can ensure that the exact same sources will be used to build the unikernel as the as
  the lockfile has not changed. Additional work might be required to ensure that the 
  rest of the tools (mirage, dune, ocaml-freestanding) are also locked to a specific 
  version.

- **Merlin support**: `dune` automatically enables the usage of `merlin` to improve the
  developper experience. Its editor support can be enabled for example by using the ocaml
  LSP server. Due to current limitations, `merlin` can be enabled either on the 
  `config.ml` file or the unikernel files, but not both at the same time.

  Note that until the next release of `dune`, `merlin` support must be activated manually 
  in the `dune-workspace` file. [documentation](https://dune.readthedocs.io/en/stable/dune-files.html#context)

### Ecosystem changes

- **Port to dune**: since the beginning of the work on MirageOS 4, many packages have
  been ported to dune. This is a _requirement_ to be able to use it in a unikernel. 
  The libraries using alternative build systems (such as `B0`) have been ported to `dune`,
  but as upstreaming the work is not expected, the MirageOS team maintains a repository
  of _build system forks_: [mirage/opam-overlays](https://github.com/mirage/opam-overlays). 

  The mission of porting and maintaining _dune-built_ forks is assured by the 
  [dune-universe](https://github.com/dune-universe) team.

- **Solo5 and OCaml-freestanding**: to support the new _cross-compilation_ workflow, 
  `solo5` becomes a cross-compilation toolchain (`ARCH-solo5-none-static-cc`) and 
  `ocaml-freestanding` becomes an OCaml cross-compiler based on that solo5 toolchain. 

- **C stubs compilation**: the rule for C stubs compilation has also changed. Until now,
  package maintainers that uses C stubs had to add some code to build the C stubs using the
  `solo5` flags, through the `ocaml-freestanding` `pkg-config` file.

  Now, package maintainers should only care about writing portable code once, and built it 
  using `dune` rules.


To sum it up, here are the **portable compilation rules** for a package to support Mirage 4.0: 
1) Don't depend on `unix`
2) Build your project with `dune`, and have your transitive dependencies buildable using `dune`.
3) If your project use C stubs, assume the `libc` is minimal. See `ocaml-freestanding`'s `nolibc` 
   for reference: [github.com/mirage/ocaml-freestanding/tree/master/nolibc/include](https://github.com/mirage/ocaml-freestanding/tree/master/nolibc/include)

### Tool changes

##### API breakages

The functoria devices has changed, switching from requesting objects to a function with optional parameters.
An additional `dune` field can be used to have additional rules related to the device. 

See this [commit](https://github.com/mirage/mirage-skeleton/commit/4d3f7afdcfdff9136cd4e3973afdce9de4934178) as 
an example on how to adapt the objects to the new interface.

##### Configure

The `mirage` command-line interface hasn't fundamentally changed, but when a project is _configured_, 
the following additional files are generated:

- **dune.build**: the dune rules to build the unikernel.
- **dune.config**: the dune rules to build the unikernel's configuration.
- **dune**: switch between `dune.build` and `dune.config` depending on the context.
- **dune-workspace**: the compilation workspace definition, asking dune to use the ocaml-freestanding 
  cross-compiler. 
- **mirage/UNIKERNEL-monorepo.opam**: the unikernel dependencies to lock and fetch using `opam-monorepo`.
- **mirage/UNIKERNEL-switch.opam**: the tool dependencies to `opam install` (it includes `solo5` and `ocaml-freestanding`)

##### Fetch

To fetch and install the dependencies, `make depends` is still the command to go:
- it globally installs the build dependencies in the switch.
- it locally fetches using `opam-monorepo` the unikernel dependencies in the `duniverse/` folder.

##### Build

To build the unikernel, `mirage build` and `dune build` are equivalent.
The output is available in the `dist/` folder. 

### How to test 

```sh
# Add the MirageOS 4 development repository
$ opam repo add mirage https://github.com/mirage/mirage-dev.git#master

# Install MirageOS 4
$ opam install mirage

# Clone this website
$ git clone https://github.com/mirage/mirage-www -b next

# Go in the source folder
$ cd mirage-www/src

# Configure the unikernel
$ mirage configure -t hvt

# Fetch and install dependencies
$ make depend

# Build the unikernel
$ mirage build

# Launch it (a tap interface needs to be configured for the hvt target)
$ solo5-hvt --net:service=tap100 dist/www.hvt
```
