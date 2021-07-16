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

module Make
    (Clock : Mirage_clock.PCLOCK)
    (R: Mirage_random.S)
    (S: Mirage_stack.V4)
    (FS: Mirage_kv.RO)
    (TMPL: Mirage_kv.RO)
= struct

  let log_src = Logs.Src.create "dispatch_tls" ~doc:"web-over-tls server"
  module Log = (val Logs.src_log log_src : Logs.LOG)

  module TCP  = S.TCPV4
  module TLS  = Tls_mirage.Make (TCP)

  module Http  = Cohttp_mirage.Server.Flow(TCP)
  module Https = Cohttp_mirage.Server.Flow(TLS)

  module D  = Dispatch.Make(Http)(FS)(TMPL)
  module DS = Dispatch.Make(Https)(FS)(TMPL)

  module C = Dns_certify_mirage.Make(R)(Clock)(OS.Time)(S)

  let with_tls cfg tcp ~f =
    let peer, port = TCP.dst tcp in
    let log str = Log.debug (fun f -> f "[%s:%d] %s" (Ipaddr.V4.to_string peer) port str) in
    let with_tls_server k = TLS.server_of_flow cfg tcp >>= k in
    with_tls_server @@ function
    | Error _ -> log "TLS failed"; TCP.close tcp
    | Ok tls  -> log "TLS ok"; f tls >>= fun () ->TLS.close tls

  let with_http host flow =
    let domain = `Https, host in
    let t = D.create domain (D.redirect domain) in
    Http.callback t flow

  let restart_before_expire = function
    | `Single (server :: _, _) ->
      let expiry = snd (X509.Certificate.validity server) in
      let diff = Ptime.diff expiry (Ptime.v (Clock.now_d_ps ())) in
      begin match Ptime.Span.to_int_s diff with
        | None -> invalid_arg "couldn't convert span to seconds"
        | Some x when x < 0 -> invalid_arg "diff is negative"
        | Some x ->
          Lwt.async (fun () ->
              OS.Time.sleep_ns
                (Int64.sub (Duration.of_sec x) (Duration.of_day 1)) >|= fun () ->
              exit 42)
      end
    | _ -> ()

  let tls_init stack hostname additional_hostnames =
    C.retrieve_certificate stack ~dns_key:(Key_gen.dns_key ())
      ~hostname ~additional_hostnames ~key_seed:(Key_gen.key_seed ())
      (Key_gen.dns_server ()) (Key_gen.dns_port ()) >>= function
    | Error (`Msg m) -> Lwt.fail_with m
    | Ok certificates ->
      restart_before_expire certificates;
      let conf = Tls.Config.server ~certificates () in
      Lwt.return conf

  let start () _ stack fs tmpl =
    let host = Key_gen.host () in
    let redirect = Key_gen.redirect () in
    let hostname = Domain_name.(of_string_exn (Key_gen.host ()) |> host_exn) in
    let additional_hostnames =
      List.map (fun n -> Domain_name.(of_string_exn n))
        (Key_gen.additional_hostnames ())
    in
    tls_init stack hostname additional_hostnames >>= fun cfg ->
    let domain = `Https, host in
    let dispatch = match redirect with
      | None        -> DS.dispatch domain fs tmpl
      | Some domain -> DS.redirect (Dispatch.domain_of_string domain)
    in
    let callback = Https.callback (DS.create domain dispatch) in
    let https flow = with_tls cfg flow ~f:callback in
    let http flow = with_http host flow in
    S.listen_tcpv4 stack ~port:(Key_gen.https_port ()) https;
    S.listen_tcpv4 stack ~port:(Key_gen.http_port ()) http;
    S.listen stack

end
