---
updated: 2013-08-23
authors:
- name: Vincent Bernardoff
  uri: https://github.com/vbmithr
  email: vb@luminar.eu.org
subject: Introducing vchan
permalink: introducing-vchan
---

*Editor*: Note that some of the toolchain details of this blog post are
now out-of-date with Mirage 1.1, so we will update this shortly.

Unless you are familiar with Xen's source code, there is little chance
that you've ever heard of the *vchan* library or
protocol. Documentation about it is very scarce: a description can be
found on vchan's
[public header file](http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=xen/include/public/io/libxenvchan.h;hb=HEAD),
that I quote here for convenience:

> Originally borrowed from the
> [Qubes OS Project](http://www.qubes-os.org), this code (i.e. libvchan)
> has been substantially rewritten [...]
> This is a library for inter-domain communication.  A standard Xen ring
> buffer is used, with a datagram-based interface built on top.  The
> grant reference and event channels are shared in XenStore under a
> user-specified path.

This protocol uses shared memory for inter-domain communication,
i.e. between two VMs residing in the same Xen host, and uses Xen's
mechanisms -- more specifically,
[ring buffers](http://www.informit.com/articles/article.aspx?p=1160234&seqNum=3)
and
[event channels](http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=tools/libxc/xenctrl.h;h=f2cebafc9ddd4815ffc73fcf9e0d292b1d4c91ff;hb=HEAD#l934)
-- in order to achieve its aims. *Datagram-based interface* simply
means that the
[interface](http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=tools/libvchan/libxenvchan.h;h=6365d36a06f8c8f56454724cefc4c2f1d39beba2;hb=HEAD)
resembles UDP, although there is support for stream based communication (like
TCP) as well.

Over the last two months or so, I worked on a [pure OCaml
implementation](http://github.com/mirage/ocaml-vchan) of this library, meaning
that Mirage-based unikernels can now take full advantage of *vchan* to
communicate with neighboring VMs! If your endpoint -- a Linux VM or another
unikernel -- is on the same host, it is much faster and more efficient to use
vchan rather than the network stack (although unfortunately, it is currently
incompatible with existing programs written against the `socket` library under
UNIX or the `Flow` module of Mirage, although this will improve). It also
provides a higher level of security compared to network sockets as messages
will never leave the host's shared memory.

*Building the vchan echo domain*

Provided that you have a Xen-enabled machine, do the following from
dom0:

```
    opam install mirari mirage-xen mirage vchan
```

This will install the library and its dependencies. `mirari` is
necessary to build the *echo unikernel*:

```
    git clone git://github.com/mirage/ocaml-vchan
    cd test
    mirari configure --xen --no-install
    mirari build --xen
    sudo mirari run --xen
```

This will boot a `vchan echo domain` for dom0, with connection
parameters stored in xenstore at `/local/domain/<domid>/data/vchan`,
where `<domid>` is the domain id of the vchan echo domain. The echo
domain is simply an unikernel hosting a vchan server accepting
connections from dom0, and echo'ing everything that is sent to it.

The command `xl list` will give you the domain id of the echo
server.

*Building the vchan CLI from Xen's sources*

You can try it using a vchan client that can be found in Xen's sources
at `tools/libvchan`: Just type `make` in this directory. It will
compile the executable `vchan-node2` that you can use to connect to
our freshly created echo domain:

```
    ./vchan-node2 client <domid>/local/domain/<domid>/data/vchan
```

If everything goes well, what you type in there will be echoed.

You can obtain the full API documentation for *ocaml-vchan* by doing a
`cd ocaml-vchan && make doc`. If you are doing network programming
under UNIX, vchan's interface will not surprise you. If you are
already using vchan for a C project, you will see that the OCaml API
is nearly identical to what you are used to.

Please let us know if you use or plan to use this library in any way!
If you need tremedous speed or more security, this might fit your
needs.


