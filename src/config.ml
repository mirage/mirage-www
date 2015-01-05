open Mirage

(* If the Unix `FS` is set, the choice of configuration changes:
   FS=crunch (or nothing): use static filesystem via crunch
   FS=fat: use FAT and block device
 *)
let mode =
  try match String.lowercase (Unix.getenv "FS") with
    | "fat" -> `Fat
    | _     -> `Crunch
  with Not_found ->
    `Crunch

let fat_ro dir =
  kv_ro_of_fs (fat_of_files ~dir ())

(** In Unix mode, use the passthrough filesystem for
    files to avoid a huge crunch build time *)
let fs =
  match mode, get_mode () with
  | `Fat, _    -> fat_ro "../files"
  | `Crunch, `Xen -> crunch "../files"
  | `Crunch, _ -> direct_kv_ro "../files"

let tmpl =
  match mode, get_mode () with
  | `Fat, _    -> fat_ro "../tmpl"
  | `Crunch, `Xen -> crunch "../tmpl"
  | `Crunch, _ -> direct_kv_ro "../tmpl"

let net =
  try match Sys.getenv "NET" with
    | "direct" -> `Direct
    | "socket" -> `Socket
    | _        -> `Direct
  with Not_found -> `Direct

let dhcp =
  try match Sys.getenv "DHCP" with
    | "" -> false
    | _  -> true
  with Not_found -> true

let stack console =
  match net, dhcp with
  | `Direct, true  -> direct_stackv4_with_dhcp console tap0
  | `Direct, false -> direct_stackv4_with_default_ipv4 console tap0
  | `Socket, _     -> socket_stackv4 console [Ipaddr.V4.any]

let port =
  try match Sys.getenv "PORT" with
    | "" -> 80
    | s  -> int_of_string s
  with Not_found -> 80

let server =
  conduit_direct (stack default_console)

let http_srv =
  let mode = `TCP (`Port port) in
  http_server mode server

let main =
  let libraries = [ "cow.syntax"; "cowabloga" ] in
  let packages = [ "cow";"cowabloga" ] in
  foreign ~libraries ~packages "Dispatch.Main"
    (console @-> kv_ro @-> kv_ro @-> http @-> job)

let () =
  let tracing = None in
  (* let tracing = mprof_trace ~size:10000 () in *)
  register ?tracing "www" [
    main $ default_console $ fs $ tmpl $ http_srv
  ]
