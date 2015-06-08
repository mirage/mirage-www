## Scenarios

Three scenarios need to work:

* Stub-domains for Xenstore and Xenconsoled. Device drivers (mainly netfront and blkfront) should compile on both Xen and Linux to let us swap between front-ends and back-ends as either stub-domain or dom0.

* Self-hosting website and DNS server (this one!).

* Proof concept of distributed system (ideally can be demo'd for OSCON). Current thinking is something like OCamlot or Signpost. This would be a nice "Hello world!" demo as it requires actors and a persistent job queue. For example, i.e spawning new VMs in response to load, as evidenced by self-scaling web-server.

## Repositories

All of these repositories need to be code-reviewed and run over with ocamldoc.  Purge the TODO hacks when you go over them, or explicitly pull them out into a top-level TODO file.
We need to close out this thread on a standard [repository format](https://lists.cam.ac.uk/pipermail/cl-mirage/2013-March/msg00099.html) for all these things.

Core Unix/Xen libraries:
* *shared-memory-ring*: Builds shared memory-based point-to-point communication protocols. Is reasonably mature and can be released. Can be used outside of Xen, need to benchmark vs c. 4.01.0dev ocaml improves perf with bigarray builtins. Implements the Xen ABI, but needs examples in-tree. (Owner: djs). For 1.0.
* *ocaml-xenstore*: Repo layout is confusing. Client and server in here, as well as Lwt bindings. Does build as stub domain and unix kernel. How can this stay in sync with xen-unstable? (Owner: djs). For 1.0.
* *ocaml-fd-send-recv*: UNIX only and trivial. Released and stable. For 1.0. (Owner: djs/vb)
* *ocaml-vchan*: Vchan communication channel between VMs.  Provides a socket-like interface between VMs.  For 1.0 (Owner: djs).  Post 2.0: vsock?
* *ocaml-qmp*: QEMU message-passing protocol to command a running qemu. Not for 1.0, really for advanced use (Owner: djs).
* *ocaml-gntshare*: Interface to mapping pages across Xen VMs. In ocaml-xen-lowlevel-libs, in good state, part of upstream xen-unstable and needs synching. (Owner: djs)
* *ocaml-xen-block-driver*: Successfully moved out, and works in Xen. It once worked in userspace. (Owner: djs/jonludlam). For 1.0.
* *ocaml-xen-net-driver*: Can be moved out, and works in Xen. It once worked in userspace. (Owner: djs/jonludlam). For 1.0.
* *xenbigarray*: OPAM switch hack to eliminate unix dependency. shouldnt be externally visible. (Owner: anil). For 1.0.

Core MirageOS libraries and tools:
* *mirage-platform*:
* *ocaml-cstruct*:
* *mirari*:
* *opam-repo-dev*:
* *dyntype*:
* *ocaml-re*: stable, done
* *opam*:
* *cross-ref ocamldoc*: leo

Storage libraries:
* *mirage-fs*: FAT not working as depends on Bitstring. Post 1.0, break out FAT into separate library. VB expressed interest in FAT.
* *orm*: Post 1.0, needs sqlite bindings
* *ocaml-crunch*: Works.
* *libvhd*: ?? Jon, suitable for block driver use?
* *ocaml-iscsi*: Doesnt exist, but djs really wants it.
* *cagit*: Needs a file system (Owner: tg).
* *irmin*: tg, not for 1.0
* *arakoon*: In-memory-only patch, Arakoon already functorised across the storage layer. For 1.0? to investigate

RPC/coordination:
* *rpc-light*: Works well, but slow and no wire protocol defined. Vb mentioned Thrift. Also have bin_io? No versioning story. Needs obuild help. (Owner: tg)
* *ocaml-actor*: non existent!
* *ocaml-fable*: on avsm repo only
* *message-switch*:
* *ocamlmq*: to investigate.
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

Cloud interfaces:
* *aws*: ec2 bindings, need porting to cohttp
* *ocaml-libvirt*: dave upstreaming
* *xenopsd*: convenient single-host daemon for ubuntu-unstable.


Testing:
* Ocamlot
* [Pathos](https://lists.cam.ac.uk/pipermail/cl-mirage/2013-February/msg00042.html) testing?

Tutorials and examples:
* *mirage-skeleton*:
* *mirage-tutorial*: out-of-date
* *mirage-www*: extract wiki/blog into library, make it not suck

## Misc

* Integrate `ocaml-tuntap` into `mirage-platform` to remove tun hacks [vincent]
* `mirari run` as a stateful process working with libvirt and EC2.
* cohttp/ssl releases [anil]
* obuild instead of oasis for core libraries for better cross-compilation/portability/speed
* Jenga? [dave]
