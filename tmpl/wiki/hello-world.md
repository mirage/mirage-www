First make sure you have followed the [installation instructions](/wiki/install) to setup the different OPAM compiler switches for each Mirage platform target.

The examples below are in the [`mirage-skeleton` repository](http://github.com/mirage/mirage-skeleton). Begin by cloning this and changing directory to it:

{{
    $ git clone git://github.com/mirage/mirage-skeleton.git
    $ cd mirage-skeleton
}}

!! First Steps: Hello World!

As a first step, build and run the Mirage "Hello World" unikernel as a simple POSIX binary -- this will print `Hello\nWorld\n` 5 times before terminating:

{{
    $ cat basic/hello.ml
    $ make build-basic
    $ make run-basic
}}

Cleanup with:

{{
    $ make clean-basic
}}
    
To rebuild this as a Xen VM, simply `opam switch` and rebuild:

{{
    $ opam switch 4.00.1+mirage-xen
    $ eval `opam config env`
    $ make build-basic
}}

This results in a symlink `./basic/mir-hello.xen` to `./basic/_build/main.xen`. Boot it using Mirari:

{{
    $ make run-basic
}}

You should see the same output on the Xen console as you did on the UNIX version you ran earlier. If you need more help, or would like to boot your Xen VM on Amazon's EC2, [click here](/wiki/xen-boot).

!! Networking

Mirage networking is present in the `Net` module and can compile in two modes:

* A `direct` mode that works from the Ethernet layer (the `OS.Netif`
  module). On Xen, this is the virtual Ethernet driver, and on UNIX
  this requires the `tuntap` interface. You can link in this `Net`
  module by using the `xen` or `unix-direct` backends for Xen and UNIX
  respectively.

* A subset of the Net modules (`Flow`, `Channel` and `Manager`) are
  available in 'socket' mode under UNIX. This maps the interfaces onto
  POSIX sockets, enabling easy comparison with normal kernels. This is
  only supported under UNIX via the `unix-socket` backend.

When building a Mirage unikernel, `mirari` automatically include
boilerplate code that uses the `Net.Manager` module. On the `direct`
mode, your kernel will answer ping requests, as you can verify by
issuing the following commands:

Unix:

{{
    $ opam switch 4.00.1+mirage-unix
    $ eval `opam config env`
    $ make
    $ sudo ./mir-hello
    $ ping 10.0.0.2
}}

Xen:

{{
    $ opam switch 4.00.1+mirage-xen
    $ eval `opam config env`
    $ make
    $ sudo xl create -c hello.cfg
     <configure the bridge IP address>
    $ telnet 10.0.0.2 8081
}}
