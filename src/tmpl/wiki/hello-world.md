
First, make sure you have followed the [installation instructions](/wiki/install)
to get a working MirageOS installation. The examples below are in
the [mirage-skeleton](http://github.com/mirage/mirage-skeleton) repository.
Begin by cloning and changing directory to it:

```bash
$ git clone git://github.com/mirage/mirage-skeleton.git
$ cd mirage-skeleton
```

The `mirage-skeleton` repository classifies its examples into three groups.
This document refers to unikernels in the `tutorial` directory.

**Note**: Before we begin, if you aren't familiar with the Lwt library (and the
`>>=` operator it provides), you may want to read at least the start of
the [Lwt tutorial](/wiki/tutorial-lwt) first.

**Additional note**: Throughout the tutorial, we'll use `mirage configure -t unix`
to demonstrate building MirageOS applications.  If you're using a macOS
machine, you should use `mirage configure -t macosx` instead.

### Step 0: Doing Nothing!

Before we try and do anything complicated, let's build a unikernel that starts
and then exits, without doing anything else. The code for this is, as you might
hope, fairly short. First, the unikernel itself:

```ocaml
$ cat tutorial/noop/unikernel.ml
let start =
  Lwt.return_unit
```

So this is a unikernel whose entry point (`start`) does nothing other than
return an `Lwt` thread that will evaluate to `unit`. Easy.

Before we can build even our `noop` unikernel, we must define its configuration.
That is, we need to tell Mirage what OCaml module contains the `start` entry
point. We do this by writing a `config.ml` file that sits next to our
`unikernel.ml` file:

```ocaml
$ cat tutorial/noop/config.ml
open Mirage

let main =
  main "Unikernel" job

let () =
  register "noop" [main]
```

There's a little more going on here than in `unikernel.ml`. First we open the
`Mirage` module to save on typing. Next, we define a value `main`.  This name is
only a convention, and you should feel free to change it if you wish.
`main` calls the `Mirage.main` function, passing two parameters.
The first is a string declaring the module name that contains
our entry point — in this case, standard OCaml compilation behaviour means that
the `unikernel.ml` file produces a module named `Unikernel`. Again, there's
nothing special about this name, and if you want to use something else here,
simply rename `unikernel.ml` accordingly.

The second parameter, `job`, is a bit more interesting. This declares the type
of our unikernel in terms of the devices (that is, things such as network
interfaces, network stacks, filesystems and so on) it requires to operate. As
this is a unikernel that does nothing, it needs no devices and so is simply a
`job`.

Finally, we declare the entry point to OCaml in the usual way (`let () = ...`),
`register`ing our unikernel entry point (`main`) with a name (`"noop"` in this
case) to be used when we build our unikernel.

Building our unikernel is then simply a matter of:
1. Evaluating its configuration:

```bash
$ cd tutorial/noop
/Users/mort/research/projects/mirage/src/mirage-skeleton/tutorial/noop
$ mirage configure -t unix
```

2. Installating dependencies:

- `opam install` for installing the build tools in the opam switch.
- `opam-monorepo lock` resolves the unikernel dependencies a generates a 
  _lockfile_.
- `lockfile depext` installs the external dependencies of the unikernel
  dependencies (another set of potential build tools).
- `opam-monorepo pull` locally fetch unikernel dependencies.

