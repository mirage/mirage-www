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
let fat_of_env = function "fat" -> `Fat | _ -> `Crunch
let opt_string_of_env x = Some x

let err fmt =
  Printf.eprintf ("\027[31m[ERROR]V\027[m         " ^^ fmt ^^ "\n");
  exit 1

let env_info fmt = Printf.printf ("\027[33mENV\027[m         " ^^ fmt ^^ "\n%!")

let get_exn name fn =
  try
    let res = Sys.getenv name in
    env_info "%s => %s" name res;
    fn (String.lowercase res)
  with Not_found ->
    env_info "%s => not set." name;
    raise Not_found

let get name ~default fn = try get_exn name fn with Not_found -> default

let fs = get "FS" ~default:`Crunch fat_of_env
let deploy = get "DEPLOY" ~default:false bool_of_env
let net = get  "NET" ~default:`Direct socket_of_env
let dhcp = get "DHCP" ~default:false bool_of_env
let tls = get "TLS" ~default:false bool_of_env
let host = get "HOST" ~default:None opt_string_of_env

let mkfs path =
  let fat_ro dir = kv_ro_of_fs (fat_of_files ~dir ()) in
  match fs, get_mode () with
  | `Fat,    _    -> fat_ro path
  | `Crunch, `Xen -> crunch path
  | `Crunch, _    -> direct_kv_ro path

let filesfs = mkfs "../files"
let tmplfs = mkfs "../tmpl"
let cons0 = default_console

let stack = match deploy with
  | true ->
    let staticip =
      let address = get_exn "ADDR" Ipaddr.V4.of_string_exn in
      let netmask = get_exn "MASK" Ipaddr.V4.of_string_exn in
      let gateways = get_exn "GWS" ips_of_env in
      { address; netmask; gateways }
    in
    direct_stackv4_with_static_ipv4 cons0 tap0 staticip
  | false ->
    match net, dhcp with
    | `Direct, false -> direct_stackv4_with_default_ipv4 cons0 tap0
    | `Direct, true  -> direct_stackv4_with_dhcp cons0 tap0
    | `Socket, _     -> socket_stackv4 cons0 [Ipaddr.V4.any]

let libraries = [ "cow.syntax"; "cowabloga" ]
let packages  = [ "cow"; "cowabloga" ]

let main = match host with
  | Some host -> Printf.sprintf "Make(struct let host = %S end)" host
  | None      -> "Make_localhost"

let http =
  foreign ~libraries ~packages ("Dispatch." ^ main)
    (console @-> kv_ro @-> kv_ro @-> http @-> job)

let https =
  let libraries = "tls" :: "tls.mirage" :: "mirage-http" :: libraries in
  let packages = "tls" :: "tls" :: "mirage-http" :: packages in
  foreign ~libraries ~packages ("Dispatch_tls." ^ main)
    (console @-> kv_ro @-> kv_ro @-> stackv4 @-> kv_ro @-> clock @-> job)

let err fmt = Printf.ksprintf (fun msg ->
    Printf.eprintf "\n\027[31m[ERROR]\027[m     %s, stopping.\n%!" msg;
    exit 1
  ) fmt

let check_file ~msg file =
  if not (Sys.file_exists file) then err "%s %s is missing" msg file

let () =
  let tracing = None in
  (* let tracing = mprof_trace ~size:10000 () in *)
  register ?tracing "www" [ match tls with
      | false ->
        let server = http_server (conduit_direct stack) in
        http  $ default_console $ filesfs $ tmplfs $ server
      | true ->
        let key = "../tls/tls/server.key" in
        let pem = "../tls/tls/server.pem" in
        check_file ~msg:"The TLS private key" key;
        check_file ~msg:"The TLS certificate" pem;
        let tls = mkfs "../tls" in
        let clock0 = default_clock in
        https $ default_console $ filesfs $ tmplfs $ stack $ tls $ clock0
  ]
