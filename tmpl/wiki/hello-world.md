First make sure you have followed the [installation instructions](/wiki/install) and have `mir-xen` on your `PATH`.
Mirage uses `ocamlbuild` to build applications, with the `mir-*` scripts providing a convenient shell wrapper.

To try out basic functionality, do `cd mirage.git/tests/basic/sleep`.

Build a UNIX binary:

    mir-unix-direct sleep.bin

output will be in `_build/sleep.bin`

Build a Xen kernel:

    mir-xen sleep.xen

output will be in `_build/sleep.{bin,xen}`, and you can boot it up
in Xen with a config file like:

    $ cat > sleep.cfg
    name="sleep"
    memory=1024
    kernel="sleep.xen"
    <control-d>
    $ sudo xm create -c sleep.cfg

This runs a simple interlocking sleep test which tries out the
console and timer support for the various supported platforms.

Note that the `kernel` variable only accepts an absolute path or the
name of a file in the current directory.

Network
-------

Mirage networking is present in the Net module and can compile in two modes:

A 'direct' mode that works from the Ethernet layer (the OS.Ethif
module). On Xen, this is the virtual Ethernet driver, and on UNIX
this requires the `tuntap` interface.

A subset of the Net modules (Flow and Manager) are available in
'socket' mode under UNIX. This maps the Flow interface onto POSIX
sockets, enabling easy comparison with normal kernels.

There are two echo servers available in:

* `tests/net/flow`
* `tests/net/flow_udp`

You can compile these with:

    $ mir-unix-socket echo.bin
    $ ./_build/echo.bin

    $ mir-unix-direct echo.bin
    $ sudo ./_build/echo.bin

    $ mir-xen echo.xen
    # boot the kernel in ./_build/echo.xen

