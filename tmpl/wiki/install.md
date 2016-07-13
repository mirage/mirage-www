MirageOS consists of a set of OCaml libraries that link with a runtime to form either a standalone Xen operating system or a normal UNIX binary. These libraries are managed via the [OPAM](https://opam.ocaml.org) tool. After describing MirageOS's system requirements, we will introduce the basics of OPAM and setting up for MirageOS.

## Requirements

MirageOS has been tested on ArchLinux, Debian Wheezy/Jessie, Ubuntu 14.04/16.10, CentOS 6/7 and MacOS X 10.10+. To compile the Xen backend, you *must* have a 64-bit Linux host. 32-bit is not supported at this time.

### MacOS X

* __10.10__: No special requirements beyond Homebrew or MacPorts to get OCaml.
* __10.9 or lower__: You will also need the [tuntap](http://tuntaposx.sourceforge.net/) kernel module if you want to use the MirageOS network stack from userspace.  Note that we do not test older versions of OSX beyond 10.10.

If you are using Homebrew, run

    brew install opam
    opam init
    opam install mirage

### Ubuntu

#### Ubuntu 16.04 (Xenial) or higher

This has the latest packages required in the base distribution, so just run:

    apt-get update
    apt-get install opam
    opam init
    opam install mirage

#### Ubuntu 15.10 (Vivid) or lower

The version of OPAM in older Ubuntus is not high enough to run Mirage (which requires OPAM 1.2.2 or higher), so you will need to add a custom PPA for the latest packages:

    add-apt-repository ppa:avsm/ppa
    apt-get update
    apt-get install ocaml ocaml-native-compilers camlp4-extra opam
    opam init
    opam install mirage

Also note that the `mirage` configuration and deployment tool relies on the `xl` Xen toolstack to run Xen virtual machines.  Older Ubuntus may use the `xm` toolstack, so you will need to change it.

### Debian 

#### Debian Stable (Jessie)

Debian Jessie only packages OPAM 1.2.0, but Mirage needs OPAM 1.2.2 or higher.

TODO: no Debs for OPAM 1.2.2 available? Recommend static installer for Debian stable.

#### Debian Testing (Stretch) or Unstable (Sid)

These distributions include everything you need to run Mirage in the base distribution, so just do:

    apt-get update
    apt-get install ocaml ocaml-native-compilers camlp4-extra opam
    opam init
    opam install mirage
  

## MirageOS Package Management with OPAM

We use [OPAM](https://opam.ocaml.org) to manage OCaml compiler and library installations. It tracks library versions across upgrades and will recompile dependencies automatically if they get out of date. Please refer to OPAM [documentation](https://opam.ocaml.org) if you want to know more, but we will cover the basics to get you started here. There is a [Quick Install Guide](http://opam.ocaml.org/doc/Install.html) if the above instructions don't cover your operating system.

Note that you require **OPAM 1.2.2 or greater** to use with MirageOS. Some distribution packages provide earlier versions and must be updated; check with

    $ opam --version ## response should be at least 1.2.0, viz.
    1.2.0

All the OPAM state is held in the `.opam` directory in your home directory, including compiler installations. You should never need to switch to a root user to install packages. Package listings are obtained through `remote` sources, which defaults to the contents of [github.com/ocaml/opam-repository](https://github.com/ocaml/opam-repository).

After installation, `opam update -u` refreshes the package list and recompiles packages to the latest versions.  You should run this regularly to get the latest packages.

    $ opam init
    # list of your remotes, which should include opam.ocaml.org
    $ opam remote

Next, make sure you have at least **OCaml 4.02.3 or higher** as your active compiler. This is generally the case on MacOS X, though Debian only has it in the *testing* distribution at present. But don't worry: if your compiler is out of date, just run `opam switch` to have it locally install the right version for you.

    $ ocaml -version
    # if it is not 4.02.3 or higher, then run this
    $ opam switch 4.03.0

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

This will install [Mirage](https://github.com/mirage/mirage)!
If you're upgrading from an older beta installation of MirageOS, then be sure that you have at least 2.9.0.  You can verify this by checking that the version number in the manual page from `mirage --help` is at least 2.9.0 (as of the time of writing this page).

That's it. You now have everything required to start developing MirageOS unikernels that will run either as POSIX processes or as Xen VMs using the MirageOS network stack. Next, why not try [building a MirageOS *hello world*](/wiki/hello-world)?
