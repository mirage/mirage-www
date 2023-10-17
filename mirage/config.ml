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

let packages = [ package "mirageio"; package ~build:true "yaml" ]

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

let separate_networks =
  let doc =
    Key.Arg.info ~doc:"Separate external and internal networks"
      [ "separate-networks" ]
  in
  Key.(create "separate-networks" Arg.(flag doc))

let external_netif =
  Key.(
    if_impl is_solo5
      (netif ~group:"external" "external")
      (netif ~group:"external" "tap0"))

let external_stack =
  if_impl
    (Key.value separate_networks)
    (generic_stackv4v6 ~group:"external" external_netif)
    (generic_stackv4v6 default_network)

let internal_netif =
  Key.(
    if_impl is_solo5
      (netif ~group:"internal" "internal")
      (netif ~group:"internal" "tap1"))

let internal_stack =
  if_impl
    (Key.value separate_networks)
    (generic_stackv4v6 ~group:"internal" internal_netif)
    external_stack

let mirage_monitoring =
  let ip_key =
    let ip =
      let doc =
        Key.Arg.info ~doc:"IP of InfluxDB server to transmit metrics to"
          [ "metrics-ip" ]
      in
      Key.(create "metrics-ip" Arg.(required ip_address doc))
    in
    Key.v ip
  in
  let port_key =
    let port =
      let doc =
        Key.Arg.info ~doc:"Port of InfluxDB server to transmit metrics to"
          [ "metrics-port" ]
      in
      Key.(create "metrics-port" Arg.(opt (some int) None doc))
    in
    Key.v port
  in
  let hostname_key =
    let hostname =
      let doc =
        Key.Arg.info ~doc:"Hostname for the metrics" [ "metrics-hostname" ]
      in
      Key.(create "metrics-hostname" Arg.(opt (some string) None doc))
    in
    Key.v hostname
  in
  let connect _ modname = function
    | [ _; _; stack ] ->
        Fmt.str "Lwt.return (%s.create %a ?port:%a ?hostname:%a %s)" modname
          Key.serialize_call ip_key Key.serialize_call port_key
          Key.serialize_call hostname_key stack
    | _ -> assert false
  in
  impl
    ~packages:[ package "mirage-monitoring" ]
    ~keys:[ ip_key; port_key; hostname_key ]
    ~connect "Mirage_monitoring.Make"
    (time @-> pclock @-> stackv4v6 @-> job)

let enable_metrics =
  let doc = Key.Arg.info ~doc:"Enable metrics reporting" [ "metrics" ] in
  Key.(create "metrics" Arg.(flag doc))

let optional_monitoring time pclock stack =
  if_impl (Key.value enable_metrics)
    (mirage_monitoring $ time $ pclock $ stack)
    noop

let syslog =
  let syslog =
    let doc = Key.Arg.info ~doc:"syslog host IP" ["syslog"] in
    Key.(v (create "syslog" Arg.(opt (some ip_address) None doc)))
  in
  let hostname_key =
    let hostname =
      let doc =
        Key.Arg.info ~doc:"Hostname for syslog" [ "syslog-hostname" ]
      in
      Key.(create "syslog-hostname" Arg.(opt (some string) None doc))
    in
    Key.v hostname
  in
  let connect _ modname = function
    | [ _ ; stack ] ->
      Fmt.str "Lwt.return (match %a with\
               | None -> Logs.warn (fun m -> m \"no syslog specified, dumping on stdout\")\
               | Some ip -> Logs.set_reporter (%s.create %s ip ~hostname:%a ()))"
        Key.serialize_call syslog modname stack
        Key.serialize_call hostname_key
    | _ -> assert false
  in
  impl
    ~packages:[ package ~sublibs:["mirage"] ~min:"0.4.0" "logs-syslog" ]
    ~keys:[ hostname_key ; syslog ]
    ~connect "Logs_syslog_mirage.Udp"
    (pclock @-> stackv4v6 @-> job)

let enable_syslog =
  let doc = Key.Arg.info ~doc:"Enable syslog" [ "syslog" ] in
  Key.(create "syslog" Arg.(flag doc))

let optional_syslog pclock stack =
  if_impl (Key.value enable_syslog)
    (syslog $ pclock $ stack)
    noop

let () =
  register "www"
    [
      optional_monitoring default_time default_posix_clock internal_stack;
      optional_syslog default_posix_clock internal_stack;
      app $ default_posix_clock $ default_time $ external_stack;
    ]
