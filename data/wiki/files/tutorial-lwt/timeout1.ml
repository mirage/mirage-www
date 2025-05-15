open Mirage

let main =
  main
    ~packages:[ package "duration"; package ~max:"0.2.0" "randomconv" ]
    "Unikernel.Timeout1"
    (job)

let () = register "timeout1" [ main ]