NOTE: while performing the _lock_ step, an additional repository 
(https://github.com/mirage/opam-overlays.git) is added in your opam switch. 
This repository contains packages that have been changed to use the _dune_ build 
system. The `--extra-repo` argument in `mirage configure` changes the additional 
repository to use. `--no-extra-repo` can be used to disable the extra repository, 
but the _lock_ step might fail because of dependencies that are not using the 
_dune_ build system.

```json
$ make depend
 ↳ opam depexts
 ↳ opam install global dependencies
Nothing to do.
using overlay repository mirage-tmp: https://github.com/mirage/opam-overlays.git
[mirage-tmp] no changes from git+https://github.com/mirage/opam-overlays.git
[NOTE] Repository mirage-tmp has been added to the selections of switch
       mirage-4.12.0 only.
       Run `opam repository add mirage-tmp
       --all-switches|--set-default' to use it in all existing
       switches, or in newly created switches, respectively.

 ↳ opam-monorepo lock
==> Using 1 locally scanned package as the root.
==> Found 55 opam dependencies for the root package.
==> Querying opam database for their metadata and Dune compatibility.
==> Calculating exact pins for each of them.
==> Wrote lockfile with 39 entries to mirage/noop-unix.opam.locked. You can now run opam monorepo pull to fetch their sources.
 ↳ lockfile depexts
removing overlay repository mirage-tmp
Repositories removed from the selections of switch mirage-4.12.0. Use '--all' to forget about them altogether.
 ↳ opam-monorepo pull
==> Pulling lockfile mirage/noop-unix.opam.locked          
Successfully pulled 39/39 repositories
```

...and compiling:

```bash
$ make
```

As we configured for Unix (the `-t unix` argument to the `mirage configure`
command), the result is a standard Unix ELF binary that can simply be executed:

```bash
$ ls -l dist/noop
-rwxr-xr-x 1 lucas lucas 5280056 Sep 27 11:52 noop
$ dist/noop
$ echo $?
0
```

Congratulations! You've just built and run your very first unikernel!

#### Aside: Doing Nothing with Functors!

Functors are one of those OCaml things that can seem a bit intimidating at first
(traditionally, "monads" get the same sort of reaction). However, as they're
used fairly widely throughout Mirage, a very brief introduction to the commonest
way we use them is needed. For a better introduction as to how to actually make
use of them, what they are, and so on
see
[Real World OCaml, Ch.9](https://realworldocaml.org/v1/en/html/functors.html)
(and also
[Ch.10, First-Class Modules](https://realworldocaml.org/v1/en/html/first-class-modules.html)).

In short, in Mirage, they're used as a way to abstract over the target
environment for the unikernel. Functors are, roughly, functions from modules to
modules, and they allow us to pass modules into a unikernel so that the code
inside a unikernel can interact with its environment (read files, send packets,
etc) without needing to care whether it's been built to target Unix, Xen, KVM, or
something else entirely. The modules that are passed into the unikernel in this
way are required to conform to type signatures that are specified when the
unikernel `job` value is created in the `config.ml` file.

We'll see several examples of this below but, for now, we need to wrap up our
`noop` unikernel in a module inside the `Unikernel` module so that we can use it
as a functor. This is actually quite straightforward — we simply wrap the
`start` function in `unikernel.ml` inside some module. For example,

```ocaml
$ cat tutorial/noop-functor/unikernel.ml
module Main = struct

  let start =
    Lwt.return_unit

end
```

The use of the name `Main` is purely convention, and you should feel free to
replace it with completely different if you wish!

The only other change is to the corresponding invocation in `config.ml`:

```ocaml
$ cat tutorial/noop-functor/config.ml
open Mirage

let main =
  main "Unikernel.Main" job

let () =
  register "noop" [main]
```

Note that the string passed to `main` is now `"Unikernel.Main"` as we must
refer to the `Main` module inside the `Unikernel` module. Everything else stays
the same.  Go ahead and try that out by building the unikernel inside
`noop-functor`.


...and now, onwards to unikernels that actually **do** something!

### Step 1: Hello World!

As a first step, let's build and run the MirageOS "Hello World" unikernel.
This will print a log message with the word `hello` 4 times before terminating:

```
2017-02-08 09:54:44 -01:00: INF [application] hello
2017-02-08 09:54:45 -01:00: INF [application] hello
2017-02-08 09:54:46 -01:00: INF [application] hello
2017-02-08 09:54:47 -01:00: INF [application] hello
```

First, let's look at the code:

```ocaml
$ cat hello/unikernel.ml
open Lwt.Infix

module Hello (Time : Mirage_time.S) = struct

  let start _time =

    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
        Logs.info (fun f -> f "hello");
        Time.sleep_ns (Duration.of_sec 1) >>= fun () ->
        loop (n-1)
    in
    loop 4

end
```

To veteran OCaml programmers among you, this might look a little odd: We have a
main `Hello` module parameterised by a module (`Time`, of type `Mirage_time.S`) that contains a method `start` taking an ignored parameter `_time` (an instance of a `time`).  This is the basic structure required to make this a MirageOS unikernel
rather than a standard OCaml POSIX application.

The module type for our `Time` module, `Mirage_time.S`, is defined in an
external package [mirage-time](https://github.com/mirage/mirage-time).  The name `S` for "the module type of things like this" is a common OCaml convention (comparable to naming the most-used type in a module `t`).  There are many packages defining module types for use in Mirage.

The concrete implementation of `Time` will be supplied at
compile time, depending on the target that you are compiling for. This
configuration is stored in `config.ml`, so let's take a look:

```ocaml
$ cat tutorial/hello/config.ml

open Mirage

let main =
  main
    ~packages:[package "duration"]
    "Unikernel.Hello" (time @-> job)

let () =
  register "hello" [main $ default_time]
```

The configuration file is a normal OCaml module that calls `register` to create
one or more jobs, each of which represent a process (with a start/stop
lifecycle). Each job most likely depends on some device drivers; all the
available device drivers are defined in the `Mirage` module
(see [the Mirage module documentation](http://mirage.github.io/mirage/)).

In this case, the `main` variable declares that the entry point of the process
is the `Hello` module from the file `unikernel.ml`. The `@->` combinator is used
to add a device driver to the list of functor arguments in the job definition
(see `unikernel.ml`), and the final value of using this combinator should always
be a `job` if you intend to register it.

The `foreign` function also takes some additional arguments: `~keys`, the list of
configuration keys we want to allow the user to specify at configuration or build time, and
`packages`, a list of additional `opam` packages that should be included in the list of
build dependencies for the project.  We'll talk more about configuration keys in the next example.

Notice that we refer to the module name as a string (`"Unikernel.Hello"`) when
calling `main`, instead of directly as
an OCaml value. The `mirage` command-line tool evaluates this configuration file
at build time and outputs a `main.ml` that has the concrete values filled in for
you, with the exact modules varying by which backend you selected (e.g. Unix or
Xen).

MirageOS mirrors the unikernel model on Unix as far as possible: your application is
built as a unikernel which needs to be instantiated and run whether on Unix or
on a hypervisor backend like Xen or KVM. When your unikernel is run, it starts
much like a conventional OS does when run as a virtual machine, and so it must
be passed references to devices such as the console, network interfaces and
block devices on startup.

In this case, this simple `hello world` example requires some notion of time,
so we register a single `Job` consisting of the `Unikernel.Hello` module
(and, implicitly its `start` function) and pass it references to a
timer.

#### Building a Unix binary

We invoke all this by configuring, building and finally running the resulting
unikernel under Unix first.

```bash
$ cd tutorial/hello
$ mirage configure -t unix
```

`mirage configure` generates a `Makefile` with all the build rules included from
evaluating the configuration file, a `main.ml` that represents the entry point
of your unikernel, and an `opam` file with a list of the packages necessary to
build the unikernel.

```bash
$ make depend
```

In order to automatically install the dependencies discovered by `mirage
configure` in your current `opam` switch, execute `make depend`.

```bash
$ make
```

This builds a Unix binary called `hello` that contains the simple console
application, it is available in the `dist` folder. Note that `make` simply calls
`mirage build` which itself turns into a simple `dune build` command. If you are 
familiar with `dune` it is possible to inspect the build rules for the unikernel. 

Finally to run your application, simply run it
directly — as it is a standard Unix binary — and observe the exciting log messages that our loop is generating:

```bash
$ ./hello
```

#### Building for Another Backend

**Note**: The following sections of this tutorial use the [Solo5](https://github.com/Solo5/solo5/tree/v0.7.0)-based `hvt` backend as an example. This backend is supported on Linux, FreeBSD, and OpenBSD systems with hardware virtualization. Please see the Solo5 documentation for the support [status](https://github.com/Solo5/solo5/blob/v0.7.0/docs/building.md#supported-targets) of further backends such as `spt` (for deployment on Linux using a strict seccomp sandbox), `virtio` (for deployment on e.g. Google Compute Engine) and `muen` (for deployment on the [Muen Separation Kernel](https://muen.sk)).

To build a Solo5-based unikernel that will run on a host system with hardware virtualization, re-run `mirage configure` and ask for the `hvt` target instead of `unix`.

```bash
$ mirage configure -t hvt
$ make depend
$ make
```
*Everything* else remains the same! The set of dependencies required, the `main.ml`, and the `Makefile` differ significantly, but since the source code of your application was
parameterised over the `Time` type, it doesn't matter — you do not need to
make any changes for your code to run when linked against the Solo5 console driver
instead of Unix.

When you build the `hvt` version, you'll see a new artifact which is the
unikernel: a file called `hello.hvt`.  A `solo5-hvt` binary will be installed by OPAM on your `$PATH`. This binary is a _tender_, responsible for loading your unikernel, attaching to host system devices and running it. To try running `hello.hvt`, pass it as an argument to `solo5-hvt`:

```bash
$ solo5-hvt dist/hello.hvt
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Memory map: 512 MB addressable:
Solo5:     unused @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1e8fff)
Solo5:     rodata @ (0x1e9000 - 0x220fff)
Solo5:       data @ (0x221000 - 0x2d0fff)
Solo5:       heap >= 0x2d1000 < stack < 0x20000000
2018-06-21 12:16:28 -00:00: INF [application] hello
2018-06-21 12:16:29 -00:00: INF [application] hello
2018-06-21 12:16:30 -00:00: INF [application] hello
2018-06-21 12:16:31 -00:00: INF [application] hello
Solo5: solo5_exit(0) called
```

We get some additional output from the initialization of the unikernel and its successful boot, then we see our expected output, and Solo5's report of the application's successful completion.

#### Configuration Keys

It's very common to pass additional runtime information to a program via command-line options or arguments.  But a unikernel doesn't have access to a command line, so how can we pass it runtime information?

Mirage provides a nice abstraction for this in the form of configuration keys.  The `Mirage` module provides a module `Key`, which contains functions for creating and using configuration keys.  For an example, let's have a look at `hello-key`:

```
$ cd tutorial/hello-key
$ cat config.ml
open Mirage

