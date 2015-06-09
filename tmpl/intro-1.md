MirageOS is a library operating system that constructs [unikernels](http://queue.acm.org/detail.cfm?id=2566628)
for secure, high-performance network applications across a variety
of cloud computing and mobile platforms.  Code can be developed on a normal OS
such as Linux or MacOS X, and then compiled into a fully-standalone,
specialised unikernel that runs under the [Xen](http://xen.org/) hypervisor.

Since Xen powers most public [cloud computing](http://en.wikipedia.org/Cloud_computing)
infrastructure such as [Amazon EC2](http://aws.amazon.com) or [Rackspace](http://rackspace.com/cloud),
this lets your servers run more cheaply, securely and with finer control than
with a full software stack.

MirageOS uses the [OCaml](http://ocaml.org/) language, with libraries that
provide networking, storage and concurrency support that work under Unix during
development, but become operating system drivers when being compiled for
production deployment. The framework is fully event-driven, with no support for
preemptive threading.
