open Lwt

let port = 80

let ip =
  let open Net.Nettypes in
  ( ipv4_addr_of_tuple (10l,0l,0l,2l),
    ipv4_addr_of_tuple (255l,255l,255l,0l),
   [ipv4_addr_of_tuple (10l,0l,0l,1l)]
  )

let main () =
  Log.info "Server" "listening to HTTP on port %d" port;
  lwt static = OS.Devices.find_kv_ro "static" >>=
    function
    |None -> raise_lwt (Failure "no static dev")
    |Some x -> return x in
  Log.info "Server" "got static blkif";
  let callback = Dispatch.t static in
  let spec = {
    Http.Server.address = "0.0.0.0";
    auth = `None;
    callback;
    conn_closed = (fun _ -> ());
    port;
    exn_handler = Dispatch.exn_handler;
    timeout = Some 300.;
  } in
  Log.info "Server" "Starting server";
  Net.Manager.create (fun mgr interface id ->
    let src = None, port in
    Net.Manager.configure interface (`IPv4 ip) >>
    Http.Server.listen mgr (`TCPv4 (src, spec))
  )
