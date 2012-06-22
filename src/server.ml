open Printf
open Lwt

let port = Config.port

let ip =
  let open Net.Nettypes in
  ( ipv4_addr_of_tuple (10l,0l,0l,2l),
    ipv4_addr_of_tuple (255l,255l,255l,0l),
   [ipv4_addr_of_tuple (10l,0l,0l,1l)]
  )

let main () =
  eprintf "listening to HTTP on port %d\n" port;
  eprintf "finding the static kv_ro block device\n";
  lwt static = OS.Devices.find_kv_ro "static" >>=
    function
    |None -> Printf.printf "fatal error, static kv_ro not found\n%!"; exit 1
    |Some x -> return x in
  let callback = Dispatch.t static in
  let spec = {
    Cohttp.Server.address = "0.0.0.0";
    auth = `None;
    callback;
    conn_closed = (fun _ -> ());
    port;
    exn_handler = Dispatch.exn_handler;
    timeout = Some 300.;
  } in
  Net.Manager.create (fun mgr interface id ->
    let src = None, port in
    Net.Manager.configure interface (`IPv4 ip) >>
    Cohttp.Server.listen mgr (`TCPv4 (src, spec))
  )
