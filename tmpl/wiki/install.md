Mirage consists of a set of OCaml libraries that link with a runtime to form either a standalone Xen operating system or a normal UNIX binary. These libraries are managed via the [OPAM](http://opam.ocamlpro.com) tool. After describing Mirage's system requirements, we will introduce the basics of OPAM and setting up for Mirage. 

!!Requirements

Mirage has been tested on ArchLinux, Debian Wheezy, Ubuntu Lucid/Raring and MacOS X 10.7 and 10.8. To compile the Xen backend, you *must* have a 64-bit Linux host. 32-bit is not supported at this time.

If you're using MacOS X, you will also need the [tuntap](http://tuntaposx.sourceforge.net/) kernel module if you want to use the direct networking stack.

If you're using Ubuntu/Debian, we recommend you also install the essential build tools (GNU make, etc) and GNU M4:

{{
$ apt-get install build-essential m4
}}

Also note that the `mirari` configuration and deployment tool relies on the `xl` Xen toolstack to run virtual machines.

!! Using OPAM

OPAM manages simultaneous OCaml compiler and library installations. It tracks library versions across upgrades, and will recompile dependencies automatically if they get out of date. Please refer to OPAM [documentation](https://opam.ocamlpro.com) if you want to know more, but we will cover the basics to get you started here.

Install OPAM for your operating system by following its [Quick Install Guide](http://opam.ocamlpro.com/doc/Quick_Install.html).

All the OPAM state is held in the `.opam` directory in your home directory, including compiler installations. You should never need to switch to a root user to install packages. Package listings are obtained through `remote` sources, which defaults to the contents of [github.com/OCamlPro/opam-repository](http://github.com/OCamlPro/opam-repository).

{{
$ opam init
}}

This initialises OPAM and adds the `default` repository to your package list. In the future, an `opam update` will refresh the package list, and an `opam upgrade` will recompile packages to the latest versions.

Next, make sure you have OCaml 4.00.1 as your active compiler. This is
generally the case on MacOS X, though Debian lags behind. But don't worry: if your compiler is out of date, just run `opam switch` to have it locally install the right version for you.

{{
$ ocaml -version
# if it is not 4.00.1, then run this
$ opam switch 4.00.1
}}

Once you've got the right version, set up your current shell environment:

{{
$ eval `opam config env`
# add the above line to your startup shell profile
$ opam install mirari
}}

This updates the variables in your shell to match the current OPAM installation, mainly by altering your system `PATH`. You can see the shell fragment by running `opam config env` at any time. If you add the `eval` line to your login shell (usually `~/.bash_profile`), it will automatically import the correct PATH on every subsequent login.

Finally, `opam install mirari` will install the [Mirari](https://github.com/mirage/mirari) tool that acts as a build frontend for Mirage applications. This gives you everything you need to [build the website for yourself!](/wiki/mirage-www)

!! Switching Compiler Instances

OPAM manages compiler instances by installing them simultaneously and
switching between them. The default installed compiler becomes the OPAM
`system` switch. OPAM installs packages in the current compiler switch, and a
compiler switch is customised to build for a specific Mirage target by
installation of the correct OPAM packages. 

For example, let's get a basic Mirage development environment installed using
your `system` compiler; in what follows,  if your `system` compiler is
pre-4.00.1 you will first need to `opam switch 4.00.1` and replace references
to `system` with `4.00.1`:

{{
$ opam install mirari mirage-net-socket
}}

That's it. You now have everything required to start developing Mirage unikernels -- ones that will run as POSIX processes using your OS' network stack anyway. To go a step further, and develop unikernels that will run as POSIX processes but using the Mirage network stack, switch to a new compiler instance and install the `mirage-net-direct` package instead:

{{
$ opam switch mirage-unix --alias-of system
$ eval `opam config env`
$ opam install mirari mirage-net-direct
}}

That will give you a compiler switch named `mirage-unix` -- in double-quick time if your system compiler is 4.00.1 or higher, thanks to OPAM's fast clone ability.

The `switch` above installs the compiler into `~/.opam/mirage-unix`, with the compiler binaries in `~/.opam/mirage-unix/bin`, and any libraries installed into `~/.opam/mirage-unix/lib`. The `opam config` will detect the current compiler and output the correct `PATH` for your compiler installation. Installation of the `mirari` and `mirage-net-direct` packages ensures you have the correct libraries installed to build Mirage unikernels for POSIX using the Mirage network stack.

Finally, if you are on 64-bit Linux then to build Mirage unikernels that can be booted as standalone Xen VMs, in another compiler switch install the `mirage-xen` package:

{{
$ opam switch mirage-xen --alias-of system
$ eval `opam config env`
$ opam install mirari mirage-xen
}}

In general, well-written Mirari config files will install any necessary dependencies -- OPAM will warn you and refuse if any of these conflict with your current Mirage compiler switch. Next, why not try [building the Mirage website](/wiki/mirage-www)?
