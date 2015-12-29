Almost every network needs to support [DHCP]
(https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) (Dynamic
Host Configuration Protocol), that is, a way for clients to request network
parameters from the environment. Common parameters are an IP address, a network
mask, a default gateway and so on.

DHCP can be seen as a critical security component, since it deals usually with
unauthenticated/unknown peers, therefore it is of special interest to run a
server as a self-contained MirageOS VM.

[Charrua](http://www.github.com/haesbaert/charrua-core) is a DHCP implementation
written in OCaml, it started off as an excuse to learn more about the language,
while in development it got picked up on the MirageOS mailing lists and became one
of the [Pioneer
Projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects).

The name `Charrua` is a reference to the, now extinct, semi-nomadic people of
southern South America, nowadays it is also used to refer to Uruguayan
nationals. The logic is that DHCP handles dynamic (hence nomadic) clients.

The library is platform agnostic and works outside of MirageOS as well, it
provides two main modules:
[Dhcp_wire](http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html) and
[Dhcp_server](http://haesbaert.github.io/charrua-core/api/Dhcp_server.html).

### Dhcp_wire

[Dhcp_wire](http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html) provides
basic functions for dealing with the protocol, essentialy
marshalling/unmarshalling and helpers for dealing with the various DHCP options.

The central record type of
[Dhcp_wire](http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html) is a
[pkt](http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html#TYPEpkt), which
represents a full DHCP packet, including layer 2 and layer 3 data as well as the
many possible DHCP options. The most important functions are:

```ocaml
val pkt_of_buf : Cstruct.t -> int -> [> `Error of string | `Ok of pkt ]
val buf_of_pkt : pkt -> Cstruct.t
```

[pkt_of_buf]
(http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html#VALpkt_of_buf) takes
a [Cstruct.t] (https://github.com/mirage/ocaml-cstruct) buffer and a length, it
then attempts to build a DHCP packet, unknown DHCP options are ignored, invalid
options or malformed data is not accepted and you get a `` `Error of string``.

[buf_of_pkt]
(http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html#VALbuf_of_pkt) is
the mirror function, but it never fails, it could for instance fail in case of
two duplicate DHCP options, but that would imply too much policy in a
marshalling function.

The DHCP options from RFC2132 are implemented in
[dhcp_option](http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html#TYPEdhcp_option),
there are more, but the most common ones look like this:

```ocaml
type dhcp_option =
  | Subnet_mask of Ipaddr.V4.t
  | Time_offset of int32
  | Routers of Ipaddr.V4.t list
  | Time_servers of Ipaddr.V4.t list
  | Name_servers of Ipaddr.V4.t list
  | Dns_servers of Ipaddr.V4.t list
  | Log_servers of Ipaddr.V4.t list
```

### Dhcp_server

[Dhcp_server](http://haesbaert.github.io/charrua-core/api/Dhcp_server.html)
Provides a library for building DHCP server, it is divided into two sub-modules:
[Config](http://haesbaert.github.io/charrua-core/api/Dhcp_server.Config.html),
which handles the building of a suitable DHCP server configuration record and
[Input](http://haesbaert.github.io/charrua-core/api/Dhcp_server.Config.html),
which handles the input of DHCP packets.

The logic is modeled in a pure functional style,
[Dhcp_server](http://haesbaert.github.io/charrua-core/api/Dhcp_server.html) does
not perform any IO of its own, it works by taking an input
[packet](http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html#TYPEpkt),
 a
 [configuration](http://haesbaert.github.io/charrua-core/api/Dhcp_server.Config.html#TYPEt)
 and returns a possible reply to be sent by the caller, or an error/warning:

#### Input

```ocaml
type result = 
| Silence                 (* Input packet didn't belong to us, normal nop event. *)
| Reply of Dhcp_wire.pkt  (* A reply packet to be sent on the same subnet. *)
| Warning of string       (* An odd event, could be logged. *)
| Error of string         (* Input packet is invalid, or some other error ocurred. *)

val input_pkt : Dhcp_server.Config.t -> Dhcp_server.Config.subnet ->
   Dhcp_wire.pkt -> float -> result
(** input_pkt config subnet pkt time Inputs packet pkt, the resulting action
    should be performed by the caller, normally a Reply packet is returned and
    must be sent on the same subnet. time is a float representing time as in
    Unix.time or MirageOS's Clock.time. **)
```

A typical main server loop would work by:
 1. Reading a packet from the network.
 2. Unmarshaling with [Dhcp_wire.pkt_of_buf]
(http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html#VALpkt_of_buf).
 3. Inputing the result with [Dhcp_server.Input.input_pkt]
(http://haesbaert.github.io/charrua-core/api/Dhcp_server.Input.html#VALinput_pkt).
 4. Sending the reply, or logging the event from the [Dhcp_server.Input.input_pkt]
(http://haesbaert.github.io/charrua-core/api/Dhcp_server.Input.html#VALinput_pkt) call.

A mainloop example can be found in
[mirage-skeleton](https://github.com/mirage/mirage-skeleton/blob/master/dhcp/unikernel.ml#L28):

```ocaml
  let input_dhcp c net config subnet buf =
    let open Dhcp_server.Input in
    match (Dhcp_wire.pkt_of_buf buf (Cstruct.len buf)) with
    | `Error e -> Lwt.return (log c (red "Can't parse packet: %s" e))
    | `Ok pkt ->
      match (input_pkt config subnet pkt (Clock.time ())) with
      | Silence -> Lwt.return_unit
      | Warning w -> Lwt.return (log c (yellow "%s" w))
      | Error e -> Lwt.return (log c (red "%s" e))
      | Reply reply ->
        log c (blue "Received packet %s" (Dhcp_wire.pkt_to_string pkt));
        N.write net (Dhcp_wire.buf_of_pkt reply)
        >>= fun () ->
        log c (blue "Sent reply packet %s" (Dhcp_wire.pkt_to_string reply));
        Lwt.return_unit
```

As stated,
[Dhcp_server.Input.input_pkt](http://haesbaert.github.io/charrua-core/api/Dhcp_server.Input.html#VALinput_pkt)
does not perform any IO of its own, it only deals with the logic of analyzing a
DHCP packet and building a possible answer, which should then be sent by the
caller. This allows a design where all the side effects are controlled in one
small chunk, it makes it easier to understand the state transitions since they
are made explicit.

At the time of this writing,
[Dhcp_server.Input.input_pkt](http://haesbaert.github.io/charrua-core/api/Dhcp_server.Input.html#VALinput_pkt)
is not side effect free, as it manipulates a database of leases, this will be
changed in the next version to be pure as well.

Storing leases in permanent storage is also unsupported at this time and
should be available soon, with irmin and other backends. The main idea is to
always return a new lease database for each input, or maybe just the updates to
be applied, in this scenario, the caller would be able to store the database in
permanent storage as he sees fit.

#### Configuration

This project started independently of MirageOS, and at that time, the best
configuration I could think of was the well known `ISC` `dhcpd.conf`, therefore
the configuration uses the same format, but it does not support the myriad of
options of the original one.

```ocaml
  type t = {
    addresses : (Ipaddr.V4.t * Macaddr.t) list;
    subnets : subnet list;
    options : Dhcp_wire.dhcp_option list;
    hostname : string;
    default_lease_time : int32;
    max_lease_time : int32;
  }

  val parse : string -> (Ipaddr.V4.Prefix.addr * Macaddr.t) list -> t
  (** [parse cf l] Creates a server configuration by parsing [cf] as an ISC
      dhcpd.conf file, currently only the options at [sample/dhcpd.conf] are
      supported. [l] is a list of network addresses, each pair is the output
      address to be used for building replies and each must match a [network
      section] of [cf]. A normal usage would be a list of all interfaces
      configured in the system *)
```

Although it is a great format, it doesn't play exactly nice with MirageOS and
OCaml, since the unikernel needs to parse a string at runtime to build the
configuration, this requires a file IO backend and other complications. The
next version should provide OCaml helpers for building the configuration, which
would drop the requirements of a file IO backend and facilitate writing tests.

### Building a simple server

The easiest way is to follow [mirage-skeleton DHCP
README](https://github.com/mirage/mirage-skeleton/blob/master/dhcp/README.md).

### Future

The next steps would be:

* Provide helpers for building the configuration.
* Expose the lease database in an immutable structure, possibly a `Map`, adding
also support/example for [Irmin](https://github.com/mirage/irmin).
* Use [Functoria] (https://github.com/mirage/functoria) to pass down the
configuration in [mirage-skeleton]
(https://github.com/mirage/mirage-skeleton/blob/master/dhcp/README.md). Currently
it is awkward since the user has to edit `unikernel.ml` and `config.ml`, with
[Functoria] (https://github.com/mirage/functoria) we would be able to have it
much nicer and only touch `config.ml`.
* Convert MirageOS DHCP client code to use [Dhcp_wire]
(http://haesbaert.github.io/charrua-core/api/Dhcp_wire.html), or perhaps add a
client logic functionality to [Charrua]
(http://www.github.com/haesbaert/charrua-core).

### Finishing words

This is my first real project in OCaml and I'm more or less a newcomer to
functional programming as well, my background is mostly kernel hacking as an
ex-openbsd developer.
I'd love to hear how people are actually using it and any problems they're
finding, so please do let me know via the
[issue tracker](https://github.com/haesbaert/charrua-core/issues)!

Prior to this project I had no contact with any of the MirageOS folks, but I'm
amazed on how easy the interaction and comunication with the community has been,
everyone has been incredibly friendly and supportful, I'd say MirageOS is a gold
project for anyone wanting to work with smart people and hack OCaml.

My many thanks to Anil, Richard, Hannes, Amir, Scott, Gabriel and others. I also
would like to thank my [employer] (www.genua.de) for letting me work on this
project in our hackathons.