let hello =
  let doc = Key.Arg.info ~doc:"How to say hello." ["hello"] in
  Key.(create "hello" Arg.(opt string "Hello World!" doc))

let main =
  main
    ~keys:[key hello]
    ~packages:[package "duration"]
    "Unikernel.Hello" (time @-> job)

let () =
  register "hello" [main $ default_time]
```

We create a `key` with `Key.create` which is an optional bit of configuration.  It will default to "Hello World!" if unspecified.  This particular key happens to be of type `string`, so no conversion will be required, but it's possible to ask for more exotic types in the call to `Arg`.  See [the Functoria Key.Arg module documentation](http://mirage.github.io/functoria/functoria/Functoria_key/Arg/index.html) for more details.

Once we've created our configuration key, we specify that we'd like it available in the unikernel by passing it to `main` in the `keys` parameter.

We can then read the value corresponding to configuration key using the generated function `Key_gen.hello` as shown below.

```
$ cat unikernel.ml
open Lwt.Infix

module Hello (Time : Mirage_time_lwt.S) = struct

  let start _time =

    let hello = Key_gen.hello () in

    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
        Logs.info (fun f -> f "%s" hello);
        Time.sleep_ns (Duration.of_sec 1) >>= fun () ->
        loop (n-1)
    in
    loop 4

