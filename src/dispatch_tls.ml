open Printf

let (>>=) = Lwt.(>>=)

(* HTTPS *)
module Main
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct

  module TCP  = S.TCPV4
  module TLS  = Tls_mirage.Make (TCP)
  module X509 = Tls_mirage.X509 (KEYS) (Clock)

  module Http  = Cohttp_mirage.Server(TCP)
  module Https = Cohttp_mirage.Server(TLS)

  module D  = Dispatch.Main(C)(FS)(TMPL)(Http)
  module DS = Dispatch.Main(C)(FS)(TMPL)(Https)

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let with_tls c cfg tcp ~f =
    let peer, port = TCP.get_dest tcp in
    let log str = log c "[%s:%d] %s" (Ipaddr.V4.to_string peer) port str in
    let with_tls_server k = TLS.server_of_flow cfg tcp >>= k in
    with_tls_server @@ function
    | `Error _ -> log "TLS failed"; TCP.close tcp
    | `Ok tls  -> log "TLS ok"; f tls >>= fun () ->TLS.close tls
    | `Eof     -> log "TLS eof"; TCP.close tcp

  let with_https c fs tmpl flow =
    let t = DS.create c (DS.dispatcher c fs tmpl) in
    Https.listen t flow () ()

  let with_http c flow =
    let t =
      let mk path = Site_config.base_uri ^ String.concat "/" path in
      D.create c (fun path -> D.redirect (mk path))
    in
    Http.listen t flow () ()

  let tls_init kv =
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start c fs tmpl stack keys _clock =
    tls_init keys >>= fun cfg ->
    let https flow = with_tls c cfg flow ~f:(with_https c fs tmpl) in
    let http flow = with_http c flow in
    S.listen_tcpv4 stack ~port:443 https;
    S.listen_tcpv4 stack ~port:80  http;
    S.listen stack

end
