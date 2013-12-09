

We're very pleased to announce the release of MirageOS 1.0. This is the first major release of MirageOS and represents several years of development, testing and community building. You can get started by following the [install instructions][mirage-install] and creating your own webserver to host a static website!

!! What is MirageOS and why is it important?

Most applications that run in the cloud aren't optimised to do so. They
inherently carry assumptions about the underlying operating system with
them, including vulnerabilities and bloat.

Compartmentalisation of large servers into smaller 'virtual machines' has
enabled many new businesses to get started and achieve scale. This has been
great for new services but many of those virtual machines are single-purpose
and yet they contain largely complete operating systems which typically run
single applications like web-servers, load balancers, databases, mail servers and similar services. This means a large part of the footprint is
unused and unnecessary, which is both costly due to resource usage (RAM, disk space etc) and a security risk due to the increased complexity of the system and the larger attack surface.

MirageOS is a [Cloud Operating System][cloudos] which represents an approach where only the necessary components of the operating system are included and compiled along with the application into a 'unikernel'. This results in highly efficient and extremely lean 'appliances', with the same or better functionality but a much smaller footprint and attack surface. These appliances can be deployed directly to the cloud and embedded devices, with the benefits of reduced costs and increased security and scalability.

Some example use cases for MirageOS include: (1) A lean webserver, for example the [openmirage.org][mirage-www], website is about 1MB including all content, boots in about 1 second and is hosted on Amazon EC2. (2) Middle-box applications such as small OpenFlow switches for tenants in a cloud-provider. (3) Easy reuse of the same code and toolchain that create cloud appliances to target the space and memory constrained ARM devices.

!!! How does MirageOS work?

<img src="/graphics/comparison-vm-unikernel.png" alt="Comparison between vm and unikernel" width="50%"/>

MirageOS works by treating the Xen hypervisor as a stable hardware platform and using libraries to provide the services and protocols we expect from a typical operating system, e.g. a networking stack. Application code is developed in a high-level functional programming language ([OCaml][ocaml.org]) on a desktop OS such as Linux or Mac OSX, and compiled into a fully-standalone, specialised unikernel. These unikernels run directly on Xen hypervisor APIs. Since Xen powers most public clouds such as Amazon EC2, Rackspace Cloud, and many others, MirageOS lets your servers run more cheaply, securely and faster on those services.

MirageOS is implemented in the OCaml language, with [50+ libraries][mirage-libs] which map directly to operating system constructs when being compiled for production deployment. The goal is to make it as easy as possible to create MirageOS appliances and ensure that all the things found in a typical operating system stack are still available to the developer. MirageOS includes clean-slate functional implementations of protocols ranging from TCP/IP, DNS, SSH, Openflow (switch/controller), HTTP, XMPP and Xen Project inter-VM transports. Since everything is written in a single high-level language, it is easier to work with those libraries directly. This approach guarantees the best possible performance of MirageOS on the Xen Hypervisor without needing to support the thousands of device drivers found in a traditional OS.

An example of a MirageOS appliance is a DNS server and below is a comparison with one of the most widely deployed DNS servers on the internet, BIND 9. As you can see, the MirageOS appliance outperforms BIND 9 but in addition, the MirageOS VM is less than 200kB in size compared to over 450MB for the BIND VM. Moreover, the traditional VM contains 4-5 times more lines of code than the Mirage implementation, and lines of code are often considered correlated with attack surface. More detail about this comparison and others can be found in the associated [ASPLOS paper][].

<img src="/graphics/mirage-dns-bw-360.png" alt="Comparison between BIND and MirageDNS"/>

For the DNS appliance above, the application code was written using OCaml and compiled with the relevant MirageOS libraries. To take full advantage of MirageOS it is necessary to design and construct applications using OCaml, which provides a number of additional benefits such as type-safety. For those new to OCaml, there are some excellent resources to get started with the language, including a new book [from O'Reilly][oreilly] and a range of [tutorials][] on the revamped [OCaml website][ocaml.org].

We look forward to the exciting wave of innovation that MirageOS will unleash including more resilient and lean software as well as increased developer productivity.

[mirage-install]: http://openmirage.org/wiki/install
[rwo]: https://realworldocaml.org
[oreilly]: http://shop.oreilly.com/product/0636920024743.do
[tutorials]: http://ocaml.org/learn/tutorials/
[ocaml.org]: http://ocaml.org
[mirage-libs]: https://github.com/mirage
[mirage-www]: http://openmirage.org
[mirage-decks]: http://decks.openmirage.org
[4]: http://anil.recoil.org/papers/2011-icdcn-droplets.pdf
[16]: http://anil.recoil.org/papers/2010-iswp-dustclouds.pdf
[cstruct]: https://github.com/mirage/ocaml-cstruct
[frenetic]: http://www.frenetic-lang.org
[XenServer]: http://www.xenserver.org
[cloudos]: http://www.linux.com/news/enterprise/cloud-computing/751156-are-cloud-operating-systems-the-next-big-thing-
[ASPLOS paper]: http://anil.recoil.org/papers/2013-asplos-mirage.pdf