end
```

Let's configure the example for Unix and build it:

```bash
$ mirage configure -t unix
$ make depend
$ make
```

When the target is Unix, Mirage will use an implementation for configuration keys that looks at the contents of `OS.Env.argv`. In other words, it looks directly at the command line that was used to invoke the program.  If we call `hello` with no arguments, the default value is used:

```
$ dist/hello
2017-02-08 18:18:23 -03:00: INF [application] Hello World!
2017-02-08 18:18:24 -03:00: INF [application] Hello World!
2017-02-08 18:18:25 -03:00: INF [application] Hello World!
2017-02-08 18:18:26 -03:00: INF [application] Hello World!
```

but we can ask for something else:

```
$ dist/hello --hello="Bonjour!"
2017-02-08 18:20:46 +09:00: INF [application] Bonjour!
2017-02-08 18:20:47 +09:00: INF [application] Bonjour!
2017-02-08 18:20:48 +09:00: INF [application] Bonjour!
2017-02-08 18:20:49 +09:00: INF [application] Bonjour!
```

When the target is Unix, it's also possible to get useful hints by calling the generated program with `--help`.

Many configuration keys can be specified either at configuration time or at run time.  `mirage configure` will allow us to change the default value for `hello`, while retaining the ability to override it at runtime:

```
$ mirage configure -t unix --hello="Hola!"
$ make depend
$ make
$ dist/hello
2017-02-08 18:30:30 +06:00: INF [application] Hola!
2017-02-08 18:30:31 +06:00: INF [application] Hola!
2017-02-08 18:30:32 +06:00: INF [application] Hola!
2017-02-08 18:30:33 +06:00: INF [application] Hola!
$ dist/hello --hello="Hi!"
2017-02-08 18:30:54 +06:00: INF [application] Hi!
2017-02-08 18:30:55 +06:00: INF [application] Hi!
2017-02-08 18:30:56 +06:00: INF [application] Hi!
2017-02-08 18:30:57 +06:00: INF [application] Hi!
```

When configured for non-Unix backends, other mechanisms are used to pass the runtime information to the unikernel.  `solo5-hvt`, which we used to run `hello.hvt` in the non-keyed example, will pass keys specified on the command line to the unikernel when invoked:

```
$ cd tutorial/hello-key
$ mirage configure -t hvt
$ make depend
$ make
$ solo5-hvt -- dist/hello.hvt --hello="Hola!"
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Memory map: 512 MB addressable:
Solo5:     unused @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1e8fff)
Solo5:     rodata @ (0x1e9000 - 0x220fff)
Solo5:       data @ (0x221000 - 0x2d1fff)
Solo5:       heap >= 0x2d2000 < stack < 0x20000000
2018-06-21 12:18:03 -00:00: INF [application] Hola!
2018-06-21 12:18:04 -00:00: INF [application] Hola!
2018-06-21 12:18:05 -00:00: INF [application] Hola!
2018-06-21 12:18:06 -00:00: INF [application] Hola!
Solo5: solo5_exit(0) called
```

### Step 2: Getting a block device

Most useful unikernels will need to obtain data from the outside world, so we'll
explain this subsystem next.

#### Sector-addressible block devices

The [device-usage/block/](https://github.com/mirage/mirage-skeleton/tree/master/device-usage/block)
directory in `mirage-skeleton` contains an example of attaching a raw block
device to your unikernel.
The [Mirage_block](https://mirage.github.io/mirage-block)
interface signature contains the operations that are possible on a block device:
primarily reading and writing aligned buffers to a 64-bit offset within the
device.

On Unix, the development workflow to handle block devices is by mapping them
onto local files. The `config.ml` for the block example contains some logic for automatically creating a disk image file (and removing it when `mirage clean` is called), in addition to a more familiar-looking set of calls to `foreign` and `register`:

```ocaml
open Mirage

