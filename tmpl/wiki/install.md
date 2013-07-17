Mirage consists of a set of OCaml libraries that link with a runtime to form either a standalone Xen operating system or a normal UNIX binary. These libraries are managed via the [OPAM](http://opam.ocamlpro.com) tool. We will first introduce the basics of OPAM, and then describe the libraries you need to get on with using Mirage.

OPAM manages simultaneous OCaml compiler and library installations. It tracks library versions across upgrades, and will recompile dependencies automatically if they get out of date. Please refer to OPAM [documentation](https://opam.ocamlpro.com) if you want to know more, but we will cover the basics to get you started here.

!!Requirements

Mirage has been tested on Archlinux, Debian Wheezy, Ubuntu Lucid/Raring and MacOS X 10.7 and 10.8. To compile the Xen backend, you *must* have a 64-bit Linux host. 32-bit is not supported at this time.

Install OPAM for your operating system by following its [Quick Install Guide](http://opam.ocamlpro.com/doc/Quick_Install.html).

If you're using MacOS X, you will also need the [tuntap](http://tuntaposx.sourceforge.net/) kernel module if you want to use the direct networking stack.

!! Using OPAM

All the OPAM state is held in the `.opam` directory in your home directory, including compiler installations. You should never need to switch to a root user to install packages. Package listings are obtained through `remote` sources, which defaults to the contents of [github.com/OCamlPro/opam-repository](http://github.com/OCamlPro/opam-repository).

{{
$ opam init
}}

This initialises OPAM and adds the `default` repository to your package list. In the future, an `opam update` will refresh the package list, and an `opam upgrade` will recompile packages to the latest versions.

Next, make sure you have OCaml 4.00.1 as your active compiler. This is
generally the case on MacOS X, but Debian lags behind. But don't worry: if
your compiler is out of date, just run `opam switch` to have it locally
install the right version for you.

{{
$ ocaml -version
# if it is not 4.00.1, then run this
$ opam switch 4.00.1
}}

N.B. The above step is currently also necessary on MacOS X as the `opam` installation of `ocamlfind` assumes that `ocamlfind` is placed in the same directory as the `ocaml` compiler. When using the `system` switch, this is not the case: `ocaml` is in `/usr/local/bin/ocaml` but `ocamlfind` is in `~/.opam/system/bin/ocamlfind`.

Once you've got the right version, set up your current shell environment.

{{
$ eval `opam config env`
# add the above line to your startup shell profile
$ opam install mirari
}}

This updates the variables in your shell to match the current OPAM installation, mainly by altering your system `PATH`. You can see the shell fragment by running `opam config env` at any time. If you add the `eval` line to your login shell (usually `~/.bash_profile`), it will automatically import the correct PATH on every subsequent login.

Finally, `opam install mirari` will install the [Mirari](/blog/mirari) tool
that acts as a build frontend for Mirage applications. This gives you
everything you need to [build the website for yourself!](/wiki/mirage-www)

