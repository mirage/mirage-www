(* Shared CLI terms *)
open Cmdliner

let docs = "UNIKERNEL PARAMETERS"
let ip_address = Arg.conv (Ipaddr.of_string, Ipaddr.pp)

let https_port =
  let doc =
    Arg.info ~docv:"PORT" ~docs
      ~doc:"Port to listen on for encrypted HTTPS connections" [ "https-port" ]
  in
  Arg.(value & opt int 443 doc)

let http_port =
  let doc =
    Arg.info ~docs ~docv:"PORT"
      ~doc:"Port to listen on for plain HTTP connections" [ "http-port" ]
  in
  Arg.(value & opt int 80 doc)

let redirect =
  let env = Cmd.Env.info "REDIRECT" in
  let doc =
    Arg.info ~docs ~docv:"URL" ~env
      ~doc:
        "Where to redirect to. Must start with http:// or https://. When tls \
         is enabled, the default is https://$HOST, with the effect that all \
         http requests will be redirected to https"
      [ "redirect" ]
  in
  Arg.(value & opt (some string) None doc)

let host =
  let env = Cmd.Env.info "HOST" in
  let domain =
    let of_string str =
      match Domain_name.of_string str with
      | Ok d -> Domain_name.host d
      | Error _ as e -> e
    in
    Arg.conv (of_string, Domain_name.pp)
  in
  let doc =
    Arg.info ~docs ~doc:"Hostname of the unikernel." ~docv:"URL" ~env [ "host" ]
  in
  let localhost = Domain_name.(host_exn (of_string_exn "localhost")) in
  Arg.(value & opt domain localhost doc)

let metrics_ip =
  let doc =
    Arg.info ~docs ~doc:"IP of InfluxDB server to transmit metrics to"
      [ "metrics-ip" ]
  in
  Arg.(required & opt (some ip_address) None doc)

let metrics_port =
  let doc =
    Arg.info ~docs ~doc:"Port of InfluxDB server to transmit metrics to"
      [ "metrics-port" ]
  in
  Arg.(value & opt (some int) None doc)

let metrics_hostname =
  let doc =
    Arg.info ~docs ~doc:"Hostname for the metrics" [ "metrics-hostname" ]
  in
  Arg.(value & opt (some string) None doc)