type shellconfig = ShellConfig
let shellconfig = typ ShellConfig

let config_shell = impl
  ~dune:(fun _i -> [Dune.stanza {|
(rule (targets disk.img)
 (action (run dd if=/dev/zero of=disk.img count=100000))
)|}])
  ~install:(fun _ -> Functoria.Install.v ~etc:[Fpath.v "disk.img"] ())
  "shell_config"
  shellconfig

let main =
  let packages = [ package "io-page"; package "duration"; package ~build:true "bos"; package ~build:true "fpath" ] in
  main
    ~packages
    ~deps:[dep config_shell] "Unikernel.Main" (time @-> block @-> job)

let img = Key.(if_impl is_solo5 (block_of_file "storage") (block_of_file "disk.img"))

let () =
  register "block_test" [main $ default_time $ img]
```

The `main` binding looks much like the earlier `hello` example, except for the
addition of a `block` device in the list. When we register the job, we supply a
block device from a local file via [`block_of_file`](https://docs.mirage.io/mirage/Mirage/#val-block_of_file).

Using `deps` we also supply a _custom dependency_ `config_shell` in charge of 
building the `disk.img` image. This is done using _dune_ rules.

<br />
<div class="panel callout">
  <i class="fa fa-info fa-3x pull-left"> </i>
  <p>
    As an aside, if you have your editor configured with OCaml mode, you should
    be able to see the inferred types for some of the variables in the
    configuration file. The <code>@-></code> and <code>$</code> combinators are
    designed such that any mismatches in the declared device driver types and
    the concrete registered implementations will result in a type error at
    configuration time.
  </p>
</div>

Build this on Unix in the same way as the previous examples:

```bash
$ cd device-usage/block
$ mirage configure -t unix
$ make depend
$ make
$ ./dist/block_test
```

`block_test` will write a series
of patterns to the block device and read them back to check that they are the
same (the logic for this is in `unikernel.ml` within the `Block_test` module).

We can build this example for another backend too:

```bash
$ mirage configure -t hvt
$ make depend
$ make
```

Now we just need to boot the unikernel with `solo5-hvt` as before. We should see
the same output after the VM boot preamble, but now MirageOS is linked against the
Solo5 [block device driver](https://github.com/mirage/mirage-block-solo5) and is
mapping the unikernel's block requests directly through to it, rather than
relying on the host OS (the Linux or FreeBSD kernel).

If we tell `solo5-hvt` where the disk image is, it will provide that disk image to the unikernel:

```bash
$ solo5-hvt --block:storage=disk.img dist/block_test.hvt
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Memory map: 512 MB addressable:
Solo5:     unused @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1eefff)
Solo5:     rodata @ (0x1ef000 - 0x228fff)
Solo5:       data @ (0x229000 - 0x2dffff)
Solo5:       heap >= 0x2e0000 < stack < 0x20000000
2018-06-21 12:21:11 -00:00: INF [block] sectors = 100000
read_write=true
sector_size=512

