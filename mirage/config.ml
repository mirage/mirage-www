open Mirage

let tls_key =
  let doc =
    Key.Arg.info ~doc:"Enable serving the website over https." ~docv:"BOOL"
      ~env:"TLS" [ "tls" ]
  in
  Key.(create "tls" Arg.(opt ~stage:`Configure bool false doc))

let http_port =
  let doc =
    Key.Arg.info ~doc:"Port to listen on for plain HTTP connections"
      ~docv:"PORT" [ "http-port" ]
  in
  Key.(create "http-port" Arg.(opt ~stage:`Both int 80 doc))

let keys = Key.[ v http_port ]

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

let https =
  let keys = keys @ tls_only_keys in
  main "Unikernel_tls.Make" ~keys
    ~packages:
      [ package "mirageio"; package ~sublibs:[ "mirage" ] "dns-certify" ]
    (random @-> pclock @-> time @-> stackv4v6 @-> job)

let http =
  main "Unikernel.Make" ~keys
    ~packages:[ package "mirageio" ]
    (pclock @-> time @-> stackv4v6 @-> job)

let app = if_impl (Key.value tls_key) (https $ default_random) http

let () =
  register "www"
    [
      app $ default_posix_clock $ default_time
      $ generic_stackv4v6 default_network;
    ]
