open Mirage

(* If the Unix `MODE` is set, the choice of configuration changes:
   MODE=crunch (or nothing): use static filesystem via crunch
   MODE=fat: use FAT and block device (run ./make-fat-images.sh)
 *)
let static_fs =
    Driver.KV_RO {
    KV_RO.name = "files";
    dirname    = "../files";
  }

let static_tmpl =
  Driver.KV_RO {
    KV_RO.name = "tmpl";
    dirname    = "../tmpl";
  }

let fat_fs =
  let block = {
    Block.name = "fs_block";
    filename   = "files.img";
    read_only  = true;
  } in
  Driver.Fat_KV_RO {
    Fat_KV_RO.name = "files";
    block;
  }

let fat_tmpl =
  let block = {
    Block.name = "tmpl_block";
    filename   = "tmpl.img";
    read_only  = true;
  } in
  Driver.Fat_KV_RO {
    Fat_KV_RO.name = "tmpl";
    block;
  }

let http =
 let ip =
    let open IP in
    let address = Ipaddr.V4.of_string_exn "128.232.97.54" in
    let netmask = Ipaddr.V4.of_string_exn "255.255.255.224" in
    let gateway = [Ipaddr.V4.of_string_exn "128.232.97.33"] in
    let config = IPv4 { address; netmask; gateway } in
    { name = "www4"; config; networks = [ Network.Tap0 ] }
  in
  Driver.HTTP {
    HTTP.port  = 80;
    address    = None;
    ip
  }

let mode =
  try begin
     match String.lowercase (Unix.getenv "MODE") with
     | "fat" -> `Fat
     | _ -> `Crunch
  end with Not_found -> `Crunch

let drivers =
  match mode with
  | `Crunch -> [Driver.console; static_fs; static_tmpl; http]
  | `Fat -> [Driver.console; fat_fs; fat_tmpl; http]

let () =
  Mirage.add_to_opam_packages ["cow"; "cowabloga"];
  Mirage.add_to_ocamlfind_libraries ["cow.syntax";"cowabloga"];
  Job.register [
    "Dispatch.Main", drivers
  ]
