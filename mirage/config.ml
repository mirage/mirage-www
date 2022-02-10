open Mirage

type tls = No | Local | Letsencrypt

let tls_to_string = function
  | No -> "false"
  | Local -> "local"
  | Letsencrypt -> "true"

let tls_conv =
  Cmdliner.Arg.conv
    ( (function
      | "false" -> Ok No
      | "local" -> Ok Local
      | "true" -> Ok Letsencrypt
      | v -> Error (`Msg (v ^ " is invalid"))),
      Fmt.(using tls_to_string string) )

let tls =
  Key.Arg.conv ~conv:tls_conv ~runtime_conv:"tls" ~serialize:(fun fmt ->
    function
    | No -> Format.fprintf fmt "`False"
    | Local -> Format.fprintf fmt "`Local"
    | Letsencrypt -> Format.fprintf fmt "`True")

let tls_key =
  let doc =
    Key.Arg.info ~doc:"Enable serving the website over https." ~docv:"BOOL"
      ~env:"TLS" [ "tls" ]
  in
  Key.(create "tls" Arg.(opt ~stage:`Configure tls No doc))

let http_port =
  let doc =
    Key.Arg.info ~doc:"Port to listen on for plain HTTP connections"
      ~docv:"PORT" [ "http-port" ]
  in
  Key.(create "http-port" Arg.(opt ~stage:`Both int 80 doc))

let host_key =
  let doc =
    Key.Arg.info ~doc:"Hostname of the unikernel." ~docv:"URL" ~env:"HOST"
      [ "host" ]
  in
  Key.(create "host" Arg.(opt string "localhost" doc))

let redirect_key =
  let doc =
    Key.Arg.info
      ~doc:
        "Where to redirect to. Must start with http:// or https://. When tls \
         is enabled, the default is https://$HOST, with the effect that all \
         http requests will be redirected to https"
      ~docv:"URL" ~env:"REDIRECT" [ "redirect" ]
  in
  Key.(create "redirect" Arg.(opt (some string) None doc))

let keys = Key.[ v host_key; v redirect_key; v http_port ]

let https_port =
  let doc =
    Key.Arg.info ~doc:"Port to listen on for encrypted HTTPS connections"
      ~docv:"PORT" [ "https-port" ]
  in
  Key.(create "https-port" Arg.(opt ~stage:`Both int 443 doc))

let dns_key =
  let doc =
    Key.Arg.info ~doc:"nsupdate key (name:type:value,...)" [ "dns-key" ]
  in
  Key.(create "dns-key" Arg.(required string doc))

let dns_server =
  let doc = Key.Arg.info ~doc:"dns server IP" [ "dns-server" ] in
  Key.(create "dns-server" Arg.(required ip_address doc))

let dns_port =
  let doc = Key.Arg.info ~doc:"dns server port" [ "dns-port" ] in
  Key.(create "dns-port" Arg.(opt int 53 doc))

let key_seed =
  let doc = Key.Arg.info ~doc:"certificate key seed" [ "key-seed" ] in
  Key.(create "key-seed" Arg.(required string doc))

let additional_hostnames =
  let doc =
    Key.Arg.info ~doc:"Additional names (used for certificates)"
      [ "additional-hostname" ]
  in
  Key.(create "additional-hostnames" Arg.(opt (list string) [] doc))

let tls_only_keys =
  Key.
    [
      v https_port;
      v dns_key;
      v dns_server;
      v dns_port;
      v key_seed;
      v additional_hostnames;
    ]

let packages =
  [
    package "mirageio";
    package ~build:true
      ~pin:
        "git+https://github.com/TheLortex/ocaml-yaml.git#7e1f117645ea10fbec2bd3dbbf0d8f581cce891f"
      "yaml";
  ]

let https =
  let keys = keys @ tls_only_keys in
  let packages = package ~sublibs:[ "mirage" ] "dns-certify" :: packages in
  main "Unikernel_tls.Make" ~keys ~packages
    (random @-> pclock @-> time @-> stackv4v6 @-> job)

let https_local =
  let keys = keys @ Key.[ v https_port; v additional_hostnames ] in
  main "Unikernel_tls_local.Make" ~keys ~packages
    (random @-> pclock @-> time @-> stackv4v6 @-> job)

let http =
  main "Unikernel.Make" ~keys ~packages (pclock @-> time @-> stackv4v6 @-> job)

let app =
  match_impl ~default:http (Key.value tls_key)
    [
      (No, http);
      (Local, https_local $ default_random);
      (Letsencrypt, https $ default_random);
    ]

let () =
  register "www"
    [
      app $ default_posix_clock $ default_time
      $ generic_stackv4v6 default_network;
    ]
