(based on the [article](http://queue.acm.org/detail.cfm?id=2566628) by Anil Madhavapeddy and David J. Scott)

Operating system virtualization such as Xen or VMWare allows to multiplex virtual machines (VMs) on a shared cluster of physical machines. Each VM presents as a self-contained computer, booting a standard OS kernel and running unmodified applications just as if it were executing on a physical machine.

While this is useful in many situations, it adds yet another layer to an already highly-layered software stack now including: support for old physical protocols (e.g. disk standards developed in the 80s such as IDE); irrelevant optimisations (e.g. disk elevator algorithms on SSD drives); backward-compatible interfaces (e.g. POSIX); user-space processes and threads (in addition to VMs on a hypervisor); managed code runtimes (e.g. OCaml, .NET or Java) which all sit beneath your application code. Are we really doomed to adding new layers of indirection and abstraction every few years, leaving future generations of programmers to become virtual archeologists as they dig through hundreds of layers of software emulation to debug even the simplest applications?

Our goal with MirageOS is to restructure entire VMs - including all kernel and userspace code - into more modular components that are flexible, secure and reusable in the style of a library operating system.


## Unikernels & Library operating system

Our architecture is dubbed unikernels. Unikernels are specialised OS kernels written in a high-level language which act as individual software components. A full application (or appliance) consists of a set of running unikernels working together as a distributed system.

<img src="/graphics/comparison-vm-unikernel.png" alt="Comparison between vm and unikernel" width="50%"/>

They are based on a radical operating system architecture from the 1990s, called library operating system (or libOS). In a libOS, protection boundaries are pushed to the lowest hardware layers, resulting in: (i) a set of libraries that implement mechanisms, such as those needed to drive hardware or talk network protocols; and (ii) a set of policies that enforce access control and isolation in the application layer.

The libOS architecture has several advantages over more conventional designs. For applications where performance is required, a libOS wins by allowing applications to access hardware resources directly without having to make repeated privilege transitions to move data between userspace and kernelspace. The libOS does not have a central "networking service" into which both high priority network packets (such as those from a video conference call) and low priority packets (such as from a background file download) are forced to mix, join the same queues and generally interfere. Instead libOS applications will have entirely separate queues, and packets will only mix together when they arrive at the network device itself.

A libOS running as a VM needs to implement drivers for the virtual hardware devices provided by the hypervisor. Furthermore it needs to create the protocol libraries to replace the services of a traditional OS. 


## Why OCaml

Modern kernels are all written in C, which excels at low-level programs such as device drivers but lacks the abstraction facilities of higher-level languages and demands careful manual tracking of resources such as memory buffers. Beside this high-level languages are steadily gaining ground in general application development, some of them include:

* Static type checking rejects unsafe code at compilation time rather than execution time

* Automatic memory management, which eliminiates many resource leaks.

* Modules help software development scale as internal implementation details can be abstracted 

* Metaprogramming: if the run-time configuration of a system is partially understood at compile-time, then a compiler can optimise the program much more than it would normally be able to

We chose OCaml as the sole base language for MirageOS. It is a full-fledged systems programming language with a flexible programming model that supports functional, imperative and object-oriented styles. It also features a portable single-threaded runtime that makes it ideal for porting to restricted environments such as a barebones Xen VM. The compiler heavily emphasises static type checking, and the resulting binaries are fast native code with no runtime type information and the module system is among the most powerful in a general-purpose programming language in terms of permitting flexible and safe code reuse and refactoring. Finally, we had several examples of large-scale uses of OCaml in industry at Jane Street and within Xen itself, and the positive results were encouraging before embarking on the large multi-year project that MirageOS turned out to be.


## Modular OS Libraries

Mirage provides modular OS libraries, which can be switched when needed.

<img src="/graphics/mirage-sample-application.png" alt="example" width="50%"/>

The application MyHomePage depends on an HTTP signature that is provided by the Cohttp library. A developer just starting out wants to explore their code interactively using a Unix-style development environment. The Cohttp library needs a TCP implementation to satisfy its module signature, which can be provided by the UnixSocket library. When development is finished, the on Unix is entirely dropped, and the application is recompiled using the MirNet module to directly link against a Xen network driver, which in turn pulls in all the dependencies it needs to boot on Xen.


## Development Workflow

* **Build System**: All source code dependencies of the input application
are explicitly tracked, including all the libraries required to implement kernel functionality

* **Compiler**: The compiler outputs a full standalone kernel instead of just a Unix executable. It is linked against a minimal embedded runtime which provides boot support and the garbage collector. There is no preemptive threading and the kernel is
event-driven via an I/O loop that polls Xen devices.

* **Deployment**: The specialized unikernels are deployed online on the public cloud and are recompiled to reconfigure them. They have a significantly smaller attack surface than
the conventional virtualized equivalents, and are more  resource-efficient in terms of boot time, binary size and runtime performance.


## Other Unikernels
MirageOS is certainly not the only unikernel for Xen that has emerged in the last few years:

* Haskell: [HalVM](https://github.com/GaloisInc/HaLVM#readme)
* Erlang: [ErlangOnXen](http://erlangonxen.org)
* Java: [GuestVM](https://kenai.com/projects/guestvm) 

