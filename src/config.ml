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

(* Hack to make the image name parametrized *)
let get ~default name =
  try String.lowercase @@ Sys.getenv name
  with Not_found -> default

let image = get "XENIMG" ~default:"www"


open Mirage

let tls_key =
  let doc = Key.Arg.info
      ~doc:"Enable serving the website over https. Do not forget to put certificates in tls/"
      ~docv:"BOOL" ~env:"TLS" ["tls"]
  in
  Key.(create "tls" Arg.(opt ~stage:`Configure bool false doc))

let pr_key =
  let doc = Key.Arg.info
      ~doc:"Configuration for running inside a travis PR."
      ~env:"TRAVIS_PULL_REQUEST" ["pr"]
  in
  Key.(create "pr" Arg.(opt ~stage:`Configure (some int) None doc))


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

let keys = Key.([ abstract host_key ; abstract redirect_key ])

let fs_key = Key.(value @@ kv_ro ())
let filesfs = generic_kv_ro ~key:fs_key "../files"
let tmplfs = generic_kv_ro ~key:fs_key "../tmpl"

let secrets_key = Key.(value @@ kv_ro ~group:"secrets" ())
let secrets = generic_kv_ro ~key:secrets_key "../tls"
let stack = generic_stackv4 default_console tap0

let http =
  foreign ~keys "Dispatch.Make"
    (http @-> console @-> kv_ro @-> kv_ro @-> clock @-> job)

let https =
  let libraries = [ "tls"; "tls.mirage"; "mirage-http" ] in
  let packages = ["tls"; "tls"; "mirage-http"] in
  foreign ~libraries ~packages  ~keys "Dispatch_tls.Make"
    ~deps:[abstract nocrypto]
    (stackv4 @-> kv_ro @-> console @-> kv_ro @-> kv_ro @-> clock @-> job)


let dispatch = if_impl (Key.value tls_key)
    (** With tls *)
    (https $ stack $ secrets)

    (** Without tls *)
    (http  $ http_server (conduit_direct stack))

let libraries = [ "cow"; "cowabloga"; "rrd" ]
let packages  = [ "cow"; "cowabloga"; "xapi-rrd"; "c3" ]

let () =
  let tracing = Some (mprof_trace ~size:1000000 ()) in
  register ?tracing ~libraries ~packages image [
    dispatch $ default_console $ filesfs $ tmplfs $ default_clock
  ]
