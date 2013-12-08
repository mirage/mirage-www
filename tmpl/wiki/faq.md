! Frequently asked questions

!!! Is Mirage 'still' Linux? Does it require a Linux host on which to run?

Mirage is a '[library operating system](http://anil.recoil.org/papers/2013-asplos-mirage.pdf‎)',
which means that it can run on any target for which a suitable bootloader 
and drivers exist.  The first two targets are Unix and Xen, but we have 
prototypes that compile the same application source code (e.g. the Mirage 
website) to run as kernel modules inside FreeBSD, or even to JavaScript.
Mirage provides support to more easily target such diverse environments due 
to its emphasis on modular programming and compile-time specialisation.  
We'll have a series of blog posts over December with tutorials on how the 
FreeBSD/kernel and JavaScript targets work, to aid developers who wish to 
port other environments such as the Raspberry Pi, Docker, Linux kernel 
modules, or to other hypervisors such as KVM.


!!! Is Mirage v1.0 'production ready'? 

The 1.0 release is the first 'stable toolkit' release that is sufficient to 
self-host its infrastructure on the Internet.  It is a baseline for the 
early adopters of Mirage to integrate it into their own products, such as 
XenServer (whose management stack is written in OCaml and already uses some 
of the Mirage libraries).  We are also conducting research into novel 
databases, filesystems and security technologies at Cambridge that use 
Mirage as the baseline to build complex distributed systems.  The 1.0 
release is still missing some significant functionality (such as SSL 
support), but development is proceeding fast to plug these gaps in 2014.

More immediately, and in addition to the XenServer integration, members of 
the team (and we hope others) will be using Mirage to create and manage 
their own VMs for websites and blogs!


!!! How does Mirage compare against other cloud-friendly OS options (e.g  like OSv) and also different approaches like like containers (e.g Docker)?

Mirage represents our desire for a radically simpler way of building complex 
distributed systems using a modern modular, functional and type-safe 
programming language such as OCaml.  Unlike other cloud-friendly operating 
systems such as OSv, we do not attempt to optimize *existing* code, but 
instead focus on a toolkit to make it easier to quickly assemble *new* 
systems without having to be a domain expert in (e.g.) kernel programming.

The downside to our approach is that we only work with open protocols, since 
we cannot build clean-slate versions of closed protocols for which we have 
no specification.  On the other hand, the 1.0 release contains clean-slate 
libraries for TCP/IP, DNS, Xen device drivers, VNC, HTTP and other common 
Internet protocols, but all written in a completely type-safe fashion so 
that they are resistant to attacks such as buffer overflows that are 
plaguing the Internet. There's a good chance that a few years from now, 
existing systems will still be suffering those attacks, but Mirage will 
continue to grow and mature its protocol implementations without sacrificing 
safety. 


!!! What's next for the Mirage project?

Xen has thrown open the doors to experimental new operating systems such as 
ours, and it is fitting that we (as Xen developers too) improve the state of 
cloud management toolstacks.  Many of the 1.0 Mirage libraries (such as the 
device driver implementations) are being used in XenServer as part of the 
disaggregation of the monolithic driver domain into multiple, 
less-privileged "stub domains". While the low-level plumbing for stub 
domains has existed for some years, they are difficult to build and debug in 
practise.  Mirage's first major application is to transform the XAPI control 
stack into a standalone distributed system that can run an entire cluster of 
hosts with a greater degree of reliability, security and scalability than 
exists today.

Back in the Cambridge Computer Laboratory, we are embarking on several 
major, multi-year projects that use Mirage at their heart.  The 
[User Centric Networking](http://usercentricnetworking.eu) project (with 
Nottingham and Technicolor among others) is building a privacy-preserving 
distributed system for recommender and content delivery systems.  Instead of 
a monolithic cloud storing our personal data, we are porting Mirage to 
Xen/ARM and deploying small, energy efficient devices inside people's homes. 
This "personal information hub" will talk to third-party service providers 
and control what personal data is transmitted and allow users to balance 
their desire for social networking vs the cost of privacy breaches.

We've built prototypes of this technology in the past in Cambridge, but 
discovered that securing and managing embedded devices running Linux and C 
code is incredibly difficult.  Cloud providers employ an army of security 
professions to secure their perimeters, but embedded devices do not have 
this luxury.  Since OCaml has supported fast native code compilation to ARM 
for over a decade, Mirage provides the perfect balance of resource 
efficiency and security to drive these embedded systems and benefit the 
coming wave of Internet of Things.

OCaml (the programming language that we use under the hood of Mirage) also 
has deep connections to the formal methods community, with other major tools 
such as Coq (a widely used theorem prover) and CompCert (a verified C 
compilers) written in it.  We have several initiatives ([http://rems.io](http://rems.io)) 
ongoing to verify components of Mirage (such as the garbage collector), to 
support hardware compilation to FPGAs for data centers (via the EPSRC-funded 
Network-as-a-Service project) and support new experimental CPU targets such 
as the [BERI processor](http://www.cl.cam.ac.uk/research/security/ctsrd/beri.html). 
We're extremely grateful to our research funding bodies (RCUK, EPSRC, EU FP7 
and DARPA) for supporting such long-term research and making Mirage possible.
[Jane Street](http://janestreet.com) and [Citrix](http://www.citrix.com) 
have also contributed funding and expertise for an entire research group 
called [OCaml Labs](http://www.cl.cam.ac.uk/projects/ocamllabs/) in the 
Cambridge Computer Lab. to bolster the continued growth of the functional 
programming ecosystem.  Anil has also recently published an O'Reilly book 
called Real World OCaml that's freely available at 
[https://realworldocaml.org](https://realworldocaml.org).

Last, but not least, it's simply more fun as a programmer to be able to 
regain flexibility with the Mirage approach. Too much of modern systems 
construction involves wrestling with configuration files and mystical kernel 
policies.  While Mirage is obviously not going to replace Windows any time 
soon, it's a lot more enjoyable to use and develop code it in its chosen 
problem domain of building server systems.  Several of the developers have 
rewritten their own homepages in Mirage and are hosting them on EC2, and 
Anil is experimenting with writing Oculus VR applications in Mirage and WebGL...





