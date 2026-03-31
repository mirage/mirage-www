open Lwt.Syntax
open Cmdliner

type t = {
  dns_key : [ `raw ] Domain_name.t * Dns.Dnskey.t;
  key_seed : string;
  dns_server : Ipaddr.t;
  dns_port : int;
  host : [ `host ] Domain_name.t;
  redirect : string option;
  additional_hostnames : [ `raw ] Domain_name.t list;
  http_port : int;
  https_port : int;
}

let docs = Cli.docs

let key =
  Arg.conv ~docv:"HOST:HASH:DATA"
    Dns.Dnskey.
      (name_key_of_string, fun ppf v -> Fmt.string ppf (name_key_to_string v))

let dns_key =
  let doc =
    Arg.info ~docs ~doc:"nsupdate key (name:type:value,...)" [ "dns-key" ]
  in
  Arg.(required & opt (some key) None doc)

let ip_address = Arg.conv (Ipaddr.of_string, Ipaddr.pp)

let dns_server =
  let doc = Arg.info ~docs ~doc:"dns server IP" [ "dns-server" ] in
  Arg.(required & opt (some ip_address) None doc)

let dns_port =
  let doc = Arg.info ~docs ~doc:"dns server port" [ "dns-port" ] in
  Arg.(value & opt int 53 doc)

let key_seed =
  let doc = Arg.info ~docs ~doc:"certificate key seed" [ "key-seed" ] in
  Arg.(required & opt (some string) None doc)

let additional_hostnames =
  let doc =
    Arg.info ~docs ~doc:"Additional names (used for certificates)"
      [ "additional-hostname" ]
  in
  let domain = Arg.conv (Domain_name.of_string, Domain_name.pp) in
  Arg.(value & opt (list domain) [] doc)

let setup =
  Term.(
    const
      (fun
        http_port
        redirect
        https_port
        dns_key
        dns_server
        dns_port
        host
        key_seed
        additional_hostnames
      ->
        {
          http_port;
          redirect;
          https_port;
          dns_key;
          dns_server;
          dns_port;
          host;
          key_seed;
          additional_hostnames;
        })
    $ Cli.http_port $ Cli.redirect $ Cli.https_port $ dns_key $ dns_server
    $ dns_port $ Cli.host $ key_seed $ additional_hostnames)

module Make (KV : Mirage_kv.RO) (Stack : Tcpip.Stack.V4V6) = struct
  module Certify = Dns_certify_mirage.Make (Stack)
  module Paf = Paf_mirage.Make (Stack.TCP)
  module U = Unikernel.Make (KV) (Stack)

  let restart_before_expire = function
    | server :: _, _ -> (
        let expiry = snd (X509.Certificate.validity server) in
        let diff = Ptime.diff expiry (Mirage_ptime.now ()) in
        match Ptime.Span.to_int_s diff with
        | None -> invalid_arg "couldn't convert span to seconds"
        | Some x when x < 0 -> invalid_arg "diff is negative"
        | Some x ->
            Lwt.async (fun () ->
                let+ () =
                  Mirage_sleep.ns
                    (Int64.sub (Duration.of_sec x) (Duration.of_day 1))
                in
                exit 42))
    | _ -> ()

  let tls_init stack
      { host; additional_hostnames; dns_key; key_seed; dns_server; dns_port; _ }
      =
    let* certificates_result =
      Certify.retrieve_certificate stack dns_key ~hostname:host
        ~additional_hostnames ~key_seed dns_server dns_port
    in
    match certificates_result with
    | Error (`Msg m) -> Lwt.fail_with m
    | Ok certificates -> (
        restart_before_expire certificates;
        match Tls.Config.server ~certificates:(`Single certificates) () with
        | Error (`Msg m) -> Lwt.fail_with m
        | Ok conf -> Lwt.return conf)

  let start store stack t =
    let* tls = tls_init stack t in
    (* HTTP redirects to HTTPS *)
    let* http_t = Paf.init ~port:t.http_port (Stack.tcp stack) in
    let http_service =
      Paf.http_service ~error_handler:U.error_handler
        (fun _flow _dst reqd ->
          let request = H1.Reqd.request reqd in
          let loc =
            "https://" ^ Domain_name.to_string t.host ^ request.target
          in
          U.respond_with reqd `Moved_permanently [ ("location", loc) ] "")
    in
    let (`Initialized http) = Paf.serve http_service http_t in
    (* HTTPS serves the site *)
    let* https_t = Paf.init ~port:t.https_port (Stack.tcp stack) in
    let https_service =
      Paf.https_service ~tls ~error_handler:U.error_handler
        (fun flow dst reqd -> U.request_handler store flow dst reqd)
    in
    let (`Initialized https) = Paf.serve https_service https_t in
    Lwt.join [ http; https ]
end
