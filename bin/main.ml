module Stack = Tcpip_stack_socket.V4V6
module Mirageio = Mirageio.Make (Stack)
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
  let port =
    match Sys.getenv_opt "MIRAGE_WWW_PORT" with
    | Some p -> int_of_string p
    | None -> 8080
  in
  Sys.(set_signal sigpipe Signal_ignore);
  Lwt_main.run
  @@ let* stack = stack_of_addr "0.0.0.0/0" in
     Lwt.join
       [
         Mirageio.http ~port stack;
         Lwt_io.printlf "\nmirage-www is being served at http://localhost:%d%!"
           port;
       ]
