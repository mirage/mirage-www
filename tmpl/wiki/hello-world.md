First make sure you have followed the [installation instructions](/wiki/install) and have `mir-xen` in your `PATH`.
Mirage uses `ocamlbuild` to build applications, with the `mir-*` scripts providing a convenient shell wrapper for each backend.

!!First Steps
To try out basic functionality and build a UNIX binary, do:

{{
    $ cd mirage.git/tests/basic/sleep
    $ mir-unix-direct sleep.bin
    $ ./_build/sleep.bin
}}

This will run a simple thread sleeping test that will output to the console.
Now build a Xen version of this:

{{
    $ mir-xen sleep.xen
}}

output will be in `_build/sleep.xen`, and you can boot it up with a config file like:

{{
    $ cd _build
    $ cat > sleep.cfg
    name="sleep"
    memory=1024
    kernel="sleep.xen"
    <control-d>
    $ sudo xm create -c sleep.cfg
}}

You should see the same output on the Xen console as you did on the UNIX version you ran earlier.

!!Networking

Mirage networking is present in the `Net` module and can compile in two modes:

* A `direct` mode that works from the Ethernet layer (the `OS.Netif` module). On Xen, this is the virtual Ethernet driver, and on UNIX this requires the `tuntap` interface. You can link in this `Net` module by using `mir-xen` or `mir-unix-direct` for Xen and UNIX respectively.

* A subset of the Net modules (`Flow`, `Channel` and `Manager`) are available in 'socket' mode under UNIX. This maps the interfaces onto POSIX sockets, enabling easy comparison with normal kernels. This is only supported under UNIX via `mir-unix-socket`.

Try out the echo server test by:

{{
    $ cd tests/net/flow
    $ mir-unix-socket echo.bin
    $ sudo ./_build/echo.bin
    $ telnet 127.0.0.1 8081
}}

Now that the socket version works, you can try the `mir-unix-direct` version that runs over `tuntap`.

{{
    $ mir-unix-direct echo.bin
    $ sudo ./_build/echo.bin
       <configure tap0 interface>
    $ telnet 10.0.0.2 8081
}}

And similarly, the Xen version:

{{
    $ mir-xen echo.xen
    $ cd _build
    $ cat > echo.cfg
    name="echo"
    memory=128
    kernel="echo.xen"
    vifs=['bridge=eth0']
     <control-d>
    $ sudo xm create -c echo.cfg
     <configure the bridge IP address>
    $ telnet 10.0.0.2 8081
}}