2018-06-21 12:21:11 -00:00: ERR [block] Expecting error output from the following operation...
2018-06-21 12:21:11 -00:00: ERR [block] Expecting error output from the following operation...
2018-06-21 12:21:11 -00:00: ERR [block] Expecting error output from the following operation...
2018-06-21 12:21:11 -00:00: ERR [block] Expecting error output from the following operation...
2018-06-21 12:21:11 -00:00: INF [block] Test sequence finished

2018-06-21 12:21:11 -00:00: INF [block] Total tests started: 10

2018-06-21 12:21:11 -00:00: INF [block] Total tests passed:  10

2018-06-21 12:21:11 -00:00: INF [block] Total tests failed:  0

Solo5: solo5_exit(0) called
```

### Step 3: Key/value stores

The earlier block device example shows how very low-level access can work. Now
let's move up to a more familiar abstraction: a key/value store that can
retrieve buffers from string keys. This is essential for many common uses such
as retrieving configuration data or website HTML and images.

The
[device-usage/kv_ro](https://github.com/mirage/mirage-skeleton/tree/master/device-usage/kv_ro) directory
in `mirage-skeleton` contains a simple key/value store example. The
subdirectory `t/` contains a few files, one of which the unikernel
will compare against a known constant.

The `config.ml` might look familiar after the earlier block and console
examples:

```ocaml
open Mirage

let disk = generic_kv_ro "t"

let main =
  main
    "Unikernel.Main" (kv_ro @-> job)

let () =
  register "kv_ro" [main $ disk]
```

We construct the `kv_ro` device `disk` by using the `generic_kv_ro`
function. This takes a single directory as its argument, and will do its best
to provide the content of that directory to the unikernel by whatever means
make sense given the target provided at configuration time. The best choice might be an
implementation that calls functions from OCaml's `Unix` module (referred to as
`direct` by the `mirage` tool), or perhaps a function
that transforms an entire directory into a static ML file that can expose
the file contents directly from memory (called `crunch`). `crunch` removes the need to have
an external block device entirely and is very convenient indeed for small files.

Using `generic_kv_ro` in your `config.ml` causes Mirage to automatically create a
configuration key, `kv_ro`, which you can use to request a specific implementation
of the key-value store's implementation.  To see documentation, try:

```bash
$ cd device-usage/kv_ro
$ mirage help configure
```

Under the "UNIKERNEL PARAMETERS" section, you should see:

```bash
       --kv_ro=KV_RO (absent=crunch)
           Use a fat, archive, crunch or direct pass-through implementation
           for the unikernel.
