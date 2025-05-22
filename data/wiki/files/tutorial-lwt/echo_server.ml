open Mirage

let main =
  let packages = [ package "duration"; package ~max:"0.2.0" "randomconv" ] in
  main ~packages "Unikernel" job

let () = register "echo_server" [ main ]
