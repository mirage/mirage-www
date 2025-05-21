open Mirage

let main = main ~packages:[ package "duration" ] "Unikernel.Heads1" job
let () = register "heads1" [ main ]