```

More documentation is available at [the `Mirage` module documentation for generic_kv_ro](http://mirage.github.io/mirage/mirage/Mirage/index.html#val-generic_kv_ro).

Let's try a few different kinds of key-value implementations.  First, we'll build a Unix version.  If we don't specify which kind of `kv_ro` we want, we'll get a `crunch` implementation, the contents of which we can see at `_build/default/static_t.ml`, the file being generated by `dune` rules described in `dune.build`:

```
$ cd device-usage/kv_ro
$ mirage configure -t unix
$ make depend
$ make
$ less _build/default/static_t.ml # the generated filesystem
$ dist/kv_ro
```

We can use the `direct` implementation with the Unix target as well:

```
$ cd device-usage/kv_ro
$ mirage configure -t unix --kv_ro=direct
$ make depend
$ make
$ dist/kv_ro
```

You may have noticed that, unlike with our `hello_key` example, the `kv_ro` key
can't be specified at runtime — it's only understood as an argument to `mirage configure`.  This is because the `kv_ro` implementation we choose influences the set of dependencies that are assembled and baked into the final product.  If we choose `direct`, we'll get a different set of software than if we choose `crunch`.  In either case, no code that isn't required will be included in the final product.

You should now be seeing the power of the MirageOS configuration tool: We have
built several applications that use fairly complex concepts such as filesystems
and block devices that are independent of the implementations (by virtue of our
application logic being a functor), and then are able to assemble several
combinations of unikernels via relatively simple configuration files and options
passed at compile time and runtime.

### Step 4: Networking

There are several ways that we might want to configure our network for a Mirage
application:

* On Unix, it's convenient to use the standard kernel socket API for developing
  higher level protocols (such
  as [HTTP](http://github.com/mirage/ocaml-cohttp)). These run over TCP or UDP
  and so sockets work just fine.
* When we want finer control over the network stack, or simply to test the fully-OCaml
  network implementation , we can use a userspace device facility such as the
  common Unix [tuntap](http://en.wikipedia.org/wiki/TUN/TAP) to parse Ethernet
  frames from userspace. This requires additional configuration to assign IP
  addresses, and possibly configure a network bridge to let the unikernel talk
  to the outside world.
* Once the unikernel works under Unix with the
  direct [OCaml TCP/IP stack](https://github.com/mirage/mirage-tcpip),
  recompiling it for a unikernel target like `xen`, `hvt`, or `virtio` shouldn't
  result in a change in behavior.

All of this can be manipulated via command-line arguments or environment variables,
just as we configured the key-value store in the previous example.  The example in
the `device-usage/network` directory of `mirage-skeleton` is illustrative:

```ocaml
open Mirage

let port =
  let doc = Key.Arg.info ~doc:"The TCP port on which to listen for incoming connections." ["port"] in
  Key.(create "port" Arg.(opt int 8080 doc))

let main = main ~keys:[Key.abstract port] "Unikernel.Main" (stackv4 @-> job)

let stack = generic_stackv4 default_network

let () =
  register "network" [
    main $ stack
  ]
