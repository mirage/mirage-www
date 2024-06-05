open Mirage
open Cmdliner

type tls = No | Local | Letsencrypt

let tls_to_string = function
  | No -> "false"
  | Local -> "local"
  | Letsencrypt -> "true"

let tls_conv =
  Arg.conv
    ( (function
      | "false" -> Ok No
      | "local" -> Ok Local
      | "true" -> Ok Letsencrypt
      | v -> Error (`Msg (v ^ " is invalid"))),
      Fmt.(using tls_to_string string) )

let tls_key =
  let env = Cmd.Env.info "TLS" in
  let doc =
    Arg.info ~doc:"Enable serving the website over https." ~docv:"BOOL" ~env
      [ "tls" ]
  in
  Key.(create "tls" Arg.(opt tls_conv No doc))

let packages = [ package "mirageio"; package ~build:true "yaml" ]

let packages_v =
  Key.if_ Key.is_solo5 [ package ~scope:`Switch "solo5" ] []

let https =
  let runtime_args = [ runtime_arg ~pos:__POS__ "Unikernel_tls.setup" ] in
  let packages = package ~sublibs:[ "mirage" ] "dns-certify" :: packages in
  main "Unikernel_tls.Make" ~runtime_args ~packages ~packages_v
    (random @-> pclock @-> time @-> stackv4v6 @-> job)

let https_local =
  let runtime_args = [ runtime_arg ~pos:__POS__ "Unikernel_tls_local.setup" ] in
  main "Unikernel_tls_local.Make" ~runtime_args ~packages ~packages_v
    (random @-> pclock @-> time @-> stackv4v6 @-> job)

let http =
  let runtime_args = [ runtime_arg ~pos:__POS__ "Unikernel.setup" ] in
  main "Unikernel.Make" ~runtime_args ~packages ~packages_v
    (pclock @-> time @-> stackv4v6 @-> job)

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
  let ip = runtime_arg ~pos:__POS__ "Cli.metrics_ip" in
  let port = runtime_arg ~pos:__POS__ "Cli.metrics_port" in
  let hostname = runtime_arg ~pos:__POS__ "Cli.metrics_hostname" in
  let connect _ modname = function
    | [ _; _; stack; ip; port; hostname ] ->
        code ~pos:__POS__ "Lwt.return (%s.create %s ?port:%s ?hostname:%s %s)"
          modname ip port hostname stack
    | _ -> assert false
  in
  impl
    ~packages:[ package "mirage-monitoring" ]
    ~runtime_args:[ ip; port; hostname ] ~connect "Mirage_monitoring.Make"
    (time @-> pclock @-> stackv4v6 @-> job)

let enable_metrics =
  let doc = Key.Arg.info ~doc:"Enable metrics reporting" [ "metrics" ] in
  Key.(create "metrics" Arg.(flag doc))

let optional_monitoring time pclock stack =
  if_impl (Key.value enable_metrics)
    (mirage_monitoring $ time $ pclock $ stack)
    noop

let () =
  register "www"
    [
      optional_monitoring default_time default_posix_clock internal_stack;
      app $ default_posix_clock $ default_time $ external_stack;
    ]
