!Developer Preview Checklist

!!Scenarios

Three scenarios need to work:

* Stub-domains for Xenstore and Xenconsoled. Device drivers (mainly netfront and blkfront) should compile on both Xen and Linux to let us swap between front-ends and back-ends as either stub-domain or dom0.

* Self-hosting website and DNS server (this one!).

* Proof concept of distributed system (ideally can be demo'd for OSCON). Current thinking is something like OCamlot or Signpost. This would be a nice "Hello world!" demo as it requires actors and a persistent job queue. For example, i.e spawning new VMs in response to load, as evidenced by self-scaling web-server.

!!TODO

* Integrate `ocaml-tuntap` into `mirage-platform` to remove tun hacks [vincent]
* `mirari run` as a stateful process working with libvirt and EC2.
* cohttp/ssl releases [anil]
* obuild instead of oasis for core libraries for better cross-compilation/portability/speed
* Jenga? [dave]

!!Repositories

All of these repositories need to be code-reviewed and run over with ocamldoc.  Purge the TODO hacks when you go over them, or explicitly pull them out into a top-level TODO file.
We need to close out this thread on a standard [repository format](https://lists.cam.ac.uk/pipermail/cl-mirage/2013-March/msg00099.html) for all these things.

Core Unix/Xen libraries:
* *shared-memory-ring*: can be used outside of xen, need to benchmark vs c. 4.01.0dev ocaml improves perf with bigarray builtins.
* *ocaml-xenstore*: client and server in here I think.
* *ocaml-fd-send-recv*: on djs repo only
* *ocaml-vchan*: (in djs repo only)
* *ocaml-qmp*: QEMU protocol (in djs repo only)
* *ocaml-xen-block-driver*: (in djs repo only)
* *ocaml-xen-net-driver*: todo, needs to compile in userspace too
* *xenbigarray*: opam switch hack to eliminate unix dependency. shouldnt be externally visible.

Cloud interfaces:
* *aws*: ec2 bindings, need porting to cohttp
* *ocaml-libvirt*: dave upstreaming
* *xenopsd*: convenient single-host daemon for ubuntu-unstable.

Core Mirage libraries and tools:
* *mirage-platform*:
* *ocaml-cstruct*:
* *mirari*:
* *opam-repo-dev*:
* *dyntype*:
* *ocaml-re*: stable, done
* *opam*: 
* *cross-ref ocamldoc*: leo

Storage libraries:
* *mirage-fs*:
* *orm*:
* *ocaml-crunch*:
* *libvhd*: jon, suitable for block driver use?
* *ocaml-iscsi*: djs?

RPC/coordination:
* *rpc-light*: desire to replace with binprot?
* *shelf*:
* *ocaml-actor*: non existent!
* *ocaml-fable*: on avsm repo only 
* *message-switch*: 
* *logger*: need a vchan-based logger and CLI to access from other domain

Protocols:
* *ocaml-dns*:
* *mirage-net*:
* *ocaml-pcap*:
* *ocaml-openflow*:
* *ocaml-xmpp*: ermine repos, lwt, need porting to mirage-net

Security:
* *mirage-cryptokit*:
* *ocaml-crypto-keys*:
* *stud*: need ssl binding for fable
* *ocaml-ssh*: still in mpl-land, not too hard to port

Webby libraries:
* *ocaml-cohttp*: 
* *ocaml-cow*:
* *ocaml-uri*:
* *ocaml-spdy*: out of date, not for 1.0

Testing:
* Ocamlot
* [Pathos](https://lists.cam.ac.uk/pipermail/cl-mirage/2013-February/msg00042.html) testing?

Tutorials and examples:
* *mirage-skeleton*:
* *mirage-tutorial*: out-of-date
* *mirage-www*: extract wiki/blog into library, make it not suck
