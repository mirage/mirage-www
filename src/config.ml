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
  Driver.HTTP {
    HTTP.port  = 80;
    address    = None;
    ip         = IP.local Network.Tap0;
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
  Mirage.add_to_opam_packages ["cow"];
  Mirage.add_to_ocamlfind_libraries ["cow.syntax";"cowabloga"];
  Job.register [
    "Dispatch.Main", drivers
  ]
