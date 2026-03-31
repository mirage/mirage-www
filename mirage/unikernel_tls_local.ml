open Lwt.Syntax
open Cmdliner

type t = {
  host : [ `host ] Domain_name.t;
  http_port : int;
  https_port : int;
  redirect : string option;
}

let setup =
  Term.(
    const (fun host redirect http_port https_port ->
        { host; redirect; http_port; https_port })
    $ Cli.host $ Cli.redirect $ Cli.http_port $ Cli.https_port)

module Make (KV : Mirage_kv.RO) (Stack : Tcpip.Stack.V4V6) = struct
  module Paf = Paf_mirage.Make (Stack.TCP)
  module U = Unikernel.Make (KV) (Stack)

  let start store stack { http_port; https_port; host; redirect = _ } =
    (* HTTP redirects to HTTPS *)
    let* http_t = Paf.init ~port:http_port (Stack.tcp stack) in
    let http_service =
      Paf.http_service ~error_handler:U.error_handler
        (fun _flow _dst reqd ->
          let request = H1.Reqd.request reqd in
          let loc =
            "https://" ^ Domain_name.to_string host ^ request.target
          in
          U.respond_with reqd `Moved_permanently [ ("location", loc) ] "")
    in
    let (`Initialized http) = Paf.serve http_service http_t in
    (* HTTPS serves the site *)
    let* https_t = Paf.init ~port:https_port (Stack.tcp stack) in
    let https_service =
      Paf.http_service ~error_handler:U.error_handler
        (U.request_handler store)
    in
    let (`Initialized https) = Paf.serve https_service https_t in
    Lwt.join [ http; https ]
end
