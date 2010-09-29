open Printf
open Cohttp
open Log
open Lwt

module Resp = struct

  (* dynamic response *)
  let dyn req body =
    let status = `OK in
    let headers = [] in
    Http_daemon.respond ~body ~headers ~status ()

  (* dispatch non-file URLs *)
  let dispatch req = function
    | [] | "index.html" :: [] ->
        let b = Pages.Index.t in
        (dyn req b)
    | "" :: "code" :: [] ->
        let b = Pages.Code.t in
        (dyn req b)
    | x -> 
        (Http_daemon.respond_not_found ~url:(Http_request.path req) ())
end

(* handle exceptions with a 500 *)
let exn_handler exn =
  let body = Printexc.to_string exn in
  logmod "HTTP" "ERROR: %s" body;
  return ()

(* main callback function *)
let t conn_id req =
  let path = Http_request.path req in

  logmod "HTTP" "%s %s [%s]" (Http_common.string_of_method (Http_request.meth req)) path 
    (String.concat "," (List.map (fun (h,v) -> sprintf "%s=%s" h v) 
      (Http_request.params_get req)));

  let path_elem = Str.split (Str.regexp_string "/") path in

  (* determine if it is static or dynamic content *)
  match Filesystem_static.t path with
  |Some body -> 
     Http_daemon.respond ~body ()
  |None ->
     Resp.dispatch req path_elem 
