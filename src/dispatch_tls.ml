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

module type S =
  functor (C: V1_LWT.CONSOLE) ->
  functor (FS: V1_LWT.KV_RO) ->
  functor (TMPL: V1_LWT.KV_RO) ->
  functor (S: V1_LWT.STACKV4) ->
  functor (KEYS: V1_LWT.KV_RO) ->
  functor (Clock : V1.CLOCK) ->
sig
  val start: ?host:string -> ?redirect:string ->
    C.t -> FS.t -> TMPL.t -> S.t -> KEYS.t -> unit -> unit -> unit Lwt.t
end

module Make_localhost
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct



  module TCP  = S.TCPV4
  module TLS  = Tls_mirage.Make (TCP)
  module X509 = Tls_mirage.X509 (KEYS) (Clock)

  module Http  = Cohttp_mirage.Server(TCP)
  module Https = Cohttp_mirage.Server(TLS)

  module D  = Dispatch.Make_localhost(C)(FS)(TMPL)(Http)(Clock)
  module DS = Dispatch.Make_localhost(C)(FS)(TMPL)(Https)(Clock)

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let with_tls c cfg tcp ~f =
    let peer, port = TCP.get_dest tcp in
    let log str = log c "[%s:%d] %s" (Ipaddr.V4.to_string peer) port str in
    let with_tls_server k = TLS.server_of_flow cfg tcp >>= k in
    with_tls_server @@ function
    | `Error _ -> log "TLS failed"; TCP.close tcp
    | `Ok tls  -> log "TLS ok"; f tls >>= fun () ->TLS.close tls
    | `Eof     -> log "TLS eof"; TCP.close tcp

  let with_http host c flow =
    let domain = `Https, host in
    let t = D.create domain c (D.redirect domain) in
    Http.listen t flow

  let tls_init kv =
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start ?(host="localhost") ?redirect c fs tmpl stack keys _clock () =
    Stats.start ~sleep:OS.Time.sleep ~time:Clock.time;
    tls_init keys >>= fun cfg ->
    let domain = `Https, host in
    let dispatch = match redirect with
      | None        -> DS.dispatch domain c fs tmpl
      | Some domain -> DS.redirect (Dispatch.domain_of_string domain)
    in
    let callback = Https.listen (DS.create domain c dispatch) in
    let https flow = with_tls c cfg flow ~f:callback in
    let http flow = with_http host c flow in
    S.listen_tcpv4 stack ~port:443 https;
    S.listen_tcpv4 stack ~port:80  http;
    S.listen stack

end

module Make (Config: Dispatch.Config)
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: V1_LWT.STACKV4) (KEYS: V1_LWT.KV_RO) (Clock : V1.CLOCK)
= struct
  module M = Make_localhost(C)(FS)(TMPL)(S)(KEYS)(Clock)
  let start ?host ?redirect c fs tmpl stack keys _clock () =
    let host = match host with None -> Config.host | x -> x in
    let redirect = match redirect with None -> Config.redirect | x -> x in
    M.start ?host ?redirect c fs tmpl stack keys _clock ()
end
