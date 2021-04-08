MirageOS is a library operating system that constructs [unikernels](https://en.wikipedia.org/wiki/Unikernel)
for secure, high-performance network applications across a variety
of cloud computing and mobile platforms.  Code can be developed on a normal OS
such as Linux or MacOS X, and then compiled into a fully-standalone,
specialised unikernel that runs under a [Xen](https://xenproject.org) or [KVM](http://www.linux-kvm.org/page/Main_Page) hypervisor.

This lets your services run more efficiently, securely and with finer control than
with a full conventional software stack.

MirageOS uses the [OCaml](https://ocaml.org/) language, with [libraries](https://docs.mirage.io) that
provide networking, storage and concurrency support that work under Unix during
development, but become operating system drivers when being compiled for
production deployment. The framework is fully event-driven, with no support for
preemptive threading.
