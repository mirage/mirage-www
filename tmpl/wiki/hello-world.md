First make sure you have followed the [installation instructions](/wiki/install)
to get a working MirageOS installation. The examples below are in
the [mirage-skeleton](http://github.com/mirage/mirage-skeleton) repository.
Begin by cloning and changing directory to it:

```
$ git clone git://github.com/mirage/mirage-skeleton.git
$ cd mirage-skeleton
```

The `mirage-skeleton` repository classifies its examples into three groups.
This document refers to unikernels in the `tutorial` directory.

**Note**: Before we begin, if you aren't familiar with the Lwt library (and the
`>>=` operator it provides), you may want to read at least the start of
the [Lwt tutorial](tutorial-lwt) first.

### Step 0: Doing Nothing!

Before we try and do anything complicated, let's do nothing briefly. That is,
let's build a unikernel that simply starts and then exits -- nothing else. The
code for this is, as you might hope, fairly short. First the unikernel itself:

```
$ cat tutorial/noop/unikernel.ml
let start =
  Lwt.return_unit
```

So this is a unikernel whose entry point (`start`) does nothing other than
return an `Lwt` thread that will evaluate to `unit`. Easy.

Before we can build even our `noop` unikernel, we must define its configuration.
That is, we need to tell Mirage what OCaml module contains the `start` entry
point. We do this by writing a `config.ml` file that sits next to our
`unikernel.ml` file (although you can name the file containing the configuration
something else, the `mirage` tool defaults to `config.ml`):

```
$ cat tutorial/noop/config.ml
open Mirage

let main =
  foreign "Unikernel" job

let () =
  register "noop" [main]
```

There's a little more going on here than in `unikernel.ml`. First we open the
`Mirage` module to save on typing. Next, we define a value `main` (named so by
convention because, at heart, some of us are still C programmers -- feel free to
call it something else if you wish!) which calls the `foreign` function passing
two parameters. The first is a string declaring the module name that contains
our entry point-- in this case, standard OCaml compilation behaviour means that
the `unikernel.ml` file produces a module named `Unikernel`. Again, there's
nothing special about this name -- if you want to sue something else here,
simply rename `unikernel.ml` accordingly.

The second parameter, `job`, is a bit more interesting. This declares the type
of our unikernel in terms of the devices (that is, things such as network
interfaces, network stacks, filesystems and so on) it requires to operate. As
this is a unikernel that does nothing, it needs no devices and so is simply
`job`.

Finally, we declare the entry point to OCaml in the usual way (`let () = ...`),
`register`ing our unikernel entry point (`main`) with a name (`"noop"` in this
case) to be used when we build our unikernel.

To build our unikernel is then simply a matter of evaluating its configuration:

```bash
$ cd tutorial/noop
/Users/mort/research/projects/mirage/src/mirage-skeleton/tutorial/noop
$ mirage configure -t unix
```

...installing dependencies:

```bash
$ make depend
opam pin add --no-action --yes mirage-unikernel-noop-unix .
[NOTE] Package mirage-unikernel-noop-unix is already path-pinned to /Users/mort/research/projects/mirage/src/mirage-skeleton/noop.
       This will erase any previous custom definition.
Proceed ? [Y/n] y

[mirage-unikernel-noop-unix] /Users/mort/research/projects/mirage/src/mirage-skeleton/noop/ synchronized
[mirage-unikernel-noop-unix] Installing new package description from /Users/mort/research/projects/mirage/src/mirage-skeleton/noop

opam depext --yes mirage-unikernel-noop-unix
# Detecting depexts using flags: x86_64 osx homebrew
# The following system packages are needed:
#  - camlp4
# All required OS packages found.
opam install --yes --deps-only mirage-unikernel-noop-unix

=-=- Synchronising pinned packages =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=  🐫
[mirage-unikernel-noop-unix] /Users/mort/research/projects/mirage/src/mirage-skeleton/noop/ already up-to-date
opam pin remove --no-action mirage-unikernel-noop-unix
mirage-unikernel-noop-unix is now unpinned from path /Users/mort/research/projects/mirage/src/mirage-skeleton/noop
```

...and compiling:

```bash
$ make
mirage build
ocamlfind ocamldep -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules main.ml > main.ml.depends
ocamlfind ocamldep -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules key_gen.ml > key_gen.ml.depends
ocamlfind ocamldep -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o key_gen.cmo key_gen.ml
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o main.cmo main.ml
ocamlfind ocamlopt -c -g -g -bin-annot -safe-string -principal -strict-sequence -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o key_gen.cmx key_gen.ml
ocamlfind ocamlopt -c -g -g -bin-annot -safe-string -principal -strict-sequence -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmx unikernel.ml
ocamlfind ocamlopt -c -g -g -bin-annot -safe-string -principal -strict-sequence -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o main.cmx main.ml
ocamlfind ocamlopt -g -linkpkg -g -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix key_gen.cmx unikernel.cmx main.cmx -o main.native
```

