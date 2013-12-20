First make sure you have followed the [installation instructions](/wiki/install) to get a working Mirage installation.

The examples below are in the [`mirage-skeleton` repository](http://github.com/mirage/mirage-skeleton). Begin by cloning this and changing directory to it:

```
    $ git clone git://github.com/mirage/mirage-skeleton.git
    $ cd mirage-skeleton
```

!! First Steps: Hello World!

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
    $ cat basic/hello.ml
    open Mirage_types.V1

    module Main (C: CONSOLE) = struct

      let start c =
        for_lwt i = 0 to 4 do
          C.log c "hello" ;
          lwt () = OS.Time.sleep 2.0 in
          C.log c "world" ;
          Lwt.return ()
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
    $ cat basic/config.ml
    open Mirage

    let () =
      Job.register [
        "Hello.Main", [Driver.console]
      ]
```

The configuration registers a set of one or more jobs, each of which represent a
process (with a start/stop lifecycle).  In this case, the entry point of the process
is the `Main` module that we defined earlier in `hello.ml`.  It takes a console
as its only parameter.

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

We invoke all this by configuring, building and finally running the resulting
unikernel under Unix first.


```
cd basic
mirage configure --unix
```

This will first check that you have all the right OPAM packages installed
to build a Unix application, and install the if they're not present.
It also creates a `Makefile` and `main.ml` by evaluating the `config.ml`.

```
make
```

This builds a UNIX binary called `mir-main` that contains the simple console
application.

```
mirage run
# or run the binary directly
./mir-main
```

Since this is a simple Unix application, you can just run it directly, and
observe the exciting console commands that our `for` loop is generating.

If you are on a 64-bit Linux system able to build Xen images, simply change
`--unix` for `--xen` to build a Xen VM:

```
mirage configure --xen
```

*Everything* else remains the same!  The `main.ml` and `Makefile` generated
differ significantly, but since the source code of your application was 
parameterised over the `CONSOLE` type, it doesn't need to be changed to run
using the Xen console driver instead of Unix.

When you build the Xen version, you'll have a `mir-main.xen` unikernel that
can be booted as a standalone kernel.

```
mirage run
```

This will generate a `main.xl` Xen configuration file.  You can run this
via `xl create -c main.xl` (or, if you're still on the older Xen, swap
the `xl` command for `xm`).

You should see the same output on the Xen console as you did on the UNIX
version you ran earlier. If you need more help, or would like to boot your Xen
VM on Amazon's EC2, [click here](/wiki/xen-boot).

Next, let's get the Mirage website up and running with a [networked application](/wiki/mirage-www).
