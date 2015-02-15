open Mirage

(** [split c s] splits string [s] at every occurrence of character [c] *)
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

let https =
  let deploy =
    try match Sys.getenv "DEPLOY" with
      | "1" | "true" | "yes" -> true
      | _ -> false
    with Not_found -> false
  in
  let stack console =
    match deploy with
    | true ->
      let staticip =
        let address = Sys.getenv "ADDR" |> Ipaddr.V4.of_string_exn in
        let netmask = Sys.getenv "MASK" |> Ipaddr.V4.of_string_exn in
        let gateways =
          Sys.getenv "GWS" |> split ':' |> List.map Ipaddr.V4.of_string_exn
        in
        { address; netmask; gateways }
      in
      direct_stackv4_with_static_ipv4 console tap0 staticip

    | false ->
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
