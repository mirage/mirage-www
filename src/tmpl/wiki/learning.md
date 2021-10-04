
# How to learn about Mirage

The Mirage [community](/community) is very welcoming of newcomers; your
optimal learning route is try out the software on your own development
machine, then familiarise yourself with the various backends and the
main modules and techniques used in building and running real unikernels.

If you know some OCaml but don't know about Mirage, your first steps should
be to try either our [Hello Mirage World](/wiki/hello-world) tutorial, or go
directly to building some of the example apps in [Mirage Skeleton](https://github.com/mirage/mirage-skeleton).

Mirage abstracts away various OS-level functionality (e.g., networking
and storage), which must be provided by backends. Commonly used
backends are `unix`, `hvt` and `xen`; the `unix` backend works within
a normal laptop-based development environment. The others tend to
involve various degrees of configuration effort, but are more
realistic for production use. You can write your code, test it on `unix` first,
and later adapt your environment to run one of the other backends.

## How to get help

A brief survey of the Mirage development community revealed that the
preferred method of getting help is the email mailing list: the core
developers all read it. Mailing lists aren't for everyone, so here are
the alternatives, roughly in descending order of preference:

* [the mailing list](http://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel)
* filing Issue tickets on relevant [Github repositories](https://github.com/mirage)
* [The OCaml message board](https://discuss.ocaml.org/)
* `#mirage` on the freenode IRC network

## Typical development workflow

When checking out an example project, a typical workflow would look something
like this:

```bash
    $ mirage configure -t unix
    $ make depends
    $ make
    $ dist/main
```

Be aware that the behaviour of `mirage configure` depends intimately on the
contents of the `config.ml` file in your current directory. This is true
even of its command-line options. It follows that the syntax you observe
in one tutorial or project may not always carry across to another.

The `mirage configure` phase does the heavy lifting to resolve what
code must be available for the backend you specify. The backend is
specified with the `-t` option.

## What are backends?

Backends include:

* `unix` (runs as a normal UNIX process)
* `hvt` ([runs](https://github.com/Solo5/solo5/blob/v0.6.3/docs/building.md) on Linux, FreeBSD, and OpenBSD, requires hardware virtualization)
* `virtio` ([runs](https://github.com/Solo5/solo5/blob/v0.6.3/docs/building.md) on various virtio-based hypervisors and clouds)
* `xen` and `qubes` (run as a PV domain on the [Xen](https://www.xenproject.org/) hypervisor)
* `muen` (runs as a subject on the [Muen Separation Kernel](https://muen.sk/))

The backends above are listed in ascending order of invasiveness. `unix` runs
as a normal process on your unmodified Linux kernel, albeit it may
require root privileges. `hvt` uses
[Solo5](https://github.com/Solo5/solo5/tree/v0.6.3) and hardware virtualization on Linux and FreeBSD, which entails some setup
work, e.g., of IP routing. `xen` requires that Xen be run underneath your
operating system(s), and that Mirage will be run directly on top of Xen.
Installing Xen is not hard (about 20 minutes), and it may conveniently
co-exist as a dual-booted environment if you don't want to dedicate your
host machine exclusively to it.

## Configuration

For now, see the [relevant blog post](/blog/introducing-functoria).

Mirage effectively treats functionality such as persistent storage, networking,
protocols, etc, as libraries. The configuration phase for Mirage determines
which implementations of these libraries will be compiled into your unikernel.
