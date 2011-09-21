!!Building OCaml

!!!From Sources

* Fetch and extract OCaml from the [homepage](http://caml.inria.fr/download.en.html), and run `./configure && make world opt opt.opt && sudo make install`.
* Make sure both `ocamlopt.opt` is in your default `PATH`.

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
