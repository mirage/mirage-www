Mirage consists of a set of OCaml libraries that link with a runtime, to form
either a standalone Xen operating system, or a normal UNIX binary.  These
libraries are managed via the [OPAM](http://opam.ocamlpro.com) package
management tool.  We will first introduce the basics of OPAM, and then describe
the libraries you need to get on with using Mirage.

OPAM manages simultaneous OCaml compiler and library installations.  It tracks
library versions across upgrades, and will recompile dependencies automatically
if they get out of date.  Please refer to OPAM
[documentation](https://opam.ocamlpro.com)
if you want to know more, but we will cover the basics to get you started here.

!!Requirements

Mirage has been tested on Archlinux, Debian Squeeze/Wheezy, Ubuntu Lucid and MacOS X
10.6/7. To compile the Xen backend, you *must* have a 64-bit Linux host.
32-bit is not supported at this time.

*Debian and Ubuntu*

{{
$ echo "deb [arch=amd64] http://www.recoil.org/~avsm/ wheezy main" >> /etc/apt/sources.list
$ apt-get update
$ apt-get install opam
}}

*MacOS X*

We recommend the use of [Homebrew](http://github.com/mxcl/homebrew) to get
started quickly. Ensure you have a up-to-date Home version (via `brew update`),
or the `brew tap` command below will fail.

{{
$ brew update
$ brew install opam
}}

You will also need the [tuntap](http://tuntaposx.sourceforge.net/) OS X kernel
module if you want to use the networking stack.

!! Using OPAM

!!! Initial Installation

All of the OPAM state is held in the `.opam` directory in your home directory,
including compiler installations.  You should never need to switch to a root
user to install packages.  Package listings are obtained through `remote`
sources, so lets set up the two we will need for Mirage.

{{
$ opam init
$ opam remote add mirage-dev git://github.com/mirage/opam-repo-dev
}}

The first command initialises OPAM and adds the `default` repository
to your package list. The second one is a `mirage-dev` remote that
contains bleeding-edge packages that have not yet been released, but
are directly available as git repositories. Whenever you issue an
`opam update`, it will automatically attempt to upgrade those git
repositories and recompile any dependencies as required.

{{
$ eval `opam config -env`
# add the above line to your ~/.profile
$ opam install mirari
}}

You now need to append the path to the OPAM installation to your system `PATH`.
An appropriate shell fragment is output via `opam config -env`.  If you add
the `eval` line to your login shell (usually `~/.profile`), it will automatically import
the correct PATH on every subsequent login.

Finally, `opam install mirari` will install the [Mirari](/blog/mirari)
library that will in turn download all the necessary dependencies and
setup the build system necessary to build `mirage-www`. To run it on
your local machine, do:

{{
$ git clone git://github.com/mirage/mirage-www
$ cd mirage-www
$ make
$ make run
}}

This will run the website on `localhost:80`, using normal kernel sockets.

!!! Switching Compiler Instances

The default compiler installed by OPAM uses the system OCaml installation. You
can use `opam switch` to swap between multiple cross-compilers.  If you are on
64-bit Linux, lets get the Xen cross-compiler working.

{{
$ opam switch
$ opam switch 4.00.1+mirage-xen
$ opam install mirari
$ eval `opam config -env`
}}

The `opam switch` command will show you the available compilers.  The
`switch` will install the compiler into `~/.opam/4.00.1+mirage-xen`,
with the compiler binaries in `~/.opam/4.00.1+mirage-xen/bin`, and any
libraries installed into `~/.opam/4.00.1+mirage-xen/lib`.  The `opam
config` will detect the current compiler and output the correct PATH
for your compiler installation.

Now try to compile up a Xen version of this website, via:
{{
$ cd mirage-www
$ make clean
$ make
}}

There will be a symbolic link to your Xen microkernel in the current
working directory: learn how to run it [here](/wiki/xen-boot).

An alternative is to compile a UNIX binary that uses the Mirage
network stack instead of kernel sockets. This is the `unix-direct`
compiler variant, and requires the `tuntap` interface to be available
on the UNIX host.
{{
$ opam switch 4.00.1+mirage-unix
$ opam install mirari
$ eval `opam config -env`
}}

You can now recompile the `mirage-www` repository, and the resulting binary will
serve HTTP traffic on `10.0.0.2` via the tuntap interface.

!!! Maintaining OPAM libraries

The `opam upgrade` command will refresh all your remote repositories, and
recompile any outdated libraries.  You will need to run this once per compiler
installed, so switch between them.

If you run into any problems with OPAM, then first ask on the Mirage [mailing
list](/about), or report a [bug](http://github.com/OCamlPro/opam/issues).  It
is safe to delete `~/.opam` and just start the installation again if you run
into an unrecoverable situation, as OPAM doesn't use any files outside of that
space.

!!! Developing new OPAM libraries

There are two kinds of OPAM remote repositories: `stable` released versions of
packages that have version numbers, and `dev` packages that are retrieved via
git or darcs (and eventually, other version control systems too).

To develop a new package, fork the
[mirage/opam-repo-dev](http://github.com/mirage/opam-repo-dev)
repository on Github, clone it locally, and add it as an OPAM remote.
{{
$ git clone git@github.com:avsm/opam-repo-dev
# remove the old dev remote
$ opam remote remove dev
$ cd opam-repo-dev
$ opam remote add dev .
}}

This will configure your local checkout as a development remote, and
OPAM will pull from it on every update. Each package lives in a
directory named with the version, such as `packages/foo.0.1`, and
requires three files inside it:

* `foo.0.1/url` : the URL to the distribution file or git directory
* `foo.0.1/opam` : the package commands to install and uninstall it
* `foo.0.1/descr` : a description of the library or application

It's easiest to copy the files from an existing package and modify
them to your needs (and read the [doc](http://opam.ocamlpro.org) for
more information). Once you're done, add and commit the files, issue
an `opam update`, and the new package should be available for
installation or upgrade.
