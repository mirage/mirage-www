open Mirage

let dream =
  main "Unikernel.Make"
    ~packages:[ package "mirageio" ]
    (pclock @-> time @-> stackv4v6 @-> job)

let () =
  register "dream"
    [
      dream $ default_posix_clock $ default_time
      $ generic_stackv4v6 default_network;
    ]
