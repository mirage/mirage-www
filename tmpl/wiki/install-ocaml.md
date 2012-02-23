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

!!! OSX

Package management on Mac OSX is somewhat fragmented, to say the least. We
choose to use [Homebrew](http://mxcl.github.com/homebrew/), and you should
begin by following its
[install instructions](https://github.com/mxcl/homebrew/wiki/installation). It
makes use of the system installed version of [Ruby](http://www.ruby-lang.org/)
-- if your system is missing it for some reason, install from
[here](http://www.ruby-lang.org/en/downloads/).

The first thing to do is to pull Anil's patched Homebrew formula for
`findlib`:

{{
    cd $(brew --prefix)
    git remote add -f avsm git://github.com/avsm/homebrew.git
    git checkout -b new-findlib
}}

Next, install the Homebrew packages for OCaml and `findlib`:

{{
    brew install objective-caml findlib
}}

Assuming you choose to put your source repositories in `$SRC`, then install my
fork of the [ODB](https://github.com/thelema/odb) OCaml package manager:

{{
    cd $SRC
    git clone git://github.com/mor1/odb
    alias odb=ocaml $SRC/odb/odb.ml
    
    export OCAMLPATH=~/.odb/lib:$OCAMLPATH
    export PATH=~/.odb/bin:$PATH
}}

You should then be able to install the following packages with `odb`:

{{
    odb oUnit
    odb bitstring
    odb lwt
    odb fileutils
    odb oasis
    odb batteris

    cd ~/.odb/lib && mv oasis/ oasis.ignore
    cd ../bin && mv oasis oasis.ignore
}}

Finally, to be able to rebuild the Oasis setup for the various `ocaml-*`
libraries, you need a patched version of Oasis:

{{
    cd $SRC
    git clone git://github.com/mor1/oasis
    cd oasis
    ocaml setup.ml -configure
    ocaml setup.ml -build
    ocaml setup.ml -install
}}

And that should be it! Pull, say,
[ocaml-dns](https://github.com/mor1/ocaml-dns) and execute:

{{
    oasis setup-clean
    oasis setup
    make
}}
