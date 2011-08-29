open Lwt

let port = 80

let spec = {
  Http.Server.address = "0.0.0.0";
  auth = `None;
  callback = Dispatch.t;
  conn_closed = (fun _ -> ());
  port;
  exn_handler = Dispatch.exn_handler;
  timeout = Some 300.;
}

let main () =
  Log.info "Server" "listening to HTTP on port %d" port;
  Net.Manager.create (fun mgr interface id ->
    let src = None, port in
    Http.Server.listen mgr (`TCPv4 (src, spec))
  )
