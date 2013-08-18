[*N.B.  Due to continuing development, some of the details in this blog post are now out-of-date. It is archived here.* ]

Something we've been working on for a little while now that we're pretty
excited about is an [OpenFlow](http://openflow.org/) implementation for
Mirage. For those who're not networking types, in short, OpenFlow is a
protocol and framework for devolving network control to software running on
platforms other than the network elements themselves. It consists of three
main parts:

* a *controller*, responsible for exercising control over the network;
* *switches*, consisting of switching hardware, with flow tables that apply
  forwarding behaviours to matching packets; and
* the *protocol*, by which controllers and switches communicate.

For more -- and far clearer! -- explanations, see any of the many online
OpenFlow resources such as [OpenFlowHub](http://openflowhub.org).

Within Mirage we have an OpenFlow implementation in two parts: individual
libraries that provide controller and switch functionality. Linking the switch
library enables your application to become a software-based OpenFlow switch.
Linking in the controller library enables your application to exercise direct
control over OpenFlow network elements. 

The controller is modelled after the [NOX](http://noxrepo.org/) open-source
controller and currently provides only relatively low-level access to the
OpenFlow primitives: a very cool thing to build on top of it would be a
higher-level abstraction such as that provided by
[Nettle](http://haskell.cs.yale.edu/?page_id=376) or
[Frenetic](http://www.frenetic-lang.org/).

The switch is primarily intended as an experimental platform -- it is
hopefully easier to extend than some of the existing software switches while
still being sufficiently high performance to be interesting! 

By way of a sample of how it fits together, here's a skeleton for a simple
controller application:

{{
type mac_switch = {
  addr: OP.eaddr; 
  switch: OP.datapath_id;
}

type switch_state = {
  mutable mac_cache: 
        (mac_switch, OP.Port.t) Hashtbl.t;
  mutable dpid: OP.datapath_id list
}

let switch_data = {
  mac_cache = Hashtbl.create 7; 
  dpid = [];
} 

let join_cb controller dpid evt =
  let dp = match evt with
      | OE.Datapath_join c -> c
      | _ -> invalid_arg "bogus datapath_join"
  in 
  switch_data.dpid <- switch_data.dpid @ [dp]

let packet_in_cb controller dpid evt =
  (* algorithm details omitted for space *)

let init ctrl = 
  OC.register_cb ctrl OE.DATAPATH_JOIN join_cb;
  OC.register_cb ctrl OE.PACKET_IN packet_in_cb

let main () =
  Net.Manager.create (fun mgr interface id ->
    let port = 6633 in 
    OC.listen mgr (None, port) init
  )
}}

We've written up some of the gory details of the design, implementation and
performance in a [short paper](/docs/iccsdn12-mirage.pdf) to the
[ICC](http://www.ieee-icc.org/)
[Software Defined Networking](http://sdn12.mytestbed.net/) workshop. Thanks to
some sterling work by [Haris](http://www.cl.cam.ac.uk/~cr409/) and
[Balraj](mailto:balraj.singh@cl.cam.ac.uk), the headline numbers are pretty
good though: the unoptimised Mirage controller implementation is only 30--40%
lower performance than the highly optimised NOX *destiny-fast* branch, which
drops most of the programmability and flexibility of NOX; but is about *six
times* higher performance than the fully flexible current NOX release. The
switch's performance  running as a domU virtual machine is indistinguishable
from the current [Open vSwitch](http://openvswitch.org/) release.

For more details see [the paper](/docs/iccsdn12-mirage.pdf) or contact
[Mort](mailto:mort@cantab.net),
[Haris](mailto:charalampos.rotsos@cl.cam.ac.uk) or
[Anil](mailto:anil@recoil.org). Please do get in touch if you've any comments
or questions, or you do anything interesting with it!
