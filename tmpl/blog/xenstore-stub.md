On all hosts running [xen](http://www.xen.org/), there is a critical service called [xenstore](http://wiki.xen.org/wiki/XenStore).
Xenstore is used to allow *untrusted* user VMs to communicate with *trusted* system VMs, so that

* virtual disk and network connections can be established
* performance statistics and OS version information can be shared
* VMs can be remotely power-cycled, suspended, resumed, snapshotted and migrated.

If the xenstore service fails then at best the host cannot be controlled (i.e. no VM start or shutdown)
and at worst VM isolation is compromised since an untrusted VM will be able to gain unauthorised access to disks or networks.

Recently in the Xen community, Daniel De Graaf and Alex Zeffertt have added support for
[xenstore stub domains](http://lists.xen.org/archives/html/xen-devel/2012-01/msg02349.html)
where the xenstore service is run directly as an OS kernel in its own isolated VM (in the world of xen
a running VM is a "domain" and a "stub" implies a single-purpose OS image rather than a general-purpose
machine).
Previously if something bad happened in "domain 0" (the privileged general-purpose OS where xenstore traditionally runs)
such as an out-of-memory event or a performance problem, then the critical xenstore process might become unusable
or fail altogether. Instead if xenstore is run as a "stub domain" then it is immune to such problems in
domain 0 and in fact it will even allow us to *reboot* domain 0 in future (along with all other privileged
domains) without incurring VM downtime.

The new code in [xen-unstable.hg](http://xenbits.xensource.com/xen-unstable.hg) lays the necessary groundwork
(xen and domain 0 kernel changes) and ports the original C xenstored to run as a stub domain.

Meanwhile, thanks to Vincent Hanquez and Thomas Gazagnaire, we also have an
[ocaml implementation of xenstore](http://gazagnaire.org/pub/SSGM10.pdf) which, as well as the offering
memory-safety, also supports a high-performance transaction engine, necessary for surviving a stressful
"VM bootstorm" event on a large server in the cloud. Vincent and Thomas' code is Linux/POSIX only.

Ideally we would have the best of both worlds:

* a fast, memory-safe xenstored written in ocaml,
* running directly as a stub domain i.e. as a kernel image without Linux or POSIX

*Thanks to opam and mirage we can do both.*

If you're saying, "that sounds great! How do I do that?" then read on...

*Step 1: remove dependency on POSIX/Linux*

If you read through the existing ocaml xenstored code, it becomes obvious that the main uses of POSIX APIs are for communication
with clients, both Unix sockets and for a special xen inter-domain shared memory interface. It was a fairly
painless process to extract the required socket-like IO signature and turn the bulk of the server into
a functor. The IO signature ended up looking approximately like:

{{
    type t
    val read: t -> string -> int -> int -> int Lwt.t
    val write: t -> string -> int -> int -> unit Lwt.t
    val destroy: t -> unit Lwt.t
}}

(For now the dependency on [Lwt](http://ocsigen.org/lwt/) is explicit but in future I'll probably make it more abstract so we
can use [Core Async](https://ocaml.janestreet.com/?q=node/100) too)

*Step 2: add a mirage xen IO implementation*

In a stub-domain all communication with other domains is via shared memory pages and "event channels".
Mirage already contains extensive support for using these primitives, and uses them to create fast
network and block virtual device drivers. To extend the code to cover the xenstore stub domain case,
only a few tweaks were needed to add the "server" side of a xenstore ring communication, in addition
to the "client" side which was already present.

In xen, domains share memory by a system of explicit "grants", where a client (called "frontend")
tells the hypervisor to allow a server (called "backend") access to specific memory pages. Mirage
already had code to create such grants, all that was missing was a few simple functions to receive
grants from other domains.

These changes are all in the current [mirage-platform](https://github.com/mirage/mirage-platform)
tree.

*Step 3: add a mirage xen "main" module and Makefile*

The mirage "main" module necessary for a stub domain looks pretty similar to the normal Unix
userspace case except that it:

* arranges to log via the console (rather than a file or the network, since a disk or network connection cannot be established without a working xenstore and it's important not to introduce a bootstrap
     problem here)
* instantiates the server functor with the shared memory inter-domain IO module.

The Makefile looks like a regular Makefile, invoking ocamlbuild. The whole lot is built with
[OASIS](http://oasis.forge.ocamlcore.org/) with a small extension added by [Anil](http://anil.recoil.org/) to set a few options
required for building xen kernels rather than regular binaries.

... and it all works!

The code is in two separate repositories:
* [ocaml-xenstore](https://github.com/djs55/ocaml-xenstore): contains all the generic stuff
* [ocaml-xenstore-xen](https://github.com/djs55/ocaml-xenstore-xen): contains the unix userspace
    and xen stub domain IO modules and "main" functions

*Example build instructions*

If you want to try building it yourself, try the following on a modern 64-bit OS. I've tested these
instructions on a fresh install of Debian Wheezy.


First install ocaml and the usual build tools
{{
    apt-get install ocaml build-essential git curl rsync
}}
Then install the OcamlPro "opam" package manager to simplify the installation of extra packages
{{
    git clone git://github.com/OCamlPro/opam.git
    cd opam
    make
    make install
    cd ..
}}
Initialise opam with the default packages (this needs a funny URL until version 0.4 is released)
{{
    opam --yes init default git://github.com/mirage/opam-repository
    eval `opam config -env`
}}
Add the "mirage" development package source (this step will not be needed once the package definitions are upstreamed)
{{
    opam remote -add dev git://github.com/mirage/opam-repo-dev
}}
Switch to the special "mirage" version of the ocaml compiler
{{
    opam --yes switch -install 3.12.1+mirage-xen
    opam --yes switch 3.12.1+mirage-xen
    eval `opam config -env`
}}
Install the generic xenstore protocol libraries
{{
    opam --yes install xenstore
}}
Install the "mirage" development libraries
{{
    opam --yes install mirage
}}
If this fails with "+ runtime/dietlibc/lib/atof.c:1: sorry, unimplemented: 64-bit mode not compiled in" it means you need a 64-bit build environment.
Next, clone the xen stubdom tree
{{
    git clone git://github.com/djs55/ocaml-xenstore-xen
}}
Build the xen stubdom
{{
    cd ocaml-xenstore-xen
    make
}}
The binary now lives in "xen/_build/src/server_xen.xen"

*Deploying on a xen system*

Running a stub xenstored is a little tricky, because it depends on the latest and
greatest xen and Linux PVops kernel. In the future it'll become much easier (and probably
the default) but for now you need the following:

* xen-4.2 with XSM (Xen Security Modules) turned on
* A XSM/FLASK policy which allows the stubdom to call the "domctl getdomaininfo". For the moment it's safe to skip this step with the caveat that xenstored will leak connections when domains die.
* a xen-4.2-compatible toolstack (either the bundled xl/libxl or xapi with [some patches](http://github.com/djs55/xen-api/tree/xen-4.2))
* linux-3.5 PVops domain 0 kernel
* the domain builder binary "init-xenstore-domain" from xen-4.2/tools/xenstore.

To turn the stub xenstored on, you need to edit whichever init.d script is currently starting xenstore and modify it to call
{{
    init-xenstore-domain /path/to/server_xen.xen 256 flask_label
}}
