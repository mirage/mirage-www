Mirage has been tested on Debian Squeeze, Ubuntu Lucid and MacOS X 10.6. To compile the Xen backend, you *must* have a 64-bit Linux host.  32-bit is not supported at this time.

!!Toolchain

First, you need to have the following installed and available on your PATH:

* OCaml 3.12.0
* Findlib
* (optional) [Js_of_ocaml](http://ocsigen.org/js_of_ocaml/install)

!!!Source

* Fetch and extract OCaml from the [homepage](http://caml.inria.fr/download.en.html), and run `./configure && make world opt opt.opt && sudo make install`.
* Get Findlib from its [homepage](http://projects.camlcity.org/projects/findlib.html) and run `./configure && make && make install`.
* Make sure both `ocamlopt.opt` and `ocamlfind` are in your default PATH.

This is all you need for a basic installation of Mirage. You can optionally also grab `js_of_ocaml` if you want to try out the Node.js backend.

!!!Debian Packages

Debian is unfortunately still stuck at OCaml 3.11, but there are some 3.12.0 packages [here](http://ocaml.debian.net/debian/ocaml-3.12.0/).
The necessary GPG key must first be installed to use the package source.
{{
    # gpg -a --export 49881AD3 > glondu.gpg
    # apt-key add glondu.gpg
}}

Then add the following to `/etc/apt/sources.list`:
{{
    deb     http://ocaml.debian.net/debian/ocaml-3.12.0 sid main
    deb-src http://ocaml.debian.net/debian/ocaml-3.12.0 sid main
}}

And finally execute apt-get update:
{{
    $ sudo apt-get update
    $ sudo apt-get upgrade
}}

!!! Ubuntu

Ubuntu is even further behind than Debian, so building OCaml from source is recommended.
If you really want to try the Debian packages, then first remove any existing OCaml packages via `sudo apt-get remove ocaml-findlib camlp4-extra ocaml-native-compilers` and `sudo apt-get autoremove`.
There are then package conflicts with the following, which must be downloaded and installed separately:

* `ncurses-bin_5.7+20100626-0ubuntu1_amd64.deb`
* `libncurses5-dev_5.7+20100626-0ubuntu1_amd64.deb`
* `libncurses5_5.7+20100626-0ubuntu1_amd64.deb`

Download them, and run `sudo dpkg -i *.deb` on them. After that, the Debian instructions above should work.
To install the `tuntap` device, required for unix-direct, do `sudo modprobe tun`.

!!!Library and Tools

Now pick a location you want to install the binaries to (PREFIX) and add `$PREFIX/bin` to your `PATH`. The default `PREFIX` is `~/mir-inst` which does not require super-user access.

Then run `make PREFIX=<location> all install`.
The tools include the `mir-unix-*` and `mir-xen` build wrappers and the MPL protocol specification meta-compiler.
The installation has the UNIX and Xen custom runtimes, if appropriate for the build platform.  You require 64-bit Linux to compile up Xen binaries (32-bit will not work).

You should now have a working tool-chain! Next, go to the [hello world](/wiki/hello-world) to get started with your first Mirage program!
