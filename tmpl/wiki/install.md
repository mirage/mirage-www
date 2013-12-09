Mirage consists of a set of OCaml libraries that link with a runtime to form either a standalone Xen operating system or a normal UNIX binary. These libraries are managed via the [OPAM](http://opam.ocaml.org) tool. After describing Mirage's system requirements, we will introduce the basics of OPAM and setting up for Mirage.

!!Requirements

Mirage has been tested on ArchLinux, Debian Wheezy, Ubuntu Lucid/Raring, CentOS 6.4 and MacOS X 10.7 and 10.8. To compile the Xen backend, you *must* have a 64-bit Linux host. 32-bit is not supported at this time.

If you're using MacOS X, you will also need the [tuntap](http://tuntaposx.sourceforge.net/) kernel module if you want to use the Mirage network stack.

If you're using Ubuntu/Debian, we recommend you also install the essential build tools (GNU make, etc) and GNU M4:
{{
$ apt-get install build-essential m4
}}

On CentOS 6.4, install the system compiler and libraries via:
{{
$ sudo yum groupinstall "Development Tools" "Development Libraries"
}}

Also note that the `mirage` configuration and deployment tool relies on the `xl` Xen toolstack to run virtual machines.

!! Using OPAM

We use OPAM to manage OCaml compiler and library installations. It tracks library versions across upgrades, and will recompile dependencies automatically if they get out of date. Please refer to OPAM [documentation](https://opam.ocaml.org) if you want to know more, but we will cover the basics to get you started here. Install OPAM 1.1+ for your operating system by following its [Quick Install Guide](http://opam.ocaml.org/doc/Quick_Install.html).

All the OPAM state is held in the `.opam` directory in your home directory, including compiler installations. You should never need to switch to a root user to install packages. Package listings are obtained through `remote` sources, which defaults to the contents of [github.com/OCamlPro/opam-repository](http://github.com/OCamlPro/opam-repository).
After installation, `opam update -u` refreshes the package list and recompile packages to the latest versions.

Next, make sure you have OCaml 4.00.1 as your active compiler. This is generally the case on MacOS X, though Debian lags behind. But don't worry: if your compiler is out of date, just run `opam switch` to have it locally install the right version for you.

{{
$ ocaml -version
# if it is not 4.00.1, then run this
$ opam switch 4.00.1
}}

Once you've got the right version, set up your current shell environment:

{{
$ eval `opam config env`
# add the above line to your startup shell profile
}}

This updates the variables in your shell to match the current OPAM installation, mainly by altering your system `PATH`. You can see the shell fragment by running `opam config env` at any time. If you add the `eval` line to your login shell (usually `~/.bash_profile`), it will automatically import the correct PATH on every subsequent login.

Finally,
{{
opam install mirage
}}

will install [Mirage](https://github.com/mirage/mirage)!

That's it. You now have everything required to start developing Mirage unikernels that will run either as POSIX processes or as Xen VMs using the Mirage network stack. Next, why not try [building a Mirage `hello world`](/wiki/hello-world)?
