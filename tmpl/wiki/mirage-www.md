
Building this mirage website using UNIX sockets should be straightforward once `mirari` has successfully installed.

{{
$ git clone git://github.com/mirage/mirage-www
$ cd mirage-www
$ make unix-socket-build
$ sudo make run
}}

NB. If your build fails complaining about `xmlm.cma` not being found, this is a minor bug currently being ironed out. The workaround is to downgrade the `cow` package via `opam install cow.0.5.5 && opam pin cow 0.5.5`.

This will run the website on `localhost:80`, using normal kernel sockets.

!! Using Mirage's network stack

{{
$ opam remove mirage-net-socket
$ make clean unix-direct-build
$ sudo make run
}}

This will remove the `mirage-net-socket` package, which configures the current compiler switch to use the local kernel sockets libraries for network access; and then install the `mirage-net-direct` package, which configures the compiler switch to use Mirage's native OCaml network stack instead.

Visit this alternate yet functionally identical build of the website via [http://10.0.0.2](http://10.0.0.2).

These two packages conflict and so cannot be installed simultaneously in a single compiler switch. As removing these packages can cause other packages to have to be rebuilt, and this can take some time, you may prefer to setup aliased compiler switches within which to have each version.

{{
$ opam switch 4.00.1+mirage -a 4.00.1
$ opam install mirari
$ eval `opam config -env`
$ make clean unix-direct-build
$ sudo make run
}}

Rebuilding using your native UNIX socket libraries is then as simple as

{{
$ opam switch 4.00.1
$ eval `opam config -env`
$ make clean unix-socket-build
$ sudo make run
}}

!! Building the Website as a Xen Unikernel

Now try to compile up a Xen version of this website, via:

{{
$ opam switch 4.00.1+xen -a 4.00.1
$ opam install mirari
$ eval `opam config -env`
$ make clean xen-build
}}

There will be a symbolic link to your Xen microkernel in the current working directory: learn how to run it [here](/wiki/xen-boot).
