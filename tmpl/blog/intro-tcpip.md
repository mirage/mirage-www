A critical part of any unikernel is its network stack -- it's difficult to think of a project that needs a cloud platform or runs on a set-top box with no network communications. Mirage provides a number of module types that abstract interfaces at different layers of the network stack, allowing unikernels to assemble their own network stack, customised to their own needs. Depending on the abstractions your unikernel uses, you can fulfil these abstract interfaces with implementations ranging from the native Unix Sockets API to the native OCaml Mirage TCP/IP stack.

```
$ grep "module type" V1_LWT.mli 
module type TIME = TIME
module type FLOW = FLOW
module type NETWORK = NETWORK
module type ETHIF = ETHIF
module type IPV4 = IPV4
module type UDPV4 = UDPV4
module type TCPV4 = TCPV4
module type CHANNEL = CHANNEL
module type KV_RO = KV_RO
module type CONSOLE = CONSOLE
module type BLOCK = BLOCK
module type FS = FS
module type STACKV4 = STACKV4
```

Of 13 such module types, 6 comprise the network stack (and `CHANNEL` is usable in the context of the network stack as well).  A Mirage unikernel will not use all these interfaces, but will pick those that are appropriate. For example, if your unikernel just needs a standard TCP/IP stack, the `STACKV4` abstraction will be sufficient. However, if you want more control over the implementation of the different layers in the stack or you don't need TCP support, you might construct your stack by hand using just the `NETWORK`, `ETHIF`, `IPV4` and `UDPV4` interfaces.

## How a Stack Looks to a Mirage Application

Mirage provides an interface to a network stack through the module type `STACKV4`.  (Currently this can be included with `open V1_LWT`, but soon `open V2_LWT` will also bring this module type into scope as well.)

```OCaml
(** Single network stack *)                                                     
module type STACKV4 = STACKV4                                                   
  with type 'a io = 'a Lwt.t                                                    
   and type ('a,'b,'c) config = ('a,'b,'c) stackv4_config                       
   and type ipv4addr = Ipaddr.V4.t                                              
   and type buffer = Cstruct.t 
```

`STACKV4` has a useful high-level functions, a subset of which are reproduced below:

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

## Configuring a Stack

There are currently two implementations for `STACKV4` - `direct` and `socket`.

```OCaml
module STACKV4_direct: CONFIGURABLE with                                        
  type t = console impl * network impl * [`DHCP | `IPV4 of ipv4_config]         
                                                                                
module STACKV4_socket: CONFIGURABLE with                                        
  type t = console impl * Ipaddr.V4.t list  
```

`direct` implementations use the `mirage-tcpip` implementations of the transport, network, and data link layers.
`direct` will work with either a Xen guest VM (provided there's a valid network configuration for the unikernel's running environment), or a Unix program if there's a valid `nettap` interface.  `direct` works with both `mirage configure --xen` and `mirage configure --unix` as long as there is a corresponding available device.

`socket` implementations rely on an underlying operating system to provide the transport, network, and data link layers, and therefore can't be used for a Xen guest VM deployment.  Currently, the only way to use `socket` is by configuring your Mirage project for Unix with `mirage configure --unix`.

There are a few Mirage functions which provide an interface to network operations usable from your application code (a type of `stack impl`).  The `stack impl` is generated in `config.ml` by some logic set when the program is `mirage configure`'d - often by matching an environment variable.  This means it's easy to flip between different `stack impl`s when developing an application.  The `config.ml` below allows the developer to build socket code with `NET=socket make` and direct code with `NET=direct make`.

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

Moreover, it's possible to configure multiple stacks individually for use in the same program, and to `register` multiple modules from the same `config.ml`.  This means functions can be written such that they're aware of the network stack they ought to be using, and no other - a far cry from developing network code over most socket interfaces, where it can be quite difficult to separate concerns nicely.

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

Most network applications will either want to listen for incoming connections and respond to that traffic with information, or to connect to some remote host, execute a query, and recieve information.  `STACKV4` offers simple ways to define functions implementing either of these patterns.

### Establishing and Communicating Across Connections

`STACKV4` offers `listen_tcpv4` and `listen_udpv4` functions for establishing listeners on specific ports.  Both take a `stack impl`, a named `port`, and a `callback` function.  

For UDP listeners, which are datagram-based rather than connection-based, `callback` is a function of the source IP, destination IP, source port, and the `Cstruct.t` that contains the payload data.  Applications that wish to respond to incoming UDP packets with their own UDP responses (e.g., DNS servers) can use this information to construct reply packets and send them with `UDPV4.write` from within the callback function.

For TCP listeners, `callback` is a function of `TCPV4.flow -> unit Lwt.t`.  `STACKV4.TCPV4` offers `read`, `write`, and `close` on `flow`s for application writers to build higher-level protocols on top of. 

`TCPV4` also offers `create_connection`, which allows client application code to establish TCP connections with remote servers.  In success cases, `create_connection` returns a `TCPV4.flow`, which can be acted on just as the data in a `callback` above.  There's also a polymorphic variant for error conditions, such as an unreachable remote server.

### A Simple Example

Some very simple examples of user-level TCP code are included in [mirage-tcpip/examples](https://github.com/mirage/mirage-tcpip/tree/master/examples).  `config.ml` is identical to the first configuration example above, and will build a `direct` stack by default.

Imagine a very simple application - one which simply repeats any data back to the sender, until the sender gets bored and wanders off.

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

Mirage's TCP/IP stack is still evolving!  Some low-level details are still stubbed out, and we're working on implementing some of the trickier corners of TCP.  There are few automated tests for the stack and they're not currently integrated into the workflow for testing `mirage-tcpip`.  IPv6 support is also on the horizon.
