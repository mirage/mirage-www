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

let fat_ro file =
  kv_ro_of_fs (fat (block_of_file file))

let fs = match mode with
  | `Fat    -> fat_ro "files.img"
  | `Crunch -> crunch "../files"

let tmpl = match mode with
  | `Fat    -> fat_ro "tmpl.img"
  | `Crunch -> crunch "../tmpl"

let server = http_server 80 (default_ip [tap0])

let main =
  let libraries = [ "cow.syntax"; "cowabloga" ] in
  let packages = [ "cow";"cowabloga" ] in
  foreign ~libraries ~packages "Dispatch.Main"
    (console @-> kv_ro @-> kv_ro @-> http @-> job)

let () =
  register "www" [
    main $ default_console $ fs $ tmpl $ server
  ]
