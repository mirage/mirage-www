open Printf
open Log
open Lwt
open Cow

module Resp = struct

  (* dynamic response *)
  let dyn ?(headers=[]) req body =
    let status = `OK in
    Http.Daemon.respond ~body ~headers ~status ()

  (* dispatch non-file URLs *)
  let dispatch req = function
    | [] | "index.html" :: [] -> dyn req Pages.Index.t
    | "resources" :: [] -> dyn req Pages.Resources.t
    | "about" :: [] -> dyn req Pages.About.t
    | "blog" :: tl -> 
        let headers, t = Pages.Blog.t tl in
        dyn ~headers req t
    | "tag" :: tl -> dyn req (Pages.Blog.tag tl)
    | "styles" :: "index.css" :: [] -> dyn req Style.t
    | x -> (Http.Daemon.respond_not_found ~url:(Http.Request.path req) ())
end

(* handle exceptions with a 500 *)
let exn_handler exn =
  let body = Printexc.to_string exn in
  logmod "HTTP" "ERROR: %s" body;
  return ()

(* main callback function *)
let t conn_id req =
  let path = Http.Request.path req in

  logmod "HTTP" "%s %s %s [%s]" (Http.Request.client_addr req) (Http.Common.string_of_method (Http.Request.meth req)) path 
    (String.concat "," (List.map (fun (h,v) -> sprintf "%s=%s" h v) 
      (Http.Request.params_get req)));
  logmod "header" "Connection: %s" (String.concat ", " (Http.Request.header req ~name:"connection"));
  let path_elem = Str.split (Str.regexp_string "/") path in

  (* determine if it is static or dynamic content *)
  match Filesystem_static.t path with
  |Some body -> 
     Http.Daemon.respond ~body ()
  |None ->
     Resp.dispatch req path_elem 
