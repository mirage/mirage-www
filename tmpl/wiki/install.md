MirageOS consists of a set of OCaml libraries that link with a runtime to form either a standalone Xen operating system or a normal UNIX binary. These libraries are managed via the [OPAM](http://opam.ocaml.org) tool. After describing MirageOS's system requirements, we will introduce the basics of OPAM and setting up for MirageOS.

## Requirements

MirageOS has been tested on ArchLinux, Debian Wheezy, Ubuntu Precise/Lucid/Raring/Saucy, CentOS 6.4 and MacOS X 10.8 and 10.9. To compile the Xen backend, you *must* have a 64-bit Linux host. 32-bit is not supported at this time.

If you're using MacOS X, you will also need the [tuntap](http://tuntaposx.sourceforge.net/) kernel module if you want to use the MirageOS network stack from userspace.

If you're using Ubuntu/Debian, we recommend you also install the essential build tools (GNU make, etc) and GNU M4 as well as the OCaml toolchain including camlp4:

    apt-get install build-essential m4 ocaml ocaml-native-compilers camlp4-extra

On CentOS 6.4, install the system compiler and libraries via:

    sudo yum groupinstall "Development Tools" "Development Libraries"

On Arch Linux, install the system compiler and libraries via:
    sudo pacman -S ocaml camlp4 ocaml-findlib
    yaourt -S opam

Also note that the `mirage` configuration and deployment tool relies on the `xl` Xen toolstack to run virtual machines.

## Using OPAM

We use [OPAM](http://opam.ocaml.org) to manage OCaml compiler and library installations. It tracks library versions across upgrades and will recompile dependencies automatically if they get out of date. Please refer to OPAM [documentation](https://opam.ocaml.org) if you want to know more, but we will cover the basics to get you started here. Install OPAM for your operating system by following its [Quick Install Guide](http://opam.ocaml.org/doc/Install.html).

Note that you require **OPAM 1.2 or greater** to use with MirageOS. Some distribution packages provide earlier versions and must be updated; check with

    $ opam --version ## response should be at least 1.2.0, viz.
    1.2.0

All the OPAM state is held in the `.opam` directory in your home directory, including compiler installations. You should never need to switch to a root user to install packages. Package listings are obtained through `remote` sources, which defaults to the contents of [github.com/ocaml/opam-repository](http://github.com/ocaml/opam-repository).
After installation, `opam update -u` refreshes the package list and recompiles packages to the latest versions.

    $ opam init
    # list of your remotes, which should include opam.ocaml.org
    $ opam remote

Next, make sure you have at either OCaml 4.00.1 or 4.01.0 as your active compiler. This is generally the case on MacOS X, though Debian only has it in the *unstable* distribution at present. But don't worry: if your compiler is out of date, just run `opam switch` to have it locally install the right version for you.

    $ ocaml -version
    # if it is not 4.00.1 or 4.01.0, then run this
    $ opam switch 4.01.0

Once you've got the right version, set up your shell environment to point to the current compiler switch.

    $ eval `opam config env`
    # add the above line to your startup shell profile

This updates the variables in your shell to match the current OPAM installation, mainly by altering your system `PATH`. You can see the shell fragment by running `opam config env` at any time. If you add the `eval` line to your login shell (usually `~/.bash_profile`), it will automatically import the correct PATH on every subsequent login.

Check that the base packages are installed correctly:

    $ opam list
    Installed packages for system:
    base-bigarray         base  Bigarray library distributed with the OCaml compiler
    base-threads          base  Threads library distributed with the OCaml compiler
    base-unix             base  Unix library distributed with the OCaml compiler
    [ possibly other installed packages ]

Finally, install the MirageOS command-line tool.

    $ opam install mirage
    $ mirage --help

If you're using Arch Linux and `opam install mirage` gives errors about not finding camlp4 and camlp4 was installed with pacman (and not by OPAM), then running `opam install mirage` without having executed the `eval` line lets `opam` find the system-wide installation of camlp4.

This will install [Mirage](https://github.com/mirage/mirage)!
If you're upgrading from an older beta installation of MirageOS, then be sure that you have at least 1.1.0, or you'll get installation errors.  You can verify this by checking that the version number in the manual page from `mirage --help` is at least (as of the time of writing this page) 1.1.0.

That's it. You now have everything required to start developing MirageOS unikernels that will run either as POSIX processes or as Xen VMs using the MirageOS network stack. Next, why not try [building a MirageOS *hello world*](/wiki/hello-world)?
