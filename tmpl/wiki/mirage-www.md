
!! Building the Mirage website

{{
$ git clone git://github.com/mirage/mirage-www
$ cd mirage-www
$ make unix-socket-build
$ make run
}}

This will run the website on `localhost:80`, using normal kernel sockets.

!!! Switching Compiler Instances

The default compiler installed by OPAM uses the system OCaml installation. You can use `opam switch` to swap between multiple cross-compilers. If you are on 64-bit Linux, lets get the Xen cross-compiler working.

{{
$ opam switch
$ opam switch 4.00.1+xen -a 4.00.1
$ opam install mirari
$ eval `opam config -env`
}}

The `opam switch` command will show you the available compilers. The `switch` will install the compiler into `~/.opam/4.00.1+mirage-xen`, with the compiler binaries in `~/.opam/4.00.1+mirage-xen/bin`, and any libraries installed into `~/.opam/4.00.1+mirage-xen/lib`. The `opam config` will detect the current compiler and output the correct PATH for your compiler installation.

Now try to compile up a Xen version of this website, via:
{{
$ cd mirage-www
$ make clean
$ make
}}

There will be a symbolic link to your Xen microkernel in the current working directory: learn how to run it [here](/wiki/xen-boot).

An alternative is to compile a UNIX binary that uses the Mirage network stack instead of kernel sockets. This is the `unix-direct` compiler variant, and requires the `tuntap` interface to be available on the UNIX host.

{{
$ opam switch 4.00.1+unix -a 4.00.1
$ opam install mirari
$ eval `opam config env`
}}

You can now recompile the `mirage-www` repository, and the resulting binary will serve HTTP traffic on `10.0.0.2` via the tuntap interface.
