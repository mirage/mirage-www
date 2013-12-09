First make sure you have followed the [installation instructions](/wiki/install) to get a working Mirage installation.

The examples below are in the [`mirage-skeleton` repository](http://github.com/mirage/mirage-skeleton). Begin by cloning this and changing directory to it:

{{
    $ git clone git://github.com/mirage/mirage-skeleton.git
    $ cd mirage-skeleton
}}

!! First Steps: Hello World!

As a first step, let's build and run the Mirage "Hello World" unikernel -- this will print `hello\\nworld\\n` 5 times before terminating:

{{
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
}}

First, let's look at the code:

{{
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
}}

To veteran OCaml programmers among you, this might look a little odd: we have a `Main` module parameterised by another module (`C`, of type `CONSOLE`) that contains a method `start` taking a single parameter `c` (an instance of a `CONSOLE`). This is the basic structure required to make this a Mirage unikernel rather than a standard OCaml POSIX application.

As this is a Mirage unikernel, we *also* need to look at `config.ml`:
{{
    $ cat basic/config.ml
    open Mirage

    let () =
      Job.register [
        "Hello.Main", [Driver.console]
      ]
}}

This is the harness for our unikernel. The Mirage mirrors the Xen model on UNIX as far as possible: your application is built as a unikernel which needs to be instantiated and run whether on UNIX or on Xen. When your unikernel is run, it starts much as a VM on Xen does -- and so must be passed references to devices such as the console, network interfaces and block devices on startup.

In this case, this simple `hello world` example requires just a console for output, so we register a single `Job` consisting of the `Hello.Main` module (and, implicitly its `start` function) and passing it a single reference to a console.

We invoke all this by configuring, building and finally running the resulting unikernel:

{{
    $ make basic-configure
    $ make basic-build
    $ make basic-run
}}

Finally, after we're done, we can cleanup with:
{{
    $ make clean-basic
}}

Unpacking the `Makefile` this translates to:

{{
    $ mirage configure basic/config.ml --unix ## configuration
    $ mirage build basic/config.ml            ## build
    $ mirage run basic/config.ml              ## run
}}

Or, as `mirage` knows that it must first `configure` and then `build` before running, simply execute `make basic-run` which unpacks to:

{{
    $ mirage run basic/config.ml
}}

If you are on a 64-bit Linux system able to build Xen images, simply change `--unix` for `--xen` to build a Xen VM:

{{
    $ mirage configure basic/config.ml --xen
}}

*Everything* else remains the same!

You should see the same output on the Xen console as you did on the UNIX version you ran earlier. If you need more help, or would like to boot your Xen VM on Amazon's EC2, [click here](/wiki/xen-boot).
