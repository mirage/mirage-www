open Mirage

let mkip address netmask gateways =
  let address = Ipaddr.V4.of_string_exn address in
  let netmask = Ipaddr.V4.of_string_exn netmask in
  let gateways = List.map Ipaddr.V4.of_string_exn gateways in
  { address; netmask; gateways }

let mkfs fs =
  let mode =
    try match String.lowercase (Unix.getenv "FS") with
      | "fat" -> `Fat
      | _     -> `Crunch
    with Not_found -> `Crunch
  in
  let fat_ro dir =
    kv_ro_of_fs (fat_of_files ~dir ())
  in
  match mode, get_mode () with
  | `Fat,    _    -> fat_ro fs
  | `Crunch, `Xen -> crunch fs
  | `Crunch, _    -> direct_kv_ro fs

let filesfs = mkfs "../files"
let tmplfs = mkfs "../tmpl"
let staticip = mkip "128.232.97.54" "255.255.255.224" [ "128.232.97.33" ]

let https =
  let net =
    try match Sys.getenv "NET" with
      | "socket" -> `Socket
      | _        -> `Direct
    with Not_found -> `Direct
  in
  let dhcp =
    try match Sys.getenv "DHCP" with
      | "1" | "true" | "yes" -> true
      | _  -> false
    with Not_found -> false
  in
  let deploy =
    try match Sys.getenv "DEPLOY" with
      | "1" | "true" | "yes" -> true
      | _ -> false
    with Not_found -> false
  in
  let stack console =
    match deploy with
    | true -> direct_stackv4_with_static_ipv4 console tap0 staticip
    | false ->
      match net, dhcp with
      | `Direct, false -> direct_stackv4_with_default_ipv4 console tap0
      | `Direct, true  -> direct_stackv4_with_dhcp console tap0
      | `Socket, _     -> socket_stackv4 console [Ipaddr.V4.any]
  in
  let port =
    try match Sys.getenv "PORT" with
      | "" -> 80
      | s  -> int_of_string s
    with Not_found -> 80
  in
  let server = conduit_direct (stack default_console) in
  let mode = `TCP (`Port port) in
  http_server mode server

let main =
  let libraries = [ "cow.syntax"; "cowabloga" ] in
  let packages = [ "cow"; "cowabloga" ] in
  foreign ~libraries ~packages "Dispatch.Main"
    (console @-> kv_ro @-> kv_ro @-> http @-> job)

let () =
  let tracing = None in
  (* let tracing = mprof_trace ~size:10000 () in *)
  register ?tracing "www" [
    main $ default_console $ filesfs $ tmplfs $ https
  ]
