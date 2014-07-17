A critical part of any unikernel is its network stack -- it's difficult to
think of a project that needs a cloud platform or runs on a set-top box with no
network communications.

Mirage provides a number of [module
types](https://github.com/mirage/mirage/tree/master/types) that abstract
interfaces at different layers of the network stack, allowing unikernels to
customise their own stack based on their deployment needs. Depending on the
abstractions your unikernel uses, you can fulfill these abstract interfaces
with implementations ranging from the venerable and much-imitated Unix sockets
API to a clean-slate Mirage [TCP/IP
stack](https://github.com/mirage/mirage-tcpip) written from the ground up in
pure OCaml!

A Mirage unikernel will not use *all* these interfaces, but will pick those that
are appropriate for the particular application at hand. If your unikernel just
needs a standard TCP/IP stack, the `STACKV4` abstraction will be sufficient.
However, if you want more control over the implementation of the different
layers in the stack or you don't need TCP support, you might construct your
stack by hand using just the [NETWORK](https://github.com/mirage/mirage/blob/8b59fbf0b223b3c5c70d4939b5674ecdd7521804/types/V1.mli#L263), [ETHIF](https://github.com/mirage/mirage/blob/8b59fbf0b223b3c5c70d4939b5674ecdd7521804/types/V1.mli#L316), [IPV4](https://github.com/mirage/mirage/blob/8b59fbf0b223b3c5c70d4939b5674ecdd7521804/types/V1.mli#L368) and [UDPV4](https://github.com/mirage/mirage/blob/8b59fbf0b223b3c5c70d4939b5674ecdd7521804/types/V1.mli#L457) interfaces.

## How a Stack Looks to a Mirage Application

Mirage provides a high-level interface to a TCP/IP network stack through the module type
[STACKV4](https://github.com/mirage/mirage/blob/8b59fbf0b223b3c5c70d4939b5674ecdd7521804/types/V1.mli#L581).
(Currently this can be included with `open V1_LWT`, but soon `open
V2_LWT` will also bring this module type into scope as well when Mirage 2.0 is released.)

```OCaml
(** Single network stack *)                                                     
module type STACKV4 = STACKV4                                                   
  with type 'a io = 'a Lwt.t                                                    
   and type ('a,'b,'c) config = ('a,'b,'c) stackv4_config                       
   and type ipv4addr = Ipaddr.V4.t                                              
   and type buffer = Cstruct.t 
```

`STACKV4` has useful high-level functions, a subset of which are reproduced below:

```OCaml
    val listen_udpv4 : t -> port:int -> UDPV4.callback -> unit
    val listen_tcpv4 : t -> port:int -> TCPV4.callback -> unit
    val listen : t -> unit io
```

as well as submodules that include functions for data transmission:

```OCaml
    module UDPV4 :
      sig
        type callback =
            src:ipv4addr -> dst:ipv4addr -> src_port:int -> buffer -> unit io
        val input :
          listeners:(dst_port:int -> callback option) -> t -> ipv4input
        val write :
          ?source_port:int ->
          dest_ip:ipv4addr -> dest_port:int -> t -> buffer -> unit io
```

```OCaml
    module TCPV4 :
      sig
        type flow
        type callback = flow -> unit io
        val read : flow -> [ `Eof | `Error of error | `Ok of buffer ] io
        val write : flow -> buffer -> unit io
        val close : flow -> unit io
        val create_connection :
          t -> ipv4addr * int -> [ `Error of error | `Ok of flow ] io
        val input : t -> listeners:(int -> callback option) -> ipv4input
```

These should look rather familiar if you've used the Unix sockets
API before, with one notable difference: the stack accepts functional
callbacks to react to events such as a new connection request.  This
permits callers of the library to define the precise datastructures that
are used to store intermediate state (such as active connections).
This becomes important when building very scalable systems that have
to deal with [lots of concurrent connections](https://en.wikipedia.org/wiki/C10k_problem)
efficiently.

## Configuring a Stack

The `STACKV4` signature shown so far is just a module signature, and you
need to find a concrete module that satisfies that signature.  The known
implementations of a module can be found in the `mirage` CLI frontend,
which provids the [configuration API](https://github.com/mirage/mirage/blob/8b59fbf0b223b3c5c70d4939b5674ecdd7521804/lib/mirage.mli#L266) for unikernels.  
There are currently two implementations for `STACKV4`: `direct` and `socket`.

```OCaml
module STACKV4_direct: CONFIGURABLE with                                        
  type t = console impl * network impl * [`DHCP | `IPV4 of ipv4_config]         
                                                                                
module STACKV4_socket: CONFIGURABLE with                                        
  type t = console impl * Ipaddr.V4.t list  
```

The `socket` implementations rely on an underlying OS kernel to provide the
transport, network, and data link layers, and therefore can't be used for a Xen
guest VM deployment.  Currently, the only way to use `socket` is by configuring
your Mirage project for Unix with `mirage configure --unix`.  This is the mode
you will most often use when developing high-level application logic that doesn't
need to delve into the innards of the network stack (e.g. a REST website).

The `direct` implementations use the [mirage-tcpip](https://github.com/mirage/mirage-tcpip) implementations of the
transport, network, and data link layers.  When you use this stack, all the network
traffic from the Ethernet level up will be handled in pure OCaml.  This means that the
`direct` stack will work with either a Xen
guest VM (provided there's a valid network configuration for the unikernel's
running environment of course), or a Unix program if there's a valid [tuntap](https://en.wikipedia.org/wiki/TUN/TAP) interface.
`direct` this works with both `mirage configure --xen` and `mirage configure --unix`
as long as there is a corresponding available device when the unikernel is run.

There are a few Mirage functions that provide IPv4 (and UDP/TCP) stack
implementations (of type `stackv4 impl`), usable from your application code.
The `stackv4 impl` is generated in `config.ml` by some logic set when the
program is `mirage configure`'d - often by matching an environment variable.
This means it's easy to flip between different stack implementations when
developing an application just be recompiling the application.  The `config.ml`
below allows the developer to build socket code with `NET=socket make` and
direct code with `NET=direct make`.

```OCaml
let main = foreign "Services.Main" (console @-> stackv4 @-> job)

let net =
  try match Sys.getenv "NET" with
    | "direct" -> `Direct
    | "socket" -> `Socket
    | _        -> `Direct
  with Not_found -> `Direct

let dhcp =
  try match Sys.getenv "ADDR" with
    | "dhcp"   -> `Dhcp
    | "static" -> `Static
    | _ -> `Dhcp
  with Not_found -> `Dhcp

let stack console =
  match net, dhcp with
  | `Direct, `Dhcp   -> direct_stackv4_with_dhcp console tap0
  | `Direct, `Static -> direct_stackv4_with_default_ipv4 console tap0
  | `Socket, _       -> socket_stackv4 console [Ipaddr.V4.any]

let () =
  register "services" [
    main $ default_console $ stack default_console
  ]
```

Moreover, it's possible to configure multiple stacks individually for use in
the same program, and to `register` multiple modules from the same `config.ml`.
This means functions can be written such that they're aware of the network
stack they ought to be using, and no other - a far cry from developing network
code over most socket interfaces, where it can be quite difficult to separate
concerns nicely.

```OCaml
let client = foreign "Unikernel.Client" (console @-> stackv4 @-> job)
let server = foreign "Unikernel.Server" (console @-> stackv4 @-> job) 

let client_netif = (netif "0")
let server_netif = (netif "1") 

let client_stack = direct_stackv4_with_dhcp default_console client_netif
let server_stack = direct_stackv4_with_dhcp default_console server_netif

let () = 
  register "unikernel" [
    main $ default_console $ client_stack;
    server $ default_console $ server_stack 
  ]

```

## Acting on Stacks

Most network applications will either want to listen for incoming connections
and respond to that traffic with information, or to connect to some remote
host, execute a query, and receive information.  `STACKV4` offers simple ways
to define functions implementing either of these patterns.

### Establishing and Communicating Across Connections

`STACKV4` offers `listen_tcpv4` and `listen_udpv4` functions for establishing
listeners on specific ports.  Both take a `stack impl`, a named `port`, and a
`callback` function.  

For UDP listeners, which are datagram-based rather than connection-based,
`callback` is a function of the source IP, destination IP, source port, and the
`Cstruct.t` that contains the payload data.  Applications that wish to respond
to incoming UDP packets with their own UDP responses (e.g., DNS servers) can
use this information to construct reply packets and send them with
`UDPV4.write` from within the callback function.

For TCP listeners, `callback` is a function of `TCPV4.flow -> unit Lwt.t`.  `STACKV4.TCPV4` offers `read`, `write`, and `close` on `flow`s for application writers to build higher-level protocols on top of. 

`TCPV4` also offers `create_connection`, which allows client application code to establish TCP connections with remote servers.  In success cases, `create_connection` returns a `TCPV4.flow`, which can be acted on just as the data in a `callback` above.  There's also a polymorphic variant for error conditions, such as an unreachable remote server.

### A Simple Example

Some very simple examples of user-level TCP code are included in [mirage-tcpip/examples](https://github.com/mirage/mirage-tcpip/tree/master/examples).  `config.ml` is identical to the first configuration example above, and will build a `direct` stack by default.

Imagine a very simple application - one which simply repeats any data back to the sender, until the sender gets bored and wanders off ([RFC 862](https://en.wikipedia.org/wiki/Echo_Protocol), for the curious).

```OCaml
open Lwt
open V1_LWT

module Main (C: V1_LWT.CONSOLE) (S: V1_LWT.STACKV4) = struct
  let report_and_close c flow message =
    C.log c message;
    S.TCPV4.close flow

  let rec echo c flow =
    S.TCPV4.read flow >>= fun result -> (
      match result with  
        | `Eof -> report_and_close c flow "Echo connection closure initiated."
        | `Error e -> 
          let message = 
          match e with 
            | `Timeout -> "Echo connection timed out; closing.\n"
            | `Refused -> "Echo connection refused; closing.\n"
            | `Unknown s -> (Printf.sprintf "Echo connection error: %s\n" s)
             in
          report_and_close c flow message
        | `Ok buf ->
            S.TCPV4.write flow buf >>= fun () -> echo c flow
        ) 

  let start c s = 
    S.listen_tcpv4 s ~port:7 (echo c);
    S.listen s

end
```

All the application programmer needs to do is define functionality in relation to `flow` for sending and receiving data, establish this function as a callback with `listen_tcpv4`, and start a listening thread with `listen`.

## More Complex Uses

An OCaml HTTP server, [Cohttp](http://www.github.com/mirage/ocaml-cohttp), is currently powering this very blog.  A simple static webserver using Cohttp [is included in `mirage-skeleton`](https://github.com/mirage/mirage-skeleton/tree/master/static_website).

[The OCaml-TLS demonstration server](https://tls.openmirage.org/) announced here [just a few days ago](http://openmirage.org/blog/introducing-ocaml-tls) is also running atop Cohttp - [source is available on Github](https://github.com/mirleft/tls-demo-server).

## The future

Mirage's TCP/IP stack is under active development!  [Some low-level details](https://github.com/mirage/mirage-tcpip/search?q=TODO&ref=cmdform) are still stubbed out, and we're working on implementing some of the trickier corners of TCP, as well as [doing automated testing](http://somerandomidiot.com/blog/2014/05/22/throwing-some-fuzzy-dice/) on the stack.  We welcome testing tools, bug reports, bug fixes, and new protocol implementations!  
