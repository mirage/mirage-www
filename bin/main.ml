module Stack = Tcpip_stack_socket.V4V6
module Mirageio = Mirageio.Make (Pclock) (OS.Time) (Stack)
open Lwt.Syntax

let stack_of_addr addr =
  let interface = Ipaddr.V4.Prefix.of_string_exn addr in
  let* udp_socket =
    Udpv4v6_socket.connect ~ipv4_only:false ~ipv6_only:false interface None
  in
  let* tcp_socket =
    Tcpv4v6_socket.connect ~ipv4_only:false ~ipv6_only:false interface None
  in
  Stack.connect udp_socket tcp_socket

let () =
  Sys.(set_signal sigpipe Signal_ignore);
  Lwt_main.run
  @@ let* stack = stack_of_addr "0.0.0.0/0" in
     Mirageio.http ~port:8080 stack
