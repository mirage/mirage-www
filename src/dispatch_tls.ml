open Printf

let (>>=) = Lwt.(>>=)
let (>|=) = Lwt.(>|=)

let split_path uri =
  let path = Uri.path uri in
  let rec aux = function
    | [] | [""] -> []
    | hd::tl -> hd :: aux tl
  in
  List.filter (fun e -> e <> "")
    (aux (Re_str.(split_delim (regexp_string "/") path)))

(* HTTPS *)
module Main
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct

  module TCP  = S.TCPV4
  module TLS  = Tls_mirage.Make (TCP)
  module X509 = Tls_mirage.X509 (KEYS) (Clock)

  module Http     = Cohttp_mirage.Server(TLS)
  module Dispatch = Dispatch.Main(C)(FS)(TMPL)(Http)

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let with_tls c cfg tcp ~f =
    let peer, port = TCP.get_dest tcp in
    let log str = log c "[%s:%d] %s" (Ipaddr.V4.to_string peer) port str in
    let with_tls_server k = TLS.server_of_flow cfg tcp >>= k in
    with_tls_server @@ function
    | `Error _ -> log "TLS failed"; TCP.close tcp
    | `Ok tls  -> log "TLS ok"; f tls >>= fun () ->TLS.close tls
    | `Eof     -> log "TLS eof"; TCP.close tcp

  let with_http c fs tmpl flow =
    let callback conn_id request body =
      let uri = Http.Request.uri request in
      let io = {
        Cowabloga.Dispatch.log = (fun ~msg -> C.log c msg);
        ok = Dispatch.respond_ok;
        notfound = (fun ~uri -> Http.respond_not_found ~uri ());
        redirect = (fun ~uri -> Http.respond_redirect ~uri ());
      } in
      Cowabloga.Dispatch.f io (Dispatch.dispatcher c fs tmpl) uri
    in
    let conn_closed (_,conn_id) =
      let cid = Cohttp.Connection.to_string conn_id in
      C.log c (Printf.sprintf "conn %s closed" cid)
    in
    let http = Http.make ~conn_closed ~callback () in
    Http.listen http flow () ()

  let tls_init kv =
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start c fs tmpl stack keys _clock =
    tls_init keys >>= fun cfg ->
    let serve flow = with_tls c cfg flow ~f:(with_http c fs tmpl) in
    Stats.start OS.Time.sleep;
    S.listen_tcpv4 stack ~port:443 serve;
    S.listen stack

end
