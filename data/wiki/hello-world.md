---
updated: 2024-04-19
author:
  name: Richard Mortier
  uri: http://mort.io/
  email: mort@cantab.net
subject: Hello MirageOS World
permalink: hello-world
---


First, make sure you have followed the [installation instructions](/wiki/install)
to get a working MirageOS installation. The examples below are in
the [mirage-skeleton](http://github.com/mirage/mirage-skeleton) repository.
Begin by cloning and changing directory to it:

```bash skip
$ git clone https://github.com/mirage/mirage-skeleton.git
Cloning into 'mirage-skeleton'...
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
hope, fairly short.
Before we can build our `noop` unikernel, we must define its configuration
telling Mirage what jobs the unikernel is to run.
In this example we define a unikernel with zero jobs by passing the empty list.
We do this by writing a `config.ml` file:

```bash dir=files/mirage-skeleton
$ cat tutorial/noop/config.ml
let () = Mirage.register "noop" []
```

Finally, we declare the entry point to OCaml in the usual way (`let () = ...`),
`register`ing our unikernel entry points (in this case the empty list) and with a
name of the unikernel(`"noop"` in this case) we will build.

Building our unikernel is then simply a matter of:

1. Evaluating its configuration:

    ```bash dir=files/mirage-skeleton
    $ cd tutorial/noop
    $ mirage configure -t unix
    ```

    This step will generate a number of build configuration files, including a
    `Makefile` defining targets that we will use in the next step.

2. Installing dependencies:

    ```bash dir=files/mirage-skeleton/tutorial/noop
    $ make depends
    ```

    The `depends` target in the generated `Makefile` will run commands to:

    - Resolve the unikernel dependencies and generates a _lockfile_.
    - Install the build tools in the opam switch.
    - install external dependencies of the unikernel dependencies (another set of
      potential build tools).
    - Fetch unikernel dependencies.

    NOTE: while performing the _lock_ step, an additional repository
    <https://github.com/mirage/opam-overlays.git> is added in your opam switch.
    This repository contains packages that have been changed to use the _dune_ build
    system. The `--extra-repo` argument in `mirage configure` changes the additional
    repository to use. `--no-extra-repo` can be used to disable the extra repository,
    but the _lock_ step might fail because of dependencies that are not using the
    _dune_ build system.

3. Compiling:

    ```bash dir=files/mirage-skeleton/tutorial/noop
    $ make build
    ```

You can combine steps (2) and (3) by running the default `make` target.

Once all the dependencies are installed, you can also just run `dune build`
to build the unikernel (no need to call the slow `make depends` every time!):

```bash dir=files/mirage-skeleton/tutorial/noop
$ mirage configure -t unix
$ dune build
```

Because we set the configuration target to be Unix (the `-t unix` argument to
the `mirage configure` command), the result is a standard Unix ELF located in
`dist/noop` that can be executed:

```bash dir=files/mirage-skeleton/tutorial/noop
$ dist/noop
$ echo $?
0
```

Congratulations! You've just built and run your very first unikernel!

### Step 1: Hello World!

Except for the noop example above, all unikernels have at least one
job.  A job is a module with a `start` function as entrypoint that
performs some task.  Most jobs will depend on some system devices
which they use to interact with the environment.  This tutorial will
cover examples timer devices, key-value stores, block devies and
network interfaces.  In this section, we illustrate how to define a
unikernel with a job that depends on a timer device.

Mirage unikernels use *functors* to specify abstract device dependencies that
are not dependent on the particular details of an environment.  In OCaml, a
*functor* is a module that takes other modules as parameters.  Functors are used
widely throughout Mirage and we will explain the basic idea and provide examples
in this tutorial. For a proper introduction into the core concepts, you may see
[Real World OCaml, Ch.9][rwo-9] (and also [Ch.10, First-Class Modules][rwo-10]).

[rwo-9]: https://dev.realworldocaml.org/functors.html
[rwo-10]: https://dev.realworldocaml.org/first-class-modules.html

Functors act as functions from modules to modules. They allow us to pass
dependencies into a unikernel, so that the program running inside can interact
with the environment (read files, send packets, etc) without needing to care
whether it will eventually be built to target Unix, Xen, KVM, or something else
entirely. The modules that are passed into the unikernel in this way must
satisfy type signatures that are specified when the unikernel `job` value is
created in the `config.ml` file.

In this section, we present a simple example of a unikernel that uses a functor
to depend on a device for reading the system's time.  We will build and run the
MirageOS "Hello World" unikernel that prints a log message with the word
`hello`, sleeps for 1 second, and repeats this 4 times before finally
terminating.  The output will look like this:

```
2017-02-08 09:54:44 -01:00: INF [application] hello
2017-02-08 09:54:45 -01:00: INF [application] hello
2017-02-08 09:54:46 -01:00: INF [application] hello
2017-02-08 09:54:47 -01:00: INF [application] hello
```

Let's start by looking at the code:

```bash dir=files/mirage-skeleton
$ cat tutorial/hello/unikernel.ml
open Lwt.Infix

module Hello (Time : Mirage_time.S) = struct
  let start _time =
    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
          Logs.info (fun f -> f "hello");
          Time.sleep_ns (Duration.of_sec 1) >>= fun () -> loop (n - 1)
    in
    loop 4
end
```

We define a main `Hello` module parameterised by a module `Time`, of type
`Mirage_time.S`. The `Time` module provides the functionality enabling us to
interact with the environment clock.
Our `start` function, which is the entrypoint of the job, also takes a parameter
`_time` (an instance of a `time` which is ignored). This parameterization of a
unikernel's main module and its `start` function is the basic structure required
to make a MirageOS unikernel that can be built to run on any supported
environment, rather than a standard OCaml POSIX application.

The module type for our `Time` module, `Mirage_time.S`, is defined in an
external package [mirage-time](https://github.com/mirage/mirage-time).  The name
pattern `Foo.S` for "the **s**ignature of `Foo` modules" is a common OCaml
convention (comparable to naming the most-used type in a module `t`).  There are
many packages defining module types for use in Mirage.

The concrete implementation of `Time` will be supplied at compile time,
depending on the target that you are compiling for. This calls for some
additional configuration  in `config.ml`, so let's take a look:

```bash dir=files/mirage-skeleton
$ cat tutorial/hello/config.ml
open Mirage

let main =
  main "Unikernel.Hello" (time @-> job) ~packages:[ package "duration" ]

let () = register "hello" [ main $ default_time ]
```

First we open the `Mirage` module to save on typing.  Next, we define
a value `main`.  This name is only a convention, and you should feel
free to change it if you wish.  `main` calls the `Mirage.main`
function, passing two parameters.  The first is a string declaring the
module name that contains our entry point — in this case, standard
OCaml compilation behaviour means that the `unikernel.ml` file
produces a module named `Unikernel`.  Again, there's nothing special
about this name, and if you want to use something else here, simply
rename `unikernel.ml` accordingly.  The `@->` combinator is used to
add a device driver to the list of functor arguments in the job
definition and the final value of this combinator should always be a
`job`.  The named argument `~packages` defines extra OCaml package
dependencies that the job depends on.  In this case we depend on the
`duration` library for converting from seconds to nanoseconds.

Notice that we refer to the module name as a string (`"Unikernel.Hello"`) when
calling `main`, instead of directly as an OCaml value. The `mirage` command-line
tool evaluates this configuration file at build time and outputs a `main.ml`
that has the concrete values filled in for you depending on which target you
selected during configuration (e.g. Unix or Xen).

MirageOS mirrors the unikernel model on Unix as far as possible: your application is
built as a unikernel which needs to be instantiated and run whether on Unix or
on a hypervisor backend like Xen or KVM. When your unikernel is run, it starts
much like a conventional OS does when run as a virtual machine, and so it must
be passed references to devices such as the console, network interfaces and
block devices on startup.

In general, a `config.ml` file is a normal OCaml module that calls `register` to
register one or more jobs, each of which represent a process (with a start/stop
lifecycle). Each job depends on some device drivers; all the
available device drivers are defined in the `Mirage` module (see [the Mirage
module documentation](http://mirage.github.io/mirage/mirage/index.html)).

In this case, this simple `hello world` example requires some notion of time,
so we register a single `job` consisting of the `Unikernel.Hello` module
(and, implicitly its `start` function) and pass it references to a
timer.

When we call `Mirage.main` we specify the devices our `Unikernel.Hello` program
depends on (a `time` device) and when we call `Mirage.register`, we provide
instructions about how to satisfy those dependencies (it will be given a
`default_time` device, suitable for the target it's eventually built for).

#### Building a Unix binary

Let's test all of this by first configuring, building, and running the resulting
unikernel under Unix:

```bash dir=files/mirage-skeleton
$ cd tutorial/hello
```

```bash dir=files/mirage-skeleton/tutorial/hello
$ mirage configure -t unix
```

`mirage configure` generates a `Makefile` with all the build rules included from
evaluating the configuration file and a `mirage` directory. The `mirage`
directory includes generated files to run and build your program, including

- a `main.ml` that represents the entry point of your unikernel,
- and a `hello-unix.opam` file with a list of the packages necessary to build the
  unikernel.

Install the dependencies with

```bash skip
$ make depends
```

And build the unikernel with

```bash dir=files/mirage-skeleton/tutorial/hello
$ dune build
```

Our Unix binary is built as `dist/hello`. Note that `make` simply
calls `mirage build` which itself turns into a simple `dune build` command. If
you are  familiar with `dune` it is possible to inspect the build rules for the
unikernel generated in `dune.build`.

To run your application, execute the binary — and observe the exciting log
messages that our loop is generating:

```bash dir=files/mirage-skeleton/tutorial/hello,non-deterministic=output
$ dist/hello
2024-04-14T14:15:22+02:00: [INFO] [application] hello
2024-04-14T14:15:23+02:00: [INFO] [application] hello
2024-04-14T14:15:24+02:00: [INFO] [application] hello
2024-04-14T14:15:25+02:00: [INFO] [application] hello
```

#### Building for Another Backend

**Note**: The following sections of this tutorial use the
[Solo5](https://github.com/Solo5/solo5/tree/v0.7.0)-based `hvt` backend as an
example. This backend is supported on Linux, FreeBSD, and OpenBSD systems with
hardware virtualization. Please see the Solo5 documentation for the support
[status](https://github.com/Solo5/solo5/blob/v0.7.0/docs/building.md#supported-targets)
of further backends such as `spt` (for deployment on Linux using a strict
seccomp sandbox), `virtio` (for deployment on e.g. Google Compute Engine) and
`muen` (for deployment on the [Muen Separation Kernel](https://muen.sk)). On
supported platforms, Solo5 will be installed automatically when `make depends`
is run.

To build a Solo5-based unikernel that will run on a host system with
hardware virtualization, re-run `mirage configure` and ask for the
`hvt` target instead of `unix`.

```bash dir=files/mirage-skeleton
$ cd tutorial/hello
```

```bash dir=files/mirage-skeleton/tutorial/hello
$ mirage configure -t hvt
```

You can then install its dependencies and build it with:

```bash skip
$ make depends
$ dune build
```

*Everything* else remains the same! The set of dependencies required to build,
the generated `main.ml`, and the generated `Makefile` have changed, but since
the source code of your application was parameterised over the `Time` module, it
doesn't matter — you do not need to make any changes for your code to run when
linked against the Solo5 console driver instead of Unix.

When you build the `hvt` version, you'll see a new artifact in the `dist`
directory: a file called `hello.hvt`.  Additionally, a `solo5-hvt` binary will
be installed by OPAM on your `$PATH`. This binary is a _tender_, responsible for
loading your unikernel, attaching to host system devices and running it. To try
running `hello.hvt`, pass it as an argument to `solo5-hvt`:

```bash skip
$ solo5-hvt tutorial/hello/dist/hello.hvt
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

We get some additional output from the initialization of the unikernel
and its successful boot, then we see our expected output, and Solo5's
report of the application's successful completion.

#### Runtime Arguments

It's very common to pass additional runtime information to a program
via command-line options or arguments.  But a unikernel doesn't have
access to a command line, so how can we pass some information to it
at runtime?

Mirage provides a nice abstraction for this in the form of
`runtime_args`.

We declare that our unikernel will receive a runtime argument `hello`,
using the function `runtime_arg`.  Once we've created our list of
runtime arguments, we pass it to the unikernel by passing it to
`Mirage.main` in the `runtime_args` parameter.

For an example, let's have a look at `hello-key`:

```bash dir=files/mirage-skeleton
$ cat tutorial/hello-key/config.ml
open Mirage

let packages = [ package "duration" ]
let main = main ~packages "Unikernel.Hello" (time @-> job)
let () = register "hello-key" [ main $ default_time ]
```

Below, the function `hello` (which uses the `cmdliner` package) declares the
type of the runtime argument as `string` and sets a default value of `"Hello World!"`,
for the case that the argument is not provided at runtime.  See [the Cmdliner.Arg module
documentation](https://ocaml.org/p/cmdliner/latest/doc/Cmdliner/Arg/index.html)
for more details.

The function [Mirage_runtime.register_arg](https://ocaml.org/p/mirage-runtime/latest/doc/Mirage_runtime/index.html#val-register_arg)
registers the `'a Cmdliner.Term.t` as a runtime argument to the unikernel. It
returns a function (`unit -> 'a`), which returns the value passed via `--hello`
at boot time. The evaluation of runtime arguments is done just before `start`.

```bash dir=files/mirage-skeleton
$ cat tutorial/hello-key/unikernel.ml
open Lwt.Infix
open Cmdliner

let hello =
  let doc = Arg.info ~doc:"How to say hello." [ "hello" ] in
  Mirage_runtime.register_arg Arg.(value & opt string "Hello World!" doc)

module Hello (Time : Mirage_time.S) = struct
  let start _time =
    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
          Logs.info (fun f -> f "%s" (hello ()));
          Time.sleep_ns (Duration.of_sec 1) >>= fun () -> loop (n - 1)
    in
    loop 4
end
```

Let's configure the example for Unix and build it (do not forget to call `make
depends` if you have not done it yet for this tutorial):

```bash dir=files/mirage-skeleton/
$ cd tutorial/hello-key
```

```bash dir=files/mirage-skeleton/tutorial/hello-key
$ mirage configure -t unix
$ dune build
```

When the target is Unix, Mirage will use an implementation for
runtime arguments that looks at the contents of `OS.Env.argv`. In
other words, it looks directly at the command line that was used to
invoke the program.  If we call `hello` with no arguments, the default
value is used:

```bash dir=files/mirage-skeleton/tutorial/hello-key,non-deterministic=output
$ dist/hello-key
2024-04-17T16:13:44+02:00: [INFO] [application] Hello World!
2024-04-17T16:13:45+02:00: [INFO] [application] Hello World!
2024-04-17T16:13:46+02:00: [INFO] [application] Hello World!
2024-04-17T16:13:47+02:00: [INFO] [application] Hello World!
```

but we can ask for something else:

```bash dir=files/mirage-skeleton,non-deterministic=output
$ tutorial/hello-key/dist/hello-key --hello="Bonjour!"
2024-04-17T16:13:48+02:00: [INFO] [application] Bonjour!
2024-04-17T16:13:49+02:00: [INFO] [application] Bonjour!
2024-04-17T16:13:50+02:00: [INFO] [application] Bonjour!
2024-04-17T16:13:51+02:00: [INFO] [application] Bonjour!
```

When the target is Unix, it's also possible to get useful hints by
calling the generated program with `--help`.

When configured for non-Unix backends, other mechanisms are used to
pass the runtime information to the unikernel.  `solo5-hvt`, which we
used to run `hello.hvt` in the non-keyed example, will pass runtime
arguments specified on the command line to the unikernel when invoked:

``` skip
$ cd tutorial/hello-key
$ mirage configure -t hvt
$ dune build
$ solo5-hvt -- dist/hello-key.hvt --hello="Hola!"
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
onto local files.
On solo5 on the other hand, the block devices are mapped to alphanumeric names.

The solo5 tender then at runtime maps the names onto local files.  The
`config.ml` for the block example contains some logic for handling
this difference.  The expression `if_impl Key.is_solo5 (block_of_file
"storage") (block_of_file "disk.img")` detects if we are on the solo5
target.  If so, we emit a block device backed by the name `storage`.
Otherwise, we emit a block device backed by the file `disk.img`.
Remember, the name has to be alphanumeric on Solo5, so the dot in
`disk.img` will not work on Solo5.

```ocaml file=files/mirage-skeleton/device-usage/block/config.ml
open Mirage

let main = main "Unikernel.Main" (block @-> job)

let img =
  if_impl Key.is_solo5 (block_of_file "storage") (block_of_file "disk.img")

let () = register "block_test" [ main $ img ]
```

The `main` binding looks much like the earlier `hello` example, except for the
addition of a `block` device in the list..

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

```bash dir=files/mirage-skeleton
$ cd device-usage/block
```

And configure and build the project (do not forget to use `make depends` if you
have not done so already):

```bash dir=files/mirage-skeleton/device-usage/block
$ mirage configure -t unix
$ dune build
```

Now, with the unikernel built we can run it.
However, the unikernel expects a block device.
We can create a disk image of all zeroes before we run the unikernel:

```bash dir=files/mirage-skeleton/device-usage/block,non-deterministic=output
$ dd if=/dev/zero of=disk.img count=100000 # only needed once
100000+0 records in
100000+0 records out
51200000 bytes transferred in 0.216251 secs (236761911 bytes/sec)
$ ./dist/block_test
2024-04-17T16:13:53+02:00: [INFO] [block] { Mirage_block.read_write = true;
                                            sector_size = 512;
                                            size_sectors = 100000L }
reading 1 sectors at 100000
reading 12 sectors at 99989
2024-04-17T16:13:53+02:00: [INFO] [block] Test sequence finished
2024-04-17T16:13:53+02:00: [INFO] [block] Total tests started: 10
2024-04-17T16:13:53+02:00: [INFO] [block] Total tests passed:  10
2024-04-17T16:13:53+02:00: [INFO] [block] Total tests failed:  0
```

`block_test` will write a series
of patterns to the block device and read them back to check that they are the
same (the logic for this is in `unikernel.ml` within the `Block_test` module).

We can build this example for another backend too:

```bash skip
$ mirage configure -t hvt
$ dune build
```

Now we just need to boot the unikernel with `solo5-hvt` as before. We should see
the same output after the VM boot preamble, but now MirageOS is linked against the
Solo5 [block device driver](https://github.com/mirage/mirage-block-solo5) and is
mapping the unikernel's block requests directly through to it, rather than
relying on the host OS (the Linux or FreeBSD kernel).

If we tell `solo5-hvt` where the disk image for the name `storage` is, it will provide that disk image to the unikernel:

```bash skip
$ solo5-hvt --block:storage=disk.img ./dist/block_test.hvt
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Bindings version v0.7.5
Solo5: Memory map: 512 MB addressable:
Solo5:   reserved @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1defff)
Solo5:     rodata @ (0x1df000 - 0x214fff)
Solo5:       data @ (0x215000 - 0x2c1fff)
Solo5:       heap >= 0x2c2000 < stack < 0x20000000
2023-06-27 10:27:24 -00:00: INF [block] { Mirage_block.read_write = true; sector_size = 512;
              size_sectors = 100000L }
reading 1 sectors at 100000
reading 12 sectors at 99989
2023-06-27 10:27:24 -00:00: INF [block] Test sequence finished
2023-06-27 10:27:24 -00:00: INF [block] Total tests started: 10
2023-06-27 10:27:24 -00:00: INF [block] Total tests passed:  10
2023-06-27 10:27:24 -00:00: INF [block] Total tests failed:  0
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

```ocaml file=files/mirage-skeleton/device-usage/kv_ro/config.ml
open Mirage

let disk = generic_kv_ro "t"
let main = main "Unikernel.Main" (kv_ro @-> job)
let () = register "kv_ro" [ main $ disk ]
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

```bash skip
$ cd device-usage/kv_ro
$ mirage help configure
```

Under the "UNIKERNEL PARAMETERS" section, you should see:

```
       --kv_ro=KV_RO (absent=crunch)
           Use a fat, archive, crunch or direct pass-through implementation
           for the unikernel.
```

More documentation is available at [the `Mirage` module documentation for generic_kv_ro](http://mirage.github.io/mirage/mirage/Mirage/index.html#val-generic_kv_ro).

Let's try a few different kinds of key-value implementations.  First,
we'll build a Unix version.  If we don't specify which kind of `kv_ro`
we want, we'll get a `crunch` implementation, the contents of which we
can see at `_build/default/static_t.ml`, the file being generated by
`dune` rules described in `dune.build`:

```bash dir=files/mirage-skeleton/device-usage/kv_ro
$ mirage configure -t unix
$ dune build
Generating Static_t.ml
Generating Static_t.mli
$ ls _build/default/Static_t.ml # the generated filesystem
_build/default/Static_t.ml
```

And you can check this runs as expected:
```bash dir=files/mirage-skeleton/device-usage/kv_ro,non-deterministic=output
$ dist/kv_ro
2024-04-17T16:13:54+02:00: [INFO] [application] Contents of extremely secret vital storage confirmed!
```

We can use the `direct` implementation with the Unix target as well:

```bash dir=files/mirage-skeleton/device-usage/kv_ro
$ mirage configure -t unix --kv_ro=direct
$ dune build
```

```bash dir=files/mirage-skeleton/device-usage/kv_ro,non-deterministic=output
$ dist/kv_ro
2024-04-17T16:13:55+02:00: [INFO] [application] Contents of extremely secret vital storage confirmed!
```

You may have noticed that, unlike with our `hello_key` example, the
`kv_ro` key can't be specified at runtime — it's only understood as an
argument to `mirage configure`.  This is because the `kv_ro`
implementation we choose influences the set of dependencies that are
assembled and baked into the final product.  If we choose `direct`,
we'll get a different set of software than if we choose `crunch`.  In
either case, no code that isn't required will be included in the final
product.

You should now be seeing the power of the MirageOS configuration tool: We have
built several applications that use fairly complex concepts such as filesystems
and block devices that are independent of the implementations (by virtue of our
application logic being a functor), and then are able to assemble several
combinations of unikernels via relatively simple configuration files and options
passed at compile time and runtime.

### Step 4: Networking

You built multiple MirageOS unikernels, and at some point you may want them to
communicate with the external world. We use network for that.

Please note this document only explains how to communicate from your host system
to your unikernel. For having your unikernel being able to communicate with the
entire Internet, you will need to setup firewalling
([NAT](https://en.wikipedia.org/wiki/Network_address_translation)).

For MirageOS unikernels running as Unix application, we have the option to use
the host system stack (Unix sockets API, `--net=host`). For any other target,
we must use the OCaml network stack. On Unix, we can also use the OCaml network
stack by utilizing a [tuntap](http://en.wikipedia.org/wiki/TUN/TAP) interface
(`--net=ocaml`).

Which of the two network stacks to use can be specified via command-line arguments,
just as we configured the key-value store in the previous example.  The example in
the `device-usage/network` directory of
[`mirage-skeleton`](http://github.com/mirage/mirage-skeleton) is illustrative:

```ocaml file=files/mirage-skeleton/device-usage/network/config.ml
open Mirage

let main = main "Unikernel.Main" (stackv4v6 @-> job)
let stack = generic_stackv4v6 default_network
let () = register "network" [ main $ stack ]
```

The network device is derived from
`default_network`, a function provided by Mirage which will choose a
default based on the target the user chooses to pass to
`mirage configure` - just like the default provided by
`generic_kv_ro` in the previous example.

`generic_stackv4v6` builds a network stack on top of
the physical interface given by `default_network`.

#### Unix with host system (socket) networking

Let's get the network stack compiling using the Unix target and using the host
system network stack first. This is the default when using the Unix target -
the `--net socket` is superfluous.

```bash dir=files/mirage-skeleton
$ cd device-usage/network
```

And, as previously, configure and build the unikernel (if needed, use
`make depends` to install the required dependency):

```bash dir=files/mirage-skeleton/device-usage/network
$ mirage configure -t unix --net socket
$ dune build
```

And run it:
```bash skip
$ dist/network
```

This Unix application is now listening on TCP port 8080,
and will print to the console information about data received.
Let's try talking to it using
the commonly available _netcat_ `nc(1)` utility. From a different console
execute:

```bash skip
$ echo -n hello tcp world | nc -nw1 127.0.0.1 8080
```

You should see log messages documenting your connection from 127.0.0.1
in the console running `dist/network`.  You may have noticed that some
information that you may have expected to see after looking at `unikernel.ml`
isn't being output.  That's because we haven't specified the log level for
`dist/network`, and it defaults to `info`.  Some of the output for this application
is sent with the log level set to `debug`, so to see it, we need to run `dist/network`
with a higher log level for all logs:

```bash skip
$ dist/network -l "*:debug"
```

The program will then output the debug-level logs, which include the
content of any messages it reads.  Here's an example of what you might
see:

```bash skip
$ dist/network -l "*:debug"
2017-02-10 17:23:24 +02:00: INF [tcpip-stack-socket] Manager: connect
2017-02-10 17:23:24 +02:00: INF [tcpip-stack-socket] Manager: configuring
2017-02-10 17:23:27 +02:00: INF [application] new tcp connection from IP 127.0.0.1 on port 36358
2017-02-10 17:23:27 +02:00: DBG [application] read: 15 bytes:
hello tcp world
```

#### Unix with the OCaml network stack

Next, let's try using the OCaml network stack with the Unix target. This is done
by passing `--net direct` to `mirage configure`. It will be
necessary to run these programs with `sudo` (or `doas`) or as the root user, as
they need direct access to a `tap` network device. The IPv4 address defaults to
10.0.0.2, and can be configured via the `--ipv4=10.0.42.2/24` runtime argument.

```bash dir=files/mirage-skeleton/device-usage/network
$ mirage configure -t unix --net direct
$ dune build
```

You need to construct a tap interface, and configure an IP address in the same
network segment on your host system to communicate with the unikernel:

```bash skip
$ sudo modprobe tun
$ sudo tunctl -u $USER -t tap0
$ sudo ifconfig tap0 10.0.0.1 up
```

And run it:
```bash skip
$ sudo dist/network -l "*:debug"
```

This will output once it successfully started up that it constructed the TCP/IP
stack successfully.

You are now able to communicate to the unikernel - via control messages (ICMP),
and also netcast, as shown before.

Now you should be able to ping the unikernel's interface:

```bash skip
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
target IP address) to interact with the running unikernel:

```bash skip
$ echo -n hello tcp world | nc -nw1 10.0.0.2 8080
```

And you will see the same output in the unikernel's terminal:

```
read: 15 "hello tcp world"
```

#### Hvt

Let's make a network-enabled unikernel with `hvt`!  The IP
configuration should be similar to what you've set up in the previous
examples, but instead of `-t unix` or `-t macosx`, build with a `hvt`
target.  If you need to specify a static IP address, remember that it
should go at the end of the command in which you invoke `solo5-hvt`,
just like the argument to `hello` in the `hello-key` example.

```bash skip
$ cd device-usage/network
$ mirage configure -t hvt
$ make depends
$ make build
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

See the Solo5 documentation on [running Solo5-based
unikernels](https://github.com/Solo5/solo5/blob/v0.6.3/docs/building.md#running-solo5-based-unikernels)
for details on how to set up the `tap100` interface used above for hvt
networking.

### What's Next?

To have your unikernel being able to communicate with the entire Internet, you
will need to setup a firewall
(and [NAT](https://en.wikipedia.org/wiki/Network_address_translation)).

The MirageOS network stack supports
[DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol), have
a look into `--dhcp true` if you're interested.

There are a number of other examples in `device-usage/` which show
some simple invocations of various devices like consoles and clocks.
You may also be interested in the `applications/` directory of the
`mirage-skeleton` repository, which contains examples that use
multiple devices to build nontrivial applications, like DNS, DHCP, and
HTTPS servers.

The real MirageOS website (which is itself a unikernel) may also be of
interest to you!  Documentation is available at
[mirage-www](/wiki/mirage-www), and the source code is published [in a
public GitHub repository](https://github.com/mirage/mirage-www).
