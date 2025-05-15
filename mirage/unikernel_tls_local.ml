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

module Make
    (Stack : Tcpip.Stack.V4V6) =
struct
  module WWW = Mirageio.Make (Stack)

  let restart_before_expire = function
    | server :: _, _ -> (
        let expiry = snd (X509.Certificate.validity server) in
        let diff = Ptime.diff expiry (Ptime.v (Mirage_ptime.now_d_ps ())) in
        match Ptime.Span.to_int_s diff with
        | None -> invalid_arg "couldn't convert span to seconds"
        | Some x when x < 0 -> invalid_arg "diff is negative"
        | Some x ->
            Lwt.async (fun () ->
                let+ () =
                  Time.sleep_ns
                    (Int64.sub (Duration.of_sec x) (Duration.of_day 1))
                in
                exit 42))
    | _ -> ()

  let start _ _ _ stack { http_port; https_port; host; redirect } =
    let http =
      WWW.Dream.(
        http ~port:http_port (Stack.tcp stack) @@ fun req ->
        let uri = ("https://" ^ Domain_name.to_string host) ^ target req in
        redirect ~status:`Moved_Permanently req uri)
    in
    let https =
      match redirect with
      | None -> WWW.https ~port:https_port stack
      | Some domain ->
          WWW.Dream.(
            https ~port:https_port (Stack.tcp stack) @@ fun req ->
            let uri = domain ^ target req in
            redirect ~status:`Moved_Permanently req uri)
    in
    Lwt.join [ http; https ]
end
