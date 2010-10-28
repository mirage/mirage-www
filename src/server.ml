open Lwt
open Http
open Http_daemon

let spec = {
  address = "0.0.0.0";
  auth = `None;
  callback = Dispatch.t;
  conn_closed = (fun _ -> ());
  port = 8080;
  exn_handler = Dispatch.exn_handler;
  timeout = Some 300.;
}

let _ =
  OS.Main.run ( 
    Log.logmod "Server" "listening to HTTP on port %d" spec.port;
    main spec
  )
