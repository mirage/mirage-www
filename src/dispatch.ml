open Printf
open Lwt
open Cow

module Resp = struct

  (* dynamic response *)
  let dyn ?(headers=[]) req body =
    printf "Dispatch: dynamic URL %s\n%!" (Cohttp.Request.path req);
    lwt body = body in
    let status = `OK in
    Cohttp.Server.respond ~body ~headers ~status ()

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
    | x                      -> Cohttp.Server.respond_not_found ~url:(Cohttp.Request.path req) ()
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
let t static conn_id req =
  let path = Cohttp.Request.path req in
  let path_elem =
    remove_empty_tail (Re_str.split_delim (Re_str.regexp_string "/") path)
  in

  (* determine if it is static or dynamic content *)
  match_lwt static#read path with
  |Some body ->
     lwt body = Util.string_of_stream body in
     Cohttp.Server.respond ~body ()
  |None ->
     Resp.dispatch req path_elem
