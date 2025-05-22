open Mirage

let main = main ~packages:[ package "duration" ] "Unikernel" job
let () = register "heads1" [ main ]
