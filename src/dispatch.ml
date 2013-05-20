open Printf
open Lwt
open Cow

module CL = Cohttp_lwt_mirage
module C = Cohttp

module Resp = struct

  (* dynamic response *)
  let dyn ?(headers=[]) req body =
    printf "Dispatch: dynamic URL %s\n%!" (CL.Request.path req);
    lwt body = body in
    let status = `OK in
    let headers = C.Header.of_list headers in
    CL.Server.respond_string ~headers ~status ~body ()

  let dyn_xhtml = dyn ~headers:Pages.content_type_xhtml

  (* dispatch non-file URLs *)
  let dispatch req =
    function
    | [] | [""]
    | [""; "index.html"]         -> dyn_xhtml req Pages.Index.t
    | [""; "resources"]          -> dyn_xhtml req Pages.Resources.t
    | [""; "about"]              -> dyn_xhtml req Pages.About.t
    | "" :: "blog" :: tl ->
        let headers, t = Pages.Blog.t tl in
        dyn ~headers req t
    | "" :: "wiki" :: "tag" :: tl  -> dyn_xhtml req (Pages.Wiki.tag tl)
    | "" :: "wiki" :: page         ->
        let headers, t = Pages.Wiki.t page in
        dyn ~headers req t
    | [""; "styles";"index.css"] -> dyn ~headers:Style.content_type_css req Style.t
    | x                      -> CL.Server.respond_not_found ~uri:(CL.Request.uri req) ()
end

(* handle exceptions with a 500 *)
let exn_handler exn =
  let body = Printexc.to_string exn in
  eprintf "HTTP: ERROR: %s\n" body;
  return ()

let rec remove_empty_tail = function
  | [] | [""] -> []
  | hd::tl -> hd :: remove_empty_tail tl

(* main callback function *)
let t conn_id ?body req =
  let path = CL.Request.path req in
  let path_elem =
    remove_empty_tail (Re_str.split_delim (Re_str.regexp_string "/") path)
  in
  lwt static =
    eprintf "finding the static kv_ro block device\n";
    OS.Devices.find_kv_ro "static" >>=
    function
    | None   -> Printf.printf "fatal error, static kv_ro not found\n%!"; exit 1
    | Some x -> return x in

  (* determine if it is static or dynamic content *)
  match_lwt static#read path with
  |Some body ->
     lwt body = Util.string_of_stream body in
     CL.Server.respond_string ~status:`OK ~body ()
  |None ->
     Resp.dispatch req path_elem