As we configured for UNIX (the `-t unix` argument to the `mirage configure`
command), the result is a standard UNIX ELF binary that can simply be executed:

```bash
$ ls -l noop
lrwxrwxr-x  1 mort  staff  18 Jan 12 12:11 noop@ -> _build/main.native
$ ls -l _build/main.native
-rwxrwxr-x  1 mort  staff  2690564 Jan 12 12:11 _build/main.native*
$ ./noop
$ echo $?
0
```

And that's it -- you've just built and run your very first unikernel!

#### Aside: Doing Nothing with Functors!

Functors are one of those OCaml things that can seem a bit intimidating at first
(traditionally, "monads" get the same sort of reaction). However, as they're
used fairly widely throughout Mirage, a very brief introduction to the commonest
way we use them is needed. For a better introduction as to how to actually make
use of them, what they are, and so on
see
[Real World OCaml, Ch.9](https://realworldocaml.org/v1/en/html/functors.html)
(and probably
also
[Ch.10, First-Class Modules](https://realworldocaml.org/v1/en/html/first-class-modules.html).

In short, in Mirage, they're used as a way to abstract over the target
environment for the unikernel. Functors are, roughly, functions from modules to
modules, and they allow us to pass modules into a unikernel so that the code
inside unikernel can interact with its environment (read files, send packets,
etc) without needing to care whether its been built to target UNIX, Xen, KVM, or
something else entirely. The modules that are passed into the unikernel in this
way are required to conform to type signatures that are specified when the
unikernel `job` value is created in the `config.ml` file.

We'll see several examples of this below but, for now, we need to wrap up our
`noop` unikernel in a module inside the `Unikernel` module so that we can use it
as a functor. This is actually quite straightforward -- we simply wrap the
`start` function in `unikernel.ml` inside some module. For example,

```
$ cat tutorial/noop-functor/unikernel.ml
module Main = struct

  let start =
    Lwt.return_unit

end
```

The use of the name `Main` is purely convention -- again, call it something
completely different if you wish to put C programming firmly behind you!

The only other change is to the corresponding invocation in `config.ml`:

```
$ cat tutorial/noop-functor/config.ml
open Mirage

let main =
  foreign "Unikernel.Main" job

let () =
  register "noop" [main]
```

Note that the string passed to `foreign` is now `"Unikernel.Main"` as we must
refer to the `Main` module inside the `Unikernel` module. Everything else stays
the same-- go ahead and try that out by building the unikernel inside
`noop-functor`.


...and now, onwards to unikernels that actually **do** something!

### Step 1: Hello World!

As a first step, let's build and run the MirageOS "Hello World" unikernel --
this will print a log message with the word `hello` 4 times before terminating:

```
2017-02-08 09:54:44 -01:00: INF [application] hello
2017-02-08 09:54:45 -01:00: INF [application] hello
2017-02-08 09:54:46 -01:00: INF [application] hello
2017-02-08 09:54:47 -01:00: INF [application] hello
```

First, let's look at the code:

```
open Lwt.Infix

module Hello (Time : Mirage_time_lwt.S) = struct

  let start pclock =

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

To veteran OCaml programmers among you, this might look a little odd: we have a
`Main` module parameterised a module (`Time`, of type `Mirage_time_lwt.S`) that contains a method `start` taking an ignored parameter `_time` (an instance of a `time`).  This is the basic structure required to make this a MirageOS unikernel
rather than a standard OCaml POSIX application.

The module type for our `Time` module, `Mirage_time_lwt.S`, is defined in an
external package [mirage-time](https://github.com/mirage/mirage-time).  The name `S` for "the module type of things like this" is a common OCaml convention (comparable to naming the most-used type in a module `t`).  There are many packages defining module types for use in Mirage.  For ease of discovery, a list of the module types that Mirage knows about is maintained
in the [`types/`](https://github.com/mirage/mirage/tree/master/types) directory
of the main MirageOS repository.  The `Mirage_types` module gives abstract definitions that leave some important primitives unspecified; the `Mirage_types_lwt` module contains more concrete definitions for use in programs.  Since you'll find yourself referring back to
these quite often when building MirageOS applications, it's worth bookmarking
the [documentation](http://mirage.github.io) for this module.

The concrete implementation of `Time` will be supplied at
compile-time, depending on the target that you are compiling for. This
configuration is stored in `config.ml`, so let's take a look:

```
$ cat tutorial/hello/config.ml

open Mirage

let main =
  foreign
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
is the `Main` module from the file `unikernel.ml`. The `@->` combinator is used
to add a device driver to the list of functor arguments in the job definition
(see `unikernel.ml`), and the final value of using this combinator should always
be a `job` if you intend to register it.

The `foreign` function also takes some additional arguments: `~keys`, the list of
configuration keys we want to allow the user to specify at configuration or build time, and
`packages`, a list of additional `opam` packages that should be included in the list of
build dependencies for the project.  We'll talk more about configuration keys in the next example.

Notice that we refer to the module name as a string (`"Unikernel.Main"`) when
calling `foreign`, instead of directly as
an OCaml value. The `mirage` command-line tool evaluates this configuration file
at build-time and outputs a `main.ml` that has the concrete values filled in for
you, with the exact modules varying by which backend you selected (e.g. Unix or
Xen).

MirageOS mirrors the unikernel model on UNIX as far as possible: your application is
built as a unikernel which needs to be instantiated and run whether on UNIX or
on Xen. When your unikernel is run, it starts much as a VM on Xen does -- and so
must be passed references to devices such as the console, network interfaces and
block devices on startup.

In this case, this simple `hello world` example requires some notion of time, so we register a single `Job` consisting of
the `Hello.Main` module
(and, implicitly its `start` function) and passing it references to a
timer.

#### Building a Unix binary

We invoke all this by configuring, building and finally running the resulting
unikernel under Unix first.

```
$ cd tutorial/hello
$ mirage configure -t unix
```

`mirage configure` generates a `Makefile` with all the build rules included from
evaluating the configuration file, a `main.ml` that represents the entry
point of your unikernel, and an `opam` file with a list of the packages necessary to build
the unikernel.

```
$ make depend
```

In order to automatically install the dependencies discovered by `mirage configure`
in your current `opam` switch, execute `make depend`.

```
$ make
```

This builds a UNIX binary called `console` that contains the simple console
application. If you are on a multicore machine and want to do parallel builds,
`export OPAMJOBS=4` (or some other value equal to the number of cores) will do
the trick.

Finally to run your application, as it is a standard Unix binary, simply run it
directly and observe the exciting log messages that our `for` loop is
generating:

```
$ ./hello
```

#### Building for Another Backend

To make a unikernel that will use [solo5](https://github.com/solo5/solo5) to run on KVM, re-run `mirage configure` and ask for the `ukvm` target instead of `unix`.

```
$ mirage configure -t ukvm
$ make depend
$ make
```

*Everything* else remains the same! The set of dependencies required, the `main.ml`, and the `Makefile` differ significantly, but since the source code of your application was
parameterised over the `Time` type, it doesn't matter-- you do not need to
make any changes for your code to run when linked against the solo5 console driver
instead of Unix.

When you build the `ukvm` version, you'll see some new artifacts: a `ukvm-bin` binary and a file called `hello.ukvm`.  `hello.ukvm` is the unikernel, and `ukvm-bin` is a dynamically-generated program that will pass it runtime information.  To try running `hello.ukvm`, pass it as an argument to `ukvm-bin`:

```
$ ./ukvm-bin hello.ukvm
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Memory map: 512 MB addressable:
Solo5:     unused @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1d8fff)
Solo5:     rodata @ (0x1d9000 - 0x20bfff)
Solo5:       data @ (0x20c000 - 0x2b3fff)
Solo5:       heap >= 0x2b4000 < stack < 0x20000000
Solo5: Clock source: KVM paravirtualized clock
Solo5: new bindings
STUB: getenv() called
2017-02-08 23:58:20 -00:00: INF [application] hello
2017-02-08 23:58:21 -00:00: INF [application] hello
2017-02-08 23:58:22 -00:00: INF [application] hello
2017-02-08 23:58:23 -00:00: INF [application] hello
Solo5: solo5_app_main() returned with 0
```

We get some additional output from the initialization of the unikernel and its successful boot, then we see our expected output, and solo5's report of the application's successful completion.

#### Configuration Keys

It's very common to pass additional runtime information to a program via command-line options or arguments.  But a unikernel doesn't have access to a command line, so how can we pass it runtime information?

Mirage provides a nice abstraction for this in the form of configuration keys.  The `Mirage` module provides a module `Key`, which contains functions for creating and using configuration keys.  For an example, let's have a look at `hello-key`:

```
$ cd tutorial/hello-key
$ cat config.ml
open Mirage

let key =
  let doc = Key.Arg.info ~doc:"How to say hello." ["hello"] in
  Key.(create "hello" Arg.(opt string "Hello World!" doc))

let main =
  foreign
    ~keys:[Key.abstract key]
    ~packages:[package "duration"]
    "Unikernel.Hello" (time @-> job)

let () =
  register "hello" [main $ default_time]
```

We create a `key` with `Key.create` which is an optional bit of configuration.  It will default to "Hello World!" if unspecified.  This particular key happens to be of type `string`, so no conversion will be required, but it's possible to ask for more exotic types in the call to `Arg` -- see [the Functoria Key.Arg module documentation](http://mirage.github.io/functoria/Functoria_key.Arg.html) for more details.

Once we've created our configuration key, we specify that we'd like it used in the unikernel by passing it to `foreign` in the `keys` parameter.

Let's configure the example for UNIX and build it:

```
$ mirage configure -t unix
$ make depend
$ make
```

When the target is Unix, Mirage will use an implementation for configuration keys that looks at the contents of `OS.Env.argv` -- in other words, it looks directly at the command line that was used to invoke the program.  If we call `hello` with no arguments, the default value is used:

```
./hello
2017-02-08 18:18:23 -03:00: INF [application] Hello World!
2017-02-08 18:18:24 -03:00: INF [application] Hello World!
2017-02-08 18:18:25 -03:00: INF [application] Hello World!
2017-02-08 18:18:26 -03:00: INF [application] Hello World!
```

but we can ask for something else:

```
./hello --hello="Bonjour!"
$ ./hello --hello="Bonjour!"
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
$ ./hello
2017-02-08 18:30:30 +06:00: INF [application] Hola!
2017-02-08 18:30:31 +06:00: INF [application] Hola!
2017-02-08 18:30:32 +06:00: INF [application] Hola!
2017-02-08 18:30:33 +06:00: INF [application] Hola!
$ ./hello --hello="Hi!"
2017-02-08 18:30:54 +06:00: INF [application] Hi!
2017-02-08 18:30:55 +06:00: INF [application] Hi!
2017-02-08 18:30:56 +06:00: INF [application] Hi!
2017-02-08 18:30:57 +06:00: INF [application] Hi!
```

When configured for non-Unix backends, other mechanisms are used to pass the runtime information to the unikernel.  `ukvm-bin`, which we used to run `hello.ukvm` in the non-keyed example, will pass information given after the kernel when invoked:

```
$ cd tutorial/hello-key
$ mirage configure -t ukvm
$ make depend
$ make
$ ./ukvm-bin hello.ukvm --hello="Hola!"
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Solo5: Memory map: 512 MB addressable:
Solo5:     unused @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1d8fff)
Solo5:     rodata @ (0x1d9000 - 0x20bfff)
Solo5:       data @ (0x20c000 - 0x2b3fff)
Solo5:       heap >= 0x2b4000 < stack < 0x20000000
Solo5: Clock source: KVM paravirtualized clock
Solo5: new bindings
STUB: getenv() called
2017-02-09 00:26:00 -00:00: INF [application] Hola!
2017-02-09 00:26:01 -00:00: INF [application] Hola!
2017-02-09 00:26:02 -00:00: INF [application] Hola!
2017-02-09 00:26:03 -00:00: INF [application] Hola!
Solo5: solo5_app_main() returned with 0
```

### Step 2: Getting a block device

Most useful unikernels will need to obtain data from the outside world, so we'll
explain this subsystem next.

#### Sector-addressible block devices

The [block/](https://github.com/mirage/mirage-skeleton/tree/master/block)
directory in `mirage-skeleton` contains an example of attaching a raw block
device to your unikernel.
The [V1.BLOCK](https://github.com/mirage/mirage/blob/1.1.0/types/V1.mli#L134)
interface signature contains the operations that are possible on a block device:
primarily reading and writing aligned buffers to a 64-bit offset within the
device.

On Unix, the development workflow to handle block devices is by mapping them
onto local files. The `config.ml` for the block example looks like this:

```
open Mirage

let main = foreign "Unikernel.Main" (console @-> block @-> job)

let img =
  if_impl Key.is_xen
    (block_of_file "xvda1")
    (block_of_file "disk.img")

let () =
  register "block_test" [main $ default_console $ img]
```

The `main` binding looks much like the earlier console example, except for the
addition of a `block` device in the list. When we register the job, we supply a
block device from a local file via `block_of_file`.

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

Build this on Unix in the same way as the console example.

```
$ cd block
$ mirage configure -t unix
$ make
$ ./generate_disk_img.sh
$ ./mir-block_test
```

The `generate_disk_img.sh` script just calls `dd` to create an empty file that
will act as our block device. Once it runs, `mir-block-test` will write a series
of patterns to the block device and read them back to check that they are the
same (the logic for this is in `unikernel.ml` within the `Block_test` module).

The Xen version works the same way. First build the code:

```
$ mirage configure -t xen
$ make
$ ./generate_disk_img.sh # only required if not executed as above
```

This will output a Xen config file called `block_test.xl`. It will look
approximately like this (note the additional `disk` definition that was
generated automatically by Mirage):

```
# Generated by Mirage (Mon, 20 Jul 2015 12:23:24 GMT).

name = 'block_test'
kernel = '/Users/djs/djs55/mirage-skeleton/block/mir-block_test.xen'
builder = 'linux'
memory = 256
on_crash = 'preserve'

disk = [ 'format=raw, vdev=xvdb, access=rw, target=/Users/djs/djs55/mirage-skeleton/block/disk.img' ]
```

Now you just need to boot the VM as before, and you should see the same output
(after the VM boot preamble) -- but now MirageOS is linked against the
Xen [block device driver](https://github.com/mirage/mirage-block-xen) and is
mapping the unikernel's block requests directly through to it, rather than
relying on the host OS (the Linux or FreeBSD kernel):

```
[root@st20 block]# xl create -c block_test.xl
Parsing config from block_test.xl
MirageOS booting....
Initialising timer interface
Initialising console ... done.
2016-05-20 13:13.27: INF [blkfront] Blkfront.connect 51728: interpreting 51728 as a xen virtual disk bus slot number
2016-05-20 13:13.27: INF [blkfront] Blkfront.connect 51728 -> 51728
2016-05-20 13:13.27: INF [blkfront] Blkfront.plug id=51728
2016-05-20 13:13.27: INF [blkfront] Blkback can only use a single-page ring
2016-05-20 13:13.27: INF [blkfront] Negotiated a single-page ring
2016-05-20 13:13.27: INF [blkfront] Blkfront.alloc ring Blkif.51728 header_size = 64; index slot size = 112; number of entries = 32
2016-05-20 13:13.27: INF [blkfront] Blkfront info: sector_size=512 sectors=4194304 max_indirect_segments=256
sectors = 524288
read_write=true
sector_size=4096
writing 1 sectors at 0
writing 1 sectors at 524287
writing 2 sectors at 0
writing 2 sectors at 524286
writing 12 sectors at 0
writing 12 sectors at 524276
writing 1 sectors at 524288
writing 12 sectors at 524277
reading 1 sectors at 524288
reading 12 sectors at 524277
Test sequence finished
Total tests started: 10
Total tests passed:  10
Total tests failed:  0
port 4 still bound!
$
```

On ARM, when `qemu` is not available, it is better to do it through `losetup` so
that you can access the 'disk':

```
$ sudo losetup -f ../block/disk.img
$ sudo losetup -a
```

Then edit the `block_test.xl` configuration so that the `disk` line reads as
follows:

```
disk = [ 'format=raw, vdev=xvdb, access=rw, target=/dev/loop0' ]
```

### Step 3: Key/value stores

The earlier block device example shows how very low-level access can work. Now
let's move up to a more familiar abstraction: a key/value store that can
retrieve buffers from string keys. This is essential for many common uses such
as retrieving configuration data or website HTML and images.

The
[kv_ro_crunch/](https://github.com/mirage/mirage-skeleton/tree/master/kv_ro_crunch) directory
in `mirage-skeleton` contains the simplest key/value store example. The
subdirectory `t/` contains a couple of data files that the unikernel uses. Our
example `unikernel.ml` reads in the data from one file and compares to the other
file, printing out `YES` if the values match, and `NO` otherwise.

The `config.ml` should look familiar after the earlier block and console
examples:

```
open Mirage

let main =
  foreign "Unikernel.Main" (console @-> kv_ro @-> kv_ro @-> job)

let disk1 = crunch "t"
let disk2 = crunch "t"

let () =
  register "kv_ro" [main $ default_console $ disk1 $ disk2]
```

We construct the `kv_ro` devices (`disk1` and `disk2`) by using the `crunch`
function. This takes a single directory as its argument, and converts that
entire directory into a static ML file that can respond with the file contents
directly. This removes the need to have an external block device entirely and is
very convenient indeed for small files.

Build the example and run it in the usual way under either Unix or Xen. Because
this no longer needs an external block device, you can run it under Xen without
having to edit the `xl` configuration file at all. You can read the generated ML
file by looking at the `static1.ml` file in your build tree.

Unix:

```
$ cd kv_ro_crunch
$ mirage configure -t unix
$ make
$ less static1.ml # the generated filesystem
$ ./mir-kv_ro
```

Xen:

```
$ mirage configure -t xen
$ make
$ sudo xl create -c kv_ro.xl
Parsing config from kv_ro.xl
MirageOS booting....
Initialising timer interface
Initialising console ... done.
YES!
YES!
YES!
YES!
YES!
YES!
YES!
YES!
YES!
YES!
```

Of course, this scheme doesn't really scale up to large websites, and we often
need a more elaborate configuration for larger datasets depending on how we are
deploying our unikernels (i.e. for development or production). Switch to
the [kv_ro/](https://github.com/mirage/mirage-skeleton/tree/master/kv_ro)
directory, which has exactly the same example as before, but with several new
configuration options: it can generate a block device that contains a FAT
filesystem that mirror the directory contents, or (when running under Unix)
simply proxy calls dynamically to the underlying filesystem.

Since the `config.ml` file is normal OCaml that is executed at build time, all
of this selection logic is simple enough.

```
open Mirage

let disk = generic_kv_ro "t"

let main =
  foreign "Unikernel.Main" (console @-> kv_ro @-> kv_ro @-> job)

let () =
  register "kv_ro" [main $ default_console $ disk $ disk]
```

This example is controlled by setting the `FS` environment variable at build
time. If you set it to `fat`, then the configuration tool will generate the
appropriate settings for external filesystem access.

On OSX:

```
$ mirage configure -t unix --kv_ro fat
$ ./make-fat1-image.sh
$ file fat1.img
fat1.img: x86 boot sector, code offset 0x0, OEM-ID "ocamlfat",
sectors/cluster 4, FAT  1, root entries 512, Media descriptor 0xf8,
sectors/FAT 1, sectors 49 (volumes > 32 MB) , dos < 4.0 BootSector (0x0)
```

or, on Linux:

```
$ mirage configure -t unix --kv_ro fat
$ ./make-fat1-image.sh
$ file fat1.img
fat1.img: x86 boot sector
```

However, notice that the definition of `disk` now checks to see if the build is
happening on Unix or Xen when crunch mode is requested. If the build is Xen,
then a statically linked filesystem is used. On Unix however, the overhead of
building this can be removed by simply passing through to the underlying
filesystem, which is done via the `direct_kv_ro` implementation.

You should now be seeing the power of the MirageOS configuration tool: we have
built several applications that use fairly complex concepts such as filesystems
and block devices that are independent of the implementations (by virtue of our
application logic being a functor), and then are able to assemble several
combinations of unikernels via relatively simple configuration files.

### Step 4: Networking

Block devices don't require a huge amount of configuration, but now we move onto
networking, which has far more knobs attached. There are several ways that we
might want to configure our networking:

* On Unix, it's convenient to use the standard kernel socket API for developing
  higher level protocols (such
  as [HTTP](http://github.com/mirage/ocaml-cohttp)). These run over TCP or UDP
  and so sockets work just fine.
* When we want finer control over the network stack, or simply to test the OCaml
  networking subsystem, we can use a userspace device facility such as the
  common Unix [tuntap](http://en.wikipedia.org/wiki/TUN/TAP) to parse Ethernet
  frames from userspace. This requires additional configuration to assign IP
  addresses, and possibly configure a network bridge to let the unikernel talk
  to the outside world.
* Once the unikernel works under Unix with the
  direct [OCaml TCP/IP stack](https://github.com/mirage/mirage-tcpip),
  recompiling it under Xen is just a matter of linking in
  the [Xen netfront](https://github.com/mirage/mirage-net-xen) driver to provide
  the Ethernet frames directly to the unikernel.

All of this can be manipulated via the `config.ml` file through standard OCaml
code as before; we use the `NET` environment variable in the example below. The
example below is config.ml from
the [stackv4/](https://github.com/mirage/mirage-skeleton/tree/master/stackv4)
directory in `mirage-skeleton`.

```
open Mirage

let handler = foreign "Unikernel.Main" (console @-> stackv4 @-> job)

let stack = generic_stackv4 default_console tap0

let () =
  register "stackv4" [handler $ default_console $ stack]
```

This configuration shows how composable the network stack subsystem is: the
application can be configured at compile-time to either listen on a socket port
(using the Linux kernel) *or* use tuntap directly -- the application code
remains the same. The definition of `main` just adds a new `stackv4` device
driver.

The `net` handler checks to see if it's building for a socket or direct network
stack. Crucially, both the socket and direct network stacks have a very similar
modular API which you can see
in
[mirage/types/V1.mli](https://github.com/mirage/mirage/blob/1.1.0/types/V1.mli#L512).
This lets your applications be parameterized across either backend.

We then define the `dhcp` variable to configure the network stack to either use
DHCP or using the "default" IPv4 address (for convenience, MirageOS assigns a
default of `10.0.0.2` in this case; this is of course overridden for production
deployments). The definition of `stack` then uses `dhcp` and `net` accordingly
to set up the networking stack.


<br />
<div class="panel callout">
  <i class="fa fa-info fa-3x pull-left"> </i>
  <p>
    You will have noticed by this stage that <code>mirage configure</code>
    invokes OPAM to install any libraries that it needs. If your application
    needs some extra packages, you can use the optional <code>~packages</code>
    and <code>~libraries</code> arguments to <code>foreign</code> to add the
    extra OPAM packages and ocamlfind libraries. For example, you could modify
    the code above to add an <a
    href='https://github.com/mirage/mirage-http'>HTTP library</a>.
  </p>
</div>

#### Unix / Socket networking

Let's get the network stack compiling using the standard Unix sockets APIs
first.

```
$ cd stackv4
$ mirage configure -t unix --net socket
$ make
$ sudo ./mir-stackv4
Manager: connect
Manager: configuring
Manager: socket config currently ignored (TODO)
IP address: 0.0.0.0

```

This Unix application is now listening simultaneously on 53/UDP and 8080/TCP,
and will print to the console information about data received. Let's try, using
the commonly available _netcat_ `nc(1)` utility. From a different console
execute:

```
$ echo -n hello udp world | nc -unw1 127.0.0.1 53
[ 1 sec delay ]
$ echo -n hello tcp world | nc -nw1 127.0.0.1 8080
```

On the first console you should now see (each line in red, green and finally
yellow respectively if your console supports it):

```
UDP 127.0.0.1.59406 > 0.0.0.0.53: "hello udp world"
TCP 127.0.0.1.50997 > _.8080
read: 15 "hello tcp world"
```

#### Unix / MirageOS Stack with DHCP

Next, let's try using the direct MirageOS network stack. On a pre-Yosemite Mac,
be sure to install the [tuntap](http://tuntaposx.sourceforge.net/) kernel module
before trying this.

Assuming you've got a DHCP server running:


```
$ cd stackv4
$ mirage configure -t unix --dhcp true --net direct
$ make
$ sudo ./mir-stackv4
Netif: connect unknown
Manager: connect
Manager: configuring
DHCP: start discovery

Sending DHCP broadcast (length 552)
DHCP: start discovery

Sending DHCP broadcast (length 552)
DHCP response:
input ciaddr 0.0.0.0 yiaddr 192.168.64.5
siaddr 192.168.64.1 giaddr 0.0.0.0
chaddr f2edd241cf3200000000000000000000 sname greyjay.mac.cl.cam.ac.uk file
DHCP: offer received: 192.168.64.5
DHCP options: Offer : DNS servers(192.168.64.1), Routers(192.168.64.1), Subnet mask(255.255.255.0), Lease time(85536), Server identifer(192.168.64.1)
Sending DHCP broadcast (length 552)
DHCP response:
input ciaddr 0.0.0.0 yiaddr 192.168.64.5
siaddr 192.168.64.1 giaddr 0.0.0.0
chaddr f2edd241cf3200000000000000000000 sname greyjay.mac.cl.cam.ac.uk file
DHCP: offer received
IPv4: 192.168.64.5
Netmask: 255.255.255.0
Gateways: [192.168.64.1]
ARP: sending gratuitous from 192.168.64.5
DHCP offer received and bound to 192.168.64.5 nm 255.255.255.0 gw [192.168.64.1]
Manager: configuration done
IP address: 192.168.64.5

```

The application starts up, issues a DHCP request and (eventually) receives a
response allocating an address -- in this case, `192.168.64.5`. Using that
address we can then trigger the application logic with some network input from
`nc(1)` in a separate terminal as before:


```
$ echo -n hello udp world | nc -unw1 192.168.64.5 53
$ echo -n hello tcp world | nc -nw1 192.168.64.5 8080
```

The original terminal reports the ARP transactions invoked by the stack, and
then reports the input received over UDP and TCP as previously:

```
ARP responding to: who-has 192.168.64.5?
UDP 192.168.64.1.61367 > 192.168.64.5.53: "hello udp world"
ARP: transmitting probe -> 192.168.64.1
ARP: updating 192.168.64.1 -> 12:dd:b1:3a:68:64
TCP 192.168.64.1.51631 > _.8080
read: 15 "hello tcp world"
```

#### Unix / MirageOS Stack with static IP addresses

__N.B.__ _This is described below on Linux for Ubuntu 14.04. It was known to
work on pre-Yosemite Mac OSX, but has not been tested on Yosemite where the new
`vmnet` framework replaces `tuntap`._

By default, if we do not use DHCP with a `direct` network stack, Mirage will
configure the stack to use the `tap0` interface with an address of `10.0.0.2`.
Verify that you have an existing `tap0` interface by reviewing `$ sudo ip link
show`; if you do not, load the tuntap kernel module (`$ sudo modprobe tun`) and
create a `tap0` interface owned by you (`$ sudo tunctl -u $USER -t tap0`). Bring
`tap0` up using `$ sudo ifconfig tap0 10.0.0.1 up`, then:

```
$ cd stackv4
$ mirage configure -t unix --dhcp false --net direct
$ make
$ ./mir-stackv4
Netif: plugging into tap0 with mac c2:9d:56:19:d7:2c
Netif: connect tap0
Manager: connect
Manager: configuring
Manager: Interface to 10.0.0.2 nm 255.255.255.0 gw [10.0.0.1]

ARP: sending gratuitous from 10.0.0.2
Manager: configuration done
IP address: 10.0.0.2
```

Now you should be able to ping the unikernel's interface:

```
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

You will see the ARP request being handled in the unikernel's terminal:

```
ARP responding to: who-has 10.0.0.2?
ARP: transmitting probe -> 10.0.0.1
ARP: updating 10.0.0.1 -> 6a:a8:fe:89:3c:67
```

Finally, you can then execute the same `nc(1)` commands as before (modulo the
target IP address of course!) to interact with the running unikernel:

```
$ echo -n hello udp world | nc -unw1 10.0.0.2 53
$ echo -n hello tcp world | nc -nw1 10.0.0.2 8080
```

And you will see the same output in the unikernel's terminal:

```
ARP responding to: who-has 10.0.0.2?
UDP 10.0.0.1.58784 > 10.0.0.2.53: "hello udp world"
ARP: transmitting probe -> 10.0.0.1
ARP: updating 10.0.0.1 -> ee:85:43:d5:d9:4d
TCP 10.0.0.1.47329 > _.8080
read: 15 "hello tcp world"
ARP: timeout 10.0.0.1
```

(The last line will be displayed after a delay dependent on the ARP timeout
setting.)

#### Xen

At this point, recompiling a Xen unikernel is pretty straightforward. The
configuration file already disables the socket-based job if a Xen compilation is
detected, leaving just the OCaml TCP/IP stack.

```
$ mirage configure -t xen --dhcp true
$ make
```

You will need to configure an appropriate Xen
[network bridge](http://wiki.xen.org/wiki/Xen_Networking) to connect to this.
The `mirage configure` command will guess the name of the bridge or openvswitch
to use based on the configuration of the build host. The generated `stackv4.xl`
will look like this:

```
# Generated by Mirage (Tue, 11 Aug 2015 21:05:57 GMT).

name = 'stackv4'
kernel = '/root/djs55/mirage-skeleton/stackv4/mir-stackv4.xen'
builder = 'linux'
memory = 256
on_crash = 'preserve'

disk = [  ]

# if your system uses openvswitch then either edit /etc/xen/xl.conf and set
#     vif.default.script="vif-openvswitch"
# or add "script=vif-openvswitch," before the "bridge=" below:
vif = [ 'bridge=xenbr0' ]
```

This tells Xen to bring up the virtual network interface and add it to the
`xenbr0` bridge. Depending on the dom0 interface configuration, usually
specified in `/etc/network/interfaces`, this will be brought up with a static IP
address or with a DHCP address. For example, in the Mirage Ubuntu
14.04 [Vagrant VM](https://github.com/mirage/mirage-vagrant-vms/), the following
lines are uncommented:

```
(network-script network-bridge)
(vif-script vif-bridge)
```

And the bridge interface is configured in `/etc/network/interfaces` as:

```
auto xenbr0
iface xenbr0 inet dhcp
  bridge_ports eth0
```

Finally, you can manually inspect the generated `main.ml` file to see what's
happening under the hood with the functor applications.

Now that we've covered the basics of configuration, block devices and
networking, let's get the real MirageOS website up and running with
a [networked application](/wiki/mirage-www).
