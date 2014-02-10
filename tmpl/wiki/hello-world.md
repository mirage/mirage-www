First make sure you have followed the [installation
instructions](/wiki/install) to get a working Mirage installation.  The
examples below are in the [`mirage-skeleton` repository](http://github.com/mirage/mirage-skeleton). Begin by cloning 
and changing directory to it:

```
$ git clone git://github.com/mirage/mirage-skeleton.git
$ cd mirage-skeleton
```

### First Steps: Hello World!

As a first step, let's build and run the Mirage "Hello World" unikernel -- this
will print `hello\\nworld\\n` 5 times before terminating:

```
    hello
    world
    hello
    world
    hello
    world
    hello
    world
    hello
    world
```

First, let's look at the code:

```
    $ cat console/unikernel.ml
    open Lwt

    module Main (C: V1_LWT.CONSOLE) = struct

    let start c =
      for_lwt i = 0 to 4 do
        C.log c "hello" ;
        lwt () = OS.Time.sleep 1.0 in
        C.log c "world" ;
        return ()
      done
    end
```

To veteran OCaml programmers among you, this might look a little odd: we have a
`Main` module parameterised by another module (`C`, of type `CONSOLE`) that
contains a method `start` taking a single parameter `c` (an instance of a
`CONSOLE`). This is the basic structure required to make this a Mirage
unikernel rather than a standard OCaml POSIX application.

The concrete implementation of `CONSOLE` will be supplied at compile-time,
depending on the target that you are compiling for.  This configuration is
stored in `config.ml`, which is very simple for our first application.

```
    $ cat console/config.ml
    open Mirage

    let main =
      foreign "Unikernel.Main" (console @-> job)

    let () =
      register "console" [
      main $ default_console
    ]
```

The configuration `register`s a set of one or more jobs, each of which represent
a process (with a start/stop lifecycle).  Each job most likely depends on some
device drivers; all the available device drivers are defined in the `Mirage`
module (see [here](http://mirage.github.io/mirage/)).

In this case, the `main` variable declares that the entry point of the process
is the `Main` module from the file `unikernel.ml`.  The `@->` combinator is
used to add a device driver to the list of functor arguments in the job
definition (see `unikernel.ml`), and the final value of using this combinator
should always be a `job` if you intend to register it.

Notice that we refer to the module name as a string here, instead of directly
as an OCaml value.  The `mirage` command-line tool evaluates this configuration
file at build-time and outputs a `main.ml` that has the concrete values filled in
for you, with the exact modules varying by which backend you selected (e.g. Unix or
Xen).

Mirage mirrors the Xen model on UNIX as far as possible: your application is
built as a unikernel which needs to be instantiated and run whether on UNIX or
on Xen. When your unikernel is run, it starts much as a VM on Xen does -- and
so must be passed references to devices such as the console, network interfaces
and block devices on startup.

In this case, this simple `hello world` example requires just a console for
output, so we register a single `Job` consisting of the `Hello.Main` module
(and, implicitly its `start` function) and passing it a single reference to a
console.

You can find the module signatures of all the device drivers (such as `CONSOLE`)
in the [`types/`](https://github.com/mirage/mirage/tree/master/types) directory
of the main Mirage repository.  Since you'll find yourself referring back to
these quite often when building Mirage applications, it's worth bookmarking
the [documentation](http://mirage.github.io) for this module.

#### Building a Unix binary

We invoke all this by configuring, building and finally running the resulting
unikernel under Unix first.


```
cd console
mirage configure --unix
```

This will first check that you have all the right OPAM packages installed
to build a Unix application, and install the if they're not present.
It also creates a `Makefile` and `main.ml` by evaluating the `config.ml`.

```
make
```

This builds a UNIX binary called `mir-console` that contains the simple console
application.  If you are on a multicore machine and want to do parallel builds,
`export OPAMJOBS=4` (or some other value equal to the number of cores) will do
the trick.

```
mirage run
# or run the binary directly
./mir-console
```

Since this is a normal Unix binary, you can just run it directly, and observe
the exciting console commands that our `for` loop is generating.

#### Building a Xen unikernel

If you are on a 64-bit Linux system able to build Xen images, simply change
`--unix` for `--xen` to build a Xen VM:

```
mirage configure --xen
```

*Everything* else remains the same!  The `main.ml` and `Makefile` generated
differ significantly, but since the source code of your application was 
parameterised over the `CONSOLE` type, it doesn't need to be changed to run
using the Xen console driver instead of Unix.

When you build the Xen version, you'll have a `mir-console.xen` unikernel that
can be booted as a standalone kernel.

```
mirage run
```

This will generate a `main.xl` Xen configuration file in the current
directory that looks something like this:

```
# Generated by Mirage (Tue, 31 Dec 2013 19:27:12 GMT).

name = 'main'
kernel = '/home/avsm/src/git/avsm/mirage-www/src/mir-main.xen'
builder = 'linux'
memory = 256
```

Edit this to customize the VM name or memory, and then run it via `xl create -c main.xl`
(or, if you're still on the older Xen, swap the `xl` command for `xm`).
You should see the same output on the Xen console as you did on the
UNIX version you ran earlier. If you need more help, or would like to boot your
Xen VM on Amazon's EC2, [click here](/wiki/xen-boot).

Next, let's get the Mirage website up and running with a [networked application](/wiki/mirage-www).
