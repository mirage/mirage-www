open Lwt

let port = 8080

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
  lwt mgr, mgr_t = Net.Manager.create () in
  let src = None, port in
  Http.Server.listen mgr src spec

let _ =
  OS.Main.run ( 
    Log.info "Server" "listening to HTTP on port %d" port;
    main ()
  )
