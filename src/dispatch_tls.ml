(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt.Infix

(* HTTPS *)
module Make
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct

  module TCP  = S.TCPV4
  module TLS  = Tls_mirage.Make (TCP)
  module X509 = Tls_mirage.X509 (KEYS) (Clock)

  module Http  = Cohttp_mirage.Server(TCP)
  module Https = Cohttp_mirage.Server(TLS)

  module D  = Dispatch.Make(C)(FS)(TMPL)(Http)
  module DS = Dispatch.Make(C)(FS)(TMPL)(Https)

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let with_tls c cfg tcp ~f =
    let peer, port = TCP.get_dest tcp in
    let log str = log c "[%s:%d] %s" (Ipaddr.V4.to_string peer) port str in
    let with_tls_server k = TLS.server_of_flow cfg tcp >>= k in
    with_tls_server @@ function
    | `Error _ -> log "TLS failed"; TCP.close tcp
    | `Ok tls  -> log "TLS ok"; f tls >>= fun () ->TLS.close tls
    | `Eof     -> log "TLS eof"; TCP.close tcp

  let with_https s c fs tmpl flow =
    let t = DS.create c (DS.dispatcher s fs tmpl) in
    Https.listen t flow

  let with_http name c flow =
    let t =
      let mk path =
        Site_config.base_uri (`Https, name) ^ String.concat "/" path
      in
      D.create c (fun path -> D.redirect (mk path))
    in
    Http.listen t flow

  let tls_init kv =
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start name c fs tmpl stack keys _clock =
    tls_init keys >>= fun cfg ->
    let callback = with_https (`Https, name) c fs tmpl in
    let https flow = with_tls c cfg flow ~f:callback in
    let http flow = with_http name c flow in
    S.listen_tcpv4 stack ~port:443 https;
    S.listen_tcpv4 stack ~port:80  http;
    S.listen stack

end

module OpenMirage_org
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct
  module M = Make(C)(FS)(TMPL)(S)(KEYS)(Clock)
  let start c fs tmpl stack keys _clock =
    M.start "openmirage.org" c fs tmpl stack keys _clock
end

module Mirage_io
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct
  module M = Make(C)(FS)(TMPL)(S)(KEYS)(Clock)
  let start c fs tmpl stack keys _clock =
    M.start "mirage.io" c fs tmpl stack keys _clock
end
