First make sure you have followed the [installation instructions](/wiki/install) and have `mir-xen` in your `PATH`.
Mirage uses `ocamlbuild` to build applications, with the `mir-*` scripts providing a convenient shell wrapper for each backend.

!!First Steps
To try out basic functionality and build a UNIX binary, do:

{{
    $ cd mirage.git/regress
    $ cat basic/sleep.ml
    $ mir-build unix-direct/basic/sleep.bin
    $ ./_build/unix-direct/basic/sleep.bin
}}

This will run a simple thread sleeping test that will output to the console.
Now build a Xen version of this:

{{
    $ mir-build xen/basic/sleep.xen
}}

output will be in `_build/sleep.xen`, and you can boot it up with a config file like:

{{
    $ mir-build xen/regress/basic/sleep.xen
    $ cd _build/xen/basic
    $ cat > sleep.cfg
    name="sleep"
    memory=1024
    kernel="sleep.xen"
    <control-d>
    $ sudo xm create -c sleep.cfg
}}

You should see the same output on the Xen console as you did on the UNIX version you ran earlier.
If you need more help getting a Xen kernel booted, try looking at the [Xen notes](/wiki/xen-boot) also.

!!Networking

Mirage networking is present in the `Net` module and can compile in two modes:

* A `direct` mode that works from the Ethernet layer (the `OS.Netif` module). On Xen, this is the virtual Ethernet driver, and on UNIX this requires the `tuntap` interface. You can link in this `Net` module by using the `xen` or `unix-direct` backends for Xen and UNIX respectively.

* A subset of the Net modules (`Flow`, `Channel` and `Manager`) are available in 'socket' mode under UNIX. This maps the interfaces onto POSIX sockets, enabling easy comparison with normal kernels. This is only supported under UNIX via the `unix-socket` backend.

Try out the ping server test by:

{{
    $ cd mirage.git/regress
    $ mir-build unix-direct/net/ping.bin
    $ sudo ./_build/unix-direct/net/ping.bin
    $ ping 10.0.0.2
}}

And similarly, the Xen version:

{{
    $ mir-build xen/net/ping.xen
    $ cd _build/xen/net
    $ cat > ping.cfg
    name="ping"
    memory=128
    kernel="ping.xen"
    vif=['bridge=xenbr0']
     <control-d>
    $ sudo xm create -c ping.cfg
     <configure the bridge IP address>
    $ telnet 10.0.0.2 8081
}}

