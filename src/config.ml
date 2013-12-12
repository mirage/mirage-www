open Mirage

let fs =
  Driver.KV_RO {
    KV_RO.name = "files";
    dirname    = "../files";
  }

let http =
  Driver.HTTP {
    HTTP.port  = 80;
    address    = None;
    ip         = IP.local Network.Tap0;
  }

let () =
  Job.register [
    "Dispatch.Main", [Driver.console; fs; http]
  ]
