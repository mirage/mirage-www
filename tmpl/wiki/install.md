Mirage has been tested on Debian Squeeze, Ubuntu Lucid and MacOS X 10.6. To compile the Xen backend, you *must* have a 64-bit Linux host.  32-bit is not supported at this time.

!!Toolchain

First, you need to have the following installed and available on your PATH:

* OCaml 3.12.0
* Findlib
* (optional) [Js_of_ocaml](http://ocsigen.org/js_of_ocaml/install)

!!!Source

It is pretty easy to install OCaml and Findlib from source:

* Fetch and extract OCaml from the [homepage], and run `./configure && make world opt opt.opt && sudo make install`.
* Get Findlib from its [homepage] and run `./configure && make && make install`.
* Make sure both `ocamlopt.opt` and `ocamlfind` are in your default PATH.

This is all you need for a basic installation of Mirage. You can optionally also grab `js_of_ocaml` if you want to try out the Node.js backend.

!!!Debian Packages

Debian is unfortunately still at 3.11, but you can grab the latest
packages from [here](http://ocaml.debian.net/debian/ocaml-3.12.0/).

Then: `apt-get install ocaml-findlib camlp4-extra ocaml-native-compilers`

!!! Ubuntu

Ubuntu is even further behind than Debian, so building OCaml from source is recommended.
If you really want to try the Debian packages, then first remove any existing OCaml packages via `sudo apt-get remove ocaml-findlib camlp4-extra ocaml-native-compilers` and `sudo apt-get autoremove`.

There are then package conflicts with the following, which must be downloaded and installed separately:

* `ncurses-bin_5.7+20100626-0ubuntu1_amd64.deb`
* `libncurses5-dev_5.7+20100626-0ubuntu1_amd64.deb`
* `libncurses5_5.7+20100626-0ubuntu1_amd64.deb`

Download them, and run `sudo dpkg -i *.deb` on them, followed by installing the Debian packages via `sudo apt-get install ocaml-findlib camlp4-extra ocaml-native-compilers ocaml-nox`.

The necessary GPG key must be installed to use the package source for the latest OCaml versions, or just ignore the errors. You can install the key by `gpg -a --export 49881AD3 > glondu.gpg && apt-key add glondu.gpg`.

Then add the following to `/etc/apt/sources.list` : `deb http://ocaml.debian.net/debian/ocaml-3.12.0 sid main`, and finally execute `sudo apt-get update; sudo apt-get upgrade`.

To install the `tuntap` device, required for unix-direct, do `sudo modprobe tun`.

!!!Library and Tools

Now pick a location you want to install the binaries to (PREFIX) and add `$PREFIX/bin` to your `PATH`. The default `PREFIX` is `~/mir-inst` which does not require super-user access.

Then run `make PREFIX=<location> all install`

The tools include the `mir-unix-*` and `mir-xen` build wrappers and the MPL protocol specification meta-compiler.

The installation has the UNIX and Xen custom runtimes, if appropriate for the build platform.  You require 64-bit Linux to compile up Xen binaries (32-bit will not work).

!!Hello World

Mirage uses `ocamlbuild` to build applications, with the `mir-*` scripts providing a wrapper to OCamlbuild.
To try out basic functionality, do `cd tests/basic/sleep`.

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

