open Lwt

let port = 80

(* put in a reference to our fake filesystem so it gets compiled *)
let _ = Filesystem_templates.size
let _ = Filesystem_static.size

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
    Http.Server.listen mgr (`TCPv4 (src, spec))
  )
