First make sure you have followed the [installation
instructions](/wiki/install).  Mirage uses [Mirari](/blog/mirari) to
automate the configuration and setup the build system necessary to
build Mirage unikernels.

!!First Steps
To try out basic functionality and build a UNIX binary, do:

{{
    $ git clone git://github.com/mirage/mirage-skeleton.git
    $ cd mirage-skeleton/basic
    $ cat basic/hello.ml
    $ make
    $ ./mir-hello
}}

This will just starts up a Xen kernel that prints "hello world" with a
short pause between words. Now build a Xen version of this:

{{
    $ opam switch 4.00.1+mirage-xen
    $ eval `opam config env`
    $ make clean && make
}}

This will create a symlink to `./dist/build/mir-hello/mir-hello.xen`,
and you can boot it up with a config file like:

{{
    $ cd dist/build/mir-hello
    $ cat > hello.cfg
    name="hello"
    memory=1024
    kernel="mir-hello.xen"
    <control-d>
    # Use xm instead of xl if you are using Xen 4.1 or older
    $ sudo xl create -c sleep.cfg
}}

You should see the same output on the Xen console as you did on the
UNIX version you ran earlier.  If you need more help getting a Xen
kernel booted, try looking at the [Xen notes](/wiki/xen-boot) also.

!!Networking

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

Try out the ping server test by:

{{
    $ cd mirage-skeleton/ping
    $ opam switch 4.00.1+mirage-unix
    $ eval `opam config env`
    $ make
    $ sudo ./mir-ping
    $ ping 10.0.0.2
}}

And similarly, the Xen version:

{{
    $ opam switch 4.00.1+mirage-xen
    $ eval `opam config env`
    $ make
    $ cd dist/build/mir-ping
    $ cat > ping.cfg
    name="ping"
    memory=128
    kernel="ping.xen"
    vif=['bridge=xenbr0']
     <control-d>
    $ sudo xl create -c ping.cfg
     <configure the bridge IP address>
    $ telnet 10.0.0.2 8081
}}
