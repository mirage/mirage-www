open Cmdliner

type t = { http_port : int; redirect : string option }

let setup =
  Term.(
    const (fun http_port redirect -> { http_port; redirect })
    $ Cli.http_port $ Cli.redirect)

module Make
    (Stack : Tcpip.Stack.V4V6) =
struct
  module WWW = Mirageio.Make (Stack)

  let start stack { http_port = port; redirect } =
    match redirect with
    | None -> WWW.http ~port stack
    | Some domain ->
        WWW.Dream.(
          http ~port (Stack.tcp stack) @@ fun req ->
          let uri = domain ^ target req in
          redirect ~status:`Moved_Permanently req uri)
end
