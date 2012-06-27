Mirage consists of a set of OCaml libraries that link with a runtime, to form
either a standalone Xen operating system, or a normal UNIX binary.  These
libraries are managed via the [OPAM](http://github.com/OCamlPro/opam) package
management tool.  We will first introduce the basics of OPAM on this page, and
then describe the libraries you need to get on with using Mirage.

OPAM manages simultaneous OCaml compiler installations, and all the libraries
to go with it.  It tracks library versions across upgrades, and will recompile
dependencies automatically if they get out of date.  There is a comprehensive
[specification](https://github.com/OCamlPro/opam/blob/master/specs/roadmap.pdf)
if you want to know more, but we will cover the basics to get you started here.

!!Requirements

Mirage has been tested on Debian Squeeze/Wheezy, Ubuntu Lucid and MacOS X
10.6/7. To compile the Xen backend, you *must* have a 64-bit Linux host.
32-bit is not supported at this time.

*Debian*

{{
# apt-get install build-essential ocaml ocaml-native-compilers git
# git clone git://github.com/OCamlPro/opam.git
# cd opam && make && make install
}}

Now skip to the next section to initialise OPAM.

*MacOS X*

We recommend the use of [Homebrew](http://github.com/mxcl/homebrew) to get started
very quickly. Ensure you have a reasonably up-to-date version (via `brew update`),
or the `brew tap` command below will fail.

{{
$ brew tap mirage/homebrew-ocaml
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
$ opam init default http://mirage.github.com/opam
$ opam remote -kind git -add dev git://github.com/mirage/opam-repo-dev
$ opam update
}}

The first command initialises OPAM and adds the `default` repository to your
package list.  The second one is a `dev` remote that contains bleeding-edge
packages that have not yet been released, but are directly available as git
repositories.  Whenever you issue an `opam update`, it will automatically
attempt to upgrade those git repositories and recompile any dependencies as
required.

{{
$ eval `opam config -env`
# add the above line to your ~/.profile
$ opam --verbose install cow mirage-fs
}}

You now need to add the path to the OPAM installation, which is automatically
added via `opam config -env`.  If you add this to your login shell (usually
`~/.profile`), it will automatically import the correct PATH.

Finally, the `opam install` will install the [CamlOnTheWeb](/wiki/cow) library 
and file system utilities, which are sufficient to build this website.  To
run it on your local machine, do:

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
$ opam switch -list
$ opam switch -alias xen 3.12.1+mirage-xen
$ opam install cow mirage-fs
$ eval `opam config -env`
}}

The `list` command will show you the available compilers.  The `switch` will
install the compiler into `~/.opam/xen`, with the compiler binaries in
`~/.opam/xen/bin`, and any libraries installed into `~/.opam/xen/lib`.
The `opam config` will detect the current compiler and output the correct
PATH for your compiler installation.

Now try to compile up a Xen version of this website, via:
{{
$ cd mirage-www
$ make clean
$ make xen
}}

There will be a Xen microkernel in `./src/_build/main.xen`.
*todo: how to run it*

!!! Maintaining OPAM libraries

The `opam upgrade` command will refresh all your remote repositories, and
recompile any outdated libraries.  You will need to run this once per
compiler installed, so switch between them 

If you run into any problems with OPAM, then first ask on the Mirage
[mailing list](/about), or report a [bug](http://github.com/OCamlPro/opam/issues).
It is safe to delete `~/.opam` and just start the installation again if you run into an unrecoverable
situation, as OPAM doesn't use any files outside of that space.

!!! Developing new OPAM libraries

TODO
