open Lwt.Syntax

module Make
    (Random : Mirage_random.S)
    (Pclock : Mirage_clock.PCLOCK)
    (Time : Mirage_time.S)
    (Stack : Tcpip.Stack.V4V6) =
struct
  module Certify = Dns_certify_mirage.Make (Random) (Pclock) (Time) (Stack)
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

  let tls_init stack hostname additional_hostnames =
    let* certificates_result =
      Certify.retrieve_certificate stack ~dns_key:(Key_gen.dns_key ()) ~hostname
        ~additional_hostnames ~key_seed:(Key_gen.key_seed ())
        (Key_gen.dns_server ()) (Key_gen.dns_port ())
    in
    match certificates_result with
    | Error (`Msg m) -> Lwt.fail_with m
    | Ok certificates ->
        restart_before_expire certificates;
        let conf = Tls.Config.server ~certificates:(`Single certificates) () in
        Lwt.return conf

  let start _ _ _ stack =
    let hostname = Domain_name.(of_string_exn (Key_gen.host ()) |> host_exn) in
    let additional_hostnames =
      List.map
        (fun n -> Domain_name.(of_string_exn n))
        (Key_gen.additional_hostnames ())
    in
    let* cfg = tls_init stack hostname additional_hostnames in
    Lwt.join
      [
        WWW.http ~port:(Key_gen.http_port ()) stack;
        WWW.https ~port:(Key_gen.https_port ()) ~tls:cfg stack;
      ]
end
