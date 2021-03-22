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

open Mirage

let tls_key =
  let doc = Key.Arg.info
      ~doc:"Enable serving the website over https."
      ~docv:"BOOL" ~env:"TLS" ["tls"]
  in
  Key.(create "tls" Arg.(opt ~stage:`Configure bool false doc))

let http_port =
  let doc = Key.Arg.info
      ~doc:"Port to listen on for plain HTTP connections"
      ~docv:"PORT" ["http-port"]
  in
  Key.(create "http-port" Arg.(opt ~stage:`Both int 80 doc))

let https_port =
  let doc = Key.Arg.info
      ~doc:"Port to listen on for encrypted HTTPS connections"
      ~docv:"PORT" ["https-port"]
  in
  Key.(create "https-port" Arg.(opt ~stage:`Both int 443 doc))

let host_key =
  let doc = Key.Arg.info
      ~doc:"Hostname of the unikernel."
      ~docv:"URL" ~env:"HOST" ["host"]
  in
  Key.(create "host" Arg.(opt string "localhost" doc))

let redirect_key =
  let doc = Key.Arg.info
      ~doc:"Where to redirect to. Must start with http:// or https://. \
            When tls is enabled, the default is https://$HOST, with the effect that all http requests will be redirected to https"
      ~docv:"URL" ~env:"REDIRECT" ["redirect"]
  in
  Key.(create "redirect" Arg.(opt (some string) None doc))

let dns_key =
  let doc = Key.Arg.info ~doc:"nsupdate key (name:type:value,...)" ["dns-key"] in
  Key.(create "dns-key" Arg.(required string doc))

let dns_server =
  let doc = Key.Arg.info ~doc:"dns server IP" ["dns-server"] in
  Key.(create "dns-server" Arg.(required ipv4_address doc))

let dns_port =
  let doc = Key.Arg.info ~doc:"dns server port" ["dns-port"] in
  Key.(create "dns-port" Arg.(opt int 53 doc))

let key_seed =
  let doc = Key.Arg.info ~doc:"certificate key seed" ["key-seed"] in
  Key.(create "key-seed" Arg.(required string doc))

let additional_hostnames =
  let doc = Key.Arg.info ~doc:"Additional names (used for certificates)" ["additional-hostname"] in
  Key.(create "additional-hostnames" Arg.(opt (list string) [] doc))

let keys = Key.([ v host_key ; v redirect_key ;
                  v http_port ;
                ])

let tls_only_keys = Key.([ v https_port ;
                      v dns_key ; v dns_server ;
                      v dns_port ; v key_seed ;
                      v additional_hostnames ;
                    ])

let fs_key = Key.(value @@ kv_ro ())
let filesfs = generic_kv_ro ~key:fs_key "../files"
let tmplfs = generic_kv_ro ~key:fs_key "../tmpl"

let http =
  foreign ~keys "Dispatch.Make"
    (http @-> kv_ro @-> kv_ro @-> pclock @-> job)

let https =
  let packages = [package "tls-mirage"; package "cohttp-mirage"] in
  let keys = keys @ tls_only_keys in
  foreign ~packages  ~keys "Dispatch_tls.Make"
    (random @-> stackv4 @-> kv_ro @-> kv_ro @-> pclock @-> job)

let dispatch = if_impl (Key.value tls_key)
    (* With tls *)
    (https $ default_random $ generic_stackv4 default_network)

    (* Without tls *)
    (http $ cohttp_server (conduit_direct (generic_stackv4 default_network)))

let packages = [
  package "cow" ~min:"2.3.0";
  package "cowabloga";
  package ~sublibs:["mirage"] "dns-certify";
  (*  package ~ocamlfind:["rrd"] ~min:"1.0.1" "xapi-rrd"; *)
  (* package "c3" ; *)
  package "duration";
  package "ptime";
  package ~min:"2.0.0" "mirage-kv";
]

let () =
  let tracing = None in
  (* let tracing = mprof_trace ~size:10000 () in *)
  register ?tracing ~packages "www" [
    dispatch $ filesfs $ tmplfs $ default_posix_clock
  ]
