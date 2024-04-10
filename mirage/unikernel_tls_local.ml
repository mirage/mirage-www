open Lwt.Syntax

module Make
    (Random : Mirage_random.S)
    (Pclock : Mirage_clock.PCLOCK)
    (Time : Mirage_time.S)
    (Stack : Tcpip.Stack.V4V6) =
struct
  module WWW = Mirageio.Make (Pclock) (Time) (Stack)

  let restart_before_expire = function
    | server :: _, _ -> (
        let expiry = snd (X509.Certificate.validity server) in
        let diff = Ptime.diff expiry (Ptime.v (Pclock.now_d_ps ())) in
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

  let start _ _ _ stack =
    let host = Key_gen.host () in
    let redirect = Key_gen.redirect () in
    let http =
      WWW.Dream.(
        http ~port:(Key_gen.http_port ()) (Stack.tcp stack) @@ fun req ->
        redirect ~status:`Moved_Permanently req ("https://" ^ host))
    in
    let https =
      match redirect with
      | None -> WWW.https ~port:(Key_gen.https_port ()) stack
      | Some domain ->
          WWW.Dream.(
            https ~port:(Key_gen.https_port ()) (Stack.tcp stack) @@ fun req ->
            redirect ~status:`Moved_Permanently req domain)
    in
    Lwt.join [ http; https ]
end
