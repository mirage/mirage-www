open Printf
open Http
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
    | [] | "index.html" :: [] -> dyn req Pages.Index.t
    | "resources" :: [] -> dyn req Pages.Resources.t
    | "about" :: [] -> dyn req Pages.About.t
    | "blog" :: tl -> dyn req (Pages.Blog.t tl)
    | "tag" :: tl -> dyn req (Pages.Blog.tag tl)
    | x -> (Http_daemon.respond_not_found ~url:(Http_request.path req) ())
end

(* handle exceptions with a 500 *)
let exn_handler exn =
  let body = Printexc.to_string exn in
  logmod "HTTP" "ERROR: %s" body;
  return ()

(* main callback function *)
let t conn_id req =
  let path = Http_request.path req in

  logmod "HTTP" "%s %s %s [%s]" (Http_request.client_addr req) (Http_common.string_of_method (Http_request.meth req)) path 
    (String.concat "," (List.map (fun (h,v) -> sprintf "%s=%s" h v) 
      (Http_request.params_get req)));
  logmod "header" "Connection: %s" (String.concat ", " (Http_request.header req ~name:"connection"));
  let path_elem = Str.split (Str.regexp_string "/") path in

  (* determine if it is static or dynamic content *)
  match Filesystem_static.t path with
  |Some body -> 
     Http_daemon.respond ~body ()
  |None ->
     Resp.dispatch req path_elem 