```

We have a custom configuration key defining which TCP port to listen for connections on.
The network device is derived from `default_network`, a function provided by Mirage which will choose a reasonable default based on the target the user chooses to pass to `mirage configure` - just like the reasonable default provided by `generic_kv_ro` in the previous example.

`generic_stackv4` attempts to build a sensible network stack on top of the physical interface given by `default_network`.  There are quite a few configuration keys exposed when `generic_stackv4` is given related to networking configuration. For a full list, try `mirage help configure` in the `device-usage/network` directory.

#### Unix / Socket networking

Let's get the network stack compiling using the standard Unix sockets APIs
first.

```bash
$ cd device-usage/network
$ mirage configure -t unix --net socket
$ make depend
$ make
$ dist/network
```

This Unix application is now listening on TCP port 8080,
and will print to the console information about data received.
Let's try talking to it using
the commonly available _netcat_ `nc(1)` utility. From a different console
execute:

```
$ echo -n hello tcp world | nc -nw1 127.0.0.1 8080
```

You should see log messages documenting your connection from 127.0.0.1
in the console running `dist/network`.  You may have noticed that some
information that you may have expected to see after looking at `unikernel.ml`
isn't being output.  That's because we haven't specified the log level for
`dist/network`, and it defaults to `info`.  Some of the output for this application
is sent with the log level set to `debug`, so to see it, we need to run `dist/network`
with a higher log level for all logs:

```
$ dist/network -l "*:debug"
```

The program will then output the debug-level logs, which include the content of any messages it reads.  Here's an example of what you might see:

```
$ dist/network -l "*:debug"
2017-02-10 17:23:24 +02:00: INF [tcpip-stack-socket] Manager: connect
2017-02-10 17:23:24 +02:00: INF [tcpip-stack-socket] Manager: configuring
2017-02-10 17:23:27 +02:00: INF [application] new tcp connection from IP 127.0.0.1 on port 36358
2017-02-10 17:23:27 +02:00: DBG [application] read: 15 bytes:
hello tcp world
```

#### Unix / MirageOS Stack with DHCP

Next, let's try using the direct MirageOS network stack.  It will be necessary to run these programs with `sudo` or as the root user, as they need direct access to a network device.  We won't be able to contact them via the loopback interface on `127.0.0.1` either — the stack will need to either obtain IP address information via DHCP, or it can be configured directly via the `--ipv4` configuration key.

To configure via DHCP:

```bash
$ cd device-usage/network
$ mirage configure -t unix --dhcp true --net direct
$ make depend
$ make
$ sudo dist/network -l "*:debug"
```

Hopefully, the application will successfully receive its network configuration.
Once the program has completed the lease transaction, it will log the configuration
information, and you'll be able to contact it as before via its own IP.

#### Unix / MirageOS Stack with static IP addresses

By default, if we do not use DHCP with a `direct` network stack, Mirage will
configure the stack to use an address of `10.0.0.2`.  You can specify a different address
with the `--ipv4` configuration key.  Depending on whether you've
configured with `-t macosx` or `-t unix`, the logic for contacting the application
from another terminal will be different.

For unix:
Verify that you have an existing `tap0` interface by reviewing `$ sudo ip link
show`; if you do not, load the tuntap kernel module (`$ sudo modprobe tun`) and
create a `tap0` interface owned by you (`$ sudo tunctl -u $USER -t tap0`). Bring
`tap0` up using `$ sudo ifconfig tap0 10.0.0.1 up`, then:

```bash
$ cd device-usage/network
$ mirage configure -t unix --dhcp false --net direct
$ make depend
$ make
$ sudo dist/network -l "*:debug"
```

For macosx:

```
(* TODO! *)
```

Now you should be able to ping the unikernel's interface:

```bash
$ ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=38 time=0.527 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=38 time=0.367 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=38 time=0.291 ms
^C
--- 10.0.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 0.291/0.395/0.527/0.098 ms
```

Finally, you can then execute the same `nc(1)` commands as before (modulo the
target IP address of course!) to interact with the running unikernel:

```
$ echo -n hello tcp world | nc -nw1 10.0.0.2 8080
```

And you will see the same output in the unikernel's terminal:

```
read: 15 "hello tcp world"
```

#### Hvt

Let's make a network-enabled unikernel with `hvt`!  The IP configuration should be similar to what you've set up in the previous examples, but instead of `-t unix` or `-t macosx`, build with a `hvt` target.  If you need to specify a static IP address, remember that it should go at the end of the command in which you invoke `solo5-hvt`, just like the argument to `hello` in the `hello-key` example.

```
$ cd device-usage/network
$ mirage configure -t hvt --dhcp true # for environments where DHCP works
$ make depend
$ make
$ solo5-hvt --net:service=tap100 -- dist/network.hvt --ipv4=10.0.0.10/24
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Memory map: 512 MB addressable:
Solo5:     unused @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x213fff)
Solo5:     rodata @ (0x214000 - 0x255fff)
Solo5:       data @ (0x256000 - 0x331fff)
Solo5:       heap >= 0x332000 < stack < 0x20000000
2018-06-21 12:24:46 -00:00: INF [netif] Plugging into 0 with mac 3a:40:76:41:5d:b0
2018-06-21 12:24:46 -00:00: INF [ethif] Connected Ethernet interface 3a:40:76:41:5d:b0
2018-06-21 12:24:46 -00:00: INF [arpv4] Connected arpv4 device on 3a:40:76:41:5d:b0
2018-06-21 12:24:46 -00:00: INF [udp] UDP interface connected on 10.0.0.10
2018-06-21 12:24:46 -00:00: INF [tcpip-stack-direct] stack assembled: mac=3a:40:76:41:5d:b0,ip=10.0.0.10
```
See the Solo5 documentation on [running Solo5-based unikernels](https://github.com/Solo5/solo5/blob/v0.6.3/docs/building.md#running-solo5-based-unikernels) for details on how to set up the `tap100` interface used above for hvt networking.

### What's Next?

There are a number of other examples in `device-usage/` which show some simple invocations
of various devices like consoles and clocks.  You may also be
interested in the `applications/` directory of the `mirage-skeleton`
repository, which contains examples that use multiple devices to build nontrivial
applications, like DNS, DHCP, and HTTPS servers.

The real MirageOS website (which is itself a unikernel) may also be of
interest to you!  Documentation is available at [mirage-www](/wiki/mirage-www),
and the source code is published [in a public GitHub repository](https://github.com/mirage/mirage-www).
