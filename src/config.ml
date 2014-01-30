open Mirage

(* If the Unix `MODE` is set, the choice of configuration changes:
   MODE=crunch (or nothing): use static filesystem via crunch
   MODE=fat: use FAT and block device (run ./make-fat-images.sh)
 *)
let mode =
  try match String.lowercase (Unix.getenv "FS") with
    | "fat" -> `Fat
    | _     -> `Crunch
  with Not_found ->
    `Crunch

let fat_ro dir =
  kv_ro_of_fs (fat_of_files ~dir ())

let fs = match mode with
  | `Fat    -> fat_ro "files.img"
  | `Crunch -> crunch "../files"

let tmpl = match mode with
  | `Fat    -> fat_ro "tmpl.img"
  | `Crunch -> crunch "../tmpl"


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
  with Not_found -> false

let stack console =
  match net, dhcp with
  | `Direct, true  -> direct_stackv4_with_dhcp console tap0
  | `Direct, false -> direct_stackv4_with_default_ipv4 console tap0
  | `Socket, _     -> socket_stackv4 console [Ipaddr.V4.any]

let server =
  http_server 80 (stack default_console)

let main =
  let libraries = [ "cow.syntax"; "cowabloga" ] in
  let packages = [ "cow";"cowabloga" ] in
  foreign ~libraries ~packages "Dispatch.Main"
    (console @-> kv_ro @-> kv_ro @-> http @-> job)

let () =
  register "www" [
    main $ default_console $ fs $ tmpl $ server
  ]
