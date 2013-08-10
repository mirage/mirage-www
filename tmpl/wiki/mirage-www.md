Building this mirage website using UNIX sockets should be straightforward once `mirari` has successfully installed. 

{{
$ git clone git://github.com/mirage/mirage-www
$ cd mirage-www
$ make unix-socket-build
$ sudo make run
}}

This will install any necessary packages, and build and run the website on `localhost:80` using normal kernel sockets. If you get any package conflicts, it's likely that you're in a compiler switch that has packages installed to support one of the other Mirage target platforms. If you just followed the [install](/wiki/install) instructions, then simply `opam switch system`.

!! Using Mirage's network stack

If you've followed the [install](/wiki/install) instructions, you can just select the right compiler switch by `opam switch mirage-unix`; or else:

{{
$ opam remove mirage-net-socket
$ make clean unix-direct-build
$ sudo make run
}}

This will remove the `mirage-net-socket` package, which configures the current compiler switch to use the local kernel sockets libraries for network access; and then install the `mirage-net-direct` package, which configures the compiler switch to use Mirage's native OCaml network stack instead.

Visit this alternate yet functionally identical build of the website via [http://10.0.0.2](http://10.0.0.2).

!! Building the Website as a Xen Unikernel

Finally, compile up a Xen version of this website; if you followed the [install](/wiki/install) just switch to it via `opam switch mirage-xen`, or else:

{{
$ opam switch mirage-xen
$ eval `opam config -env`
$ opam install mirari
$ make clean xen-build
}}

There will be a symbolic link to your Xen microkernel in the current working directory; next, [learn how to boot it](/wiki/xen-boot).
