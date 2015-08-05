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

let split c s =
  let rec aux c s ri acc =
    (* half-closed intervals. [ri] is the open end, the right-fencepost.
       [li] is the closed end, the left-fencepost. either [li] is
       + negative (outside [s]), or
       + equal to [ri] ([c] not found in remainder of [s]) ->
         take everything from [ s[0], s[ri] )
       + else inside [s], thus an instance of the separator ->
         accumulate from the separator to [ri]: [ s[li+1], s[ri] )
         and move [ri] inwards to the discovered separator [li]
    *)
    let li = try String.rindex_from s (ri-1) c with Not_found -> -1 in
    if li < 0 || li == ri then (String.sub s 0 ri) :: acc
    else begin
      let len = ri-1 - li in
      let rs = String.sub s (li+1) len in
      aux c s li (rs :: acc)
    end
  in
  aux c s (String.length s) []

let ips_of_env x = split ':' x |> List.map Ipaddr.V4.of_string_exn
let bool_of_env = function "1" | "true" | "yes" -> true | _ -> false
let socket_of_env = function "socket" -> `Socket | _ -> `Direct
let fat_of_env = function "fat" -> `Fat | "archive" -> `Archive | _ -> `Crunch
let opt_string_of_env x = Some x
let string_of_env x = x

let err fmt =
  Printf.ksprintf (fun str ->
      Printf.eprintf ("\027[31m[ERROR]\027[m     %s\n") str;
      exit 1
    ) fmt

let env_info fmt = Printf.printf ("\027[33mENV\027[m         " ^^ fmt ^^ "\n%!")

let get_env name fn =
  let res = Sys.getenv name in
  env_info "%s => %s" name res;
  fn (String.lowercase res)

let get_exn name fn =
  try get_env name fn
  with Not_found ->
    err "%s is not set." name

let get ~default name fn =
  try get_env name fn
  with Not_found ->
    env_info "%s => not set." name;
    default

let fs = get "FS" ~default:`Crunch fat_of_env
let deploy = get "DEPLOY" ~default:false bool_of_env
let net = get  "NET" ~default:`Direct socket_of_env
let dhcp = get "DHCP" ~default:false bool_of_env
let tls = get "TLS" ~default:false bool_of_env
let host = get "HOST" ~default:None opt_string_of_env
let redirect = get "REDIRECT" ~default:None opt_string_of_env
let image = get "XENIMG" ~default:"www" string_of_env

let mkfs fs path =
  let fat_of_files dir = kv_ro_of_fs (fat_of_files ~dir ()) in
  match fs, get_mode () with
  | `Fat   , _    -> fat_of_files path
  | `Archive, _   -> archive_of_files ~dir:path ()
  | `Crunch, `Xen -> crunch path
  | `Crunch, _    -> direct_kv_ro path

let filesfs = mkfs fs "../files"
let tmplfs = mkfs fs "../tmpl"
let cons0 = default_console

let stack = match deploy with
  | true ->
    let staticip =
      let address = get_exn "IP" Ipaddr.V4.of_string_exn in
      let netmask = get_exn "NETMASK" Ipaddr.V4.of_string_exn in
      let gateways = get_exn "GATEWAYS" ips_of_env in
      { address; netmask; gateways }
    in
    direct_stackv4_with_static_ipv4 cons0 tap0 staticip
  | false ->
    match net, dhcp with
    | `Direct, false -> direct_stackv4_with_default_ipv4 cons0 tap0
    | `Direct, true  -> direct_stackv4_with_dhcp cons0 tap0
    | `Socket, _     -> socket_stackv4 cons0 [Ipaddr.V4.any]

let libraries = [ "cow.syntax"; "cowabloga"; "rrd" ]
let packages  = [ "cow"; "cowabloga"; "xapi-rrd"; "c3" ]

let sp = Printf.sprintf

let config =
  let h = match host with None -> "None" | Some s -> sp "Some %S" s in
  let r = match redirect with None -> "None" | Some d -> sp "Some %S" d in
  sp "struct let host = %s let redirect = %s end" h r

let main = sp "Make(%s)" config

let http =
  foreign ~libraries ~packages ("Dispatch." ^ main)
    (console @-> kv_ro @-> kv_ro @-> http @-> clock @-> job)

let https =
  let libraries = "tls" :: "tls.mirage" :: "mirage-http" :: libraries in
  let packages = "tls" :: "tls" :: "mirage-http" :: packages in
  foreign ~libraries ~packages ("Dispatch_tls." ^ main)
    (console @-> kv_ro @-> kv_ro @-> stackv4 @-> kv_ro @-> clock @-> job)

let err fmt = Printf.ksprintf (fun msg ->
    Printf.eprintf "\n\027[31m[ERROR]\027[m     %s, stopping.\n%!" msg;
    exit 1
  ) fmt

let () =
  let tracing = None in
  (* let tracing = mprof_trace ~size:10000 () in *)
  register ?tracing image [ match tls with
      | false ->
        let server = http_server (conduit_direct stack) in
        let clock = default_clock in
        http  $ default_console $ filesfs $ tmplfs $ server $ clock
      | true ->
        let pr = get ~default:None "TRAVIS_PULL_REQUEST" opt_string_of_env in
        let secrets = get "SECRETS" ~default:`Crunch fat_of_env in
        let clock = default_clock in
        let tls =
          match pr with
          | None | Some "false" -> mkfs secrets "../tls"
          | _ ->
            (* we are running inside a PR in Travis CI. Don't try to
               get the server certificates. *)
            mkfs `Crunch "../src"
        in
        https $ default_console $ filesfs $ tmplfs $ stack $ tls $ clock
    ]
