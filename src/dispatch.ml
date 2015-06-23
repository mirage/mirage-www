(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt.Infix

module type S =
  functor (C: V1_LWT.CONSOLE) ->
  functor (FS: V1_LWT.KV_RO) ->
  functor (TMPL: V1_LWT.KV_RO) ->
  functor (S: Cohttp_lwt.Server) ->
sig
  type dispatch = Types.path -> Types.cowabloga Lwt.t
  val redirect: Types.domain -> dispatch
  val dispatch: Types.domain -> C.t -> FS.t -> TMPL.t -> dispatch
  val create: Types.domain -> C.t -> dispatch -> S.t
  type s = Conduit_mirage.server -> S.t -> unit Lwt.t
  val start: ?host:string -> C.t -> FS.t -> TMPL.t -> s -> unit Lwt.t
end

module Make_localhost
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: Cohttp_lwt.Server)
= struct

  type dispatch = Types.path -> Types.cowabloga Lwt.t
  type s = Conduit_mirage.server -> S.t -> unit Lwt.t

  let log c fmt = Printf.kprintf (C.log c) fmt
  let err fmt = Printf.kprintf (fun f -> raise (Failure f)) fmt
  let err_not_found name = err "%s not found" name

  let read_tmpl tmpl name =
    TMPL.size tmpl name >>= function
    | `Error (TMPL.Unknown_key _) -> err_not_found name
    | `Ok size ->
      TMPL.read tmpl name 0 (Int64.to_int size) >>= function
      | `Error (TMPL.Unknown_key _) -> err_not_found name
      | `Ok bufs -> Lwt.return (Cstruct.copyv bufs)

  let read_fs fs name =
    FS.size fs name >>= function
    | `Error (FS.Unknown_key _) -> err_not_found name
    | `Ok size ->
      FS.read fs name 0 (Int64.to_int size) >>= function
      | `Error (FS.Unknown_key _) -> err_not_found name
      | `Ok bufs -> Lwt.return (Cstruct.copyv bufs)

  let read_entry tmpl name = read_tmpl tmpl name >|= Cow.Markdown.of_string

  let respond_ok ?(headers=[]) body =
    body >>= fun body ->
    let status = `OK in
    let headers = Cohttp.Header.of_list headers in
    S.respond_string ~headers ~status ~body ()

  let not_found domain path =
    let uri = Site_config.uri domain path in
    let uri = Uri.to_string uri in
    Lwt.return (`Not_found uri)

  let redirect domain r =
    let uri = Site_config.uri domain r in
    let uri = Uri.to_string uri in
    Lwt.return (`Redirect uri)

  let cowabloga (x:Types.contents): Types.cowabloga = match x with
    | `Html _ | `Page _ as e -> e
    | `Not_found p -> `Not_found (Uri.to_string p)
    | `Redirect p  -> `Redirect (Uri.to_string p)

  let mk f path = f >|= fun f -> cowabloga (f path)

  let blog_feed domain tmpl =
    Data.Feed.blog domain (fun n -> read_entry tmpl ("/blog/"^n))

  let wiki_feed domain tmpl =
    Data.Feed.wiki domain (fun n -> read_entry tmpl ("/wiki/"^n))

  let updates_feed domain tmpl = Data.Feed.updates domain (read_entry tmpl)
  let links_feed domain tmpl = Data.Feed.links domain (read_entry tmpl)

  let updates_feeds domain tmpl = [
    `Blog (blog_feed domain tmpl, Data.Blog.entries);
    `Wiki (wiki_feed domain tmpl, Data.Wiki.entries);
  ]

  let blog_dispatch domain tmpl =
    let feed = blog_feed domain tmpl in
    let entries = Data.Blog.entries in
    let read = read_tmpl tmpl in
    Blog.dispatch ~domain ~feed ~entries ~read

  let wiki_dispatch domain tmpl =
    let read = read_tmpl tmpl in
    let feed = wiki_feed domain tmpl in
    let entries = Data.Wiki.entries in
    Wiki.dispatch ~domain ~read ~feed ~entries

  let releases_dispatch domain tmpl =
    let read = read_tmpl tmpl in
    Pages.Releases.dispatch ~domain ~read

  let links_dispatch domain tmpl =
    let read = read_tmpl tmpl in
    let feed = links_feed domain tmpl in
    let links = Data.Links.entries in
    Pages.Links.dispatch ~domain ~read ~feed ~links

  let updates_dispatch domain tmpl =
    let feed = updates_feed domain tmpl in
    let feeds = updates_feeds domain tmpl in
    let read = read_tmpl tmpl in
    Pages.Index.dispatch ~domain ~feed ~feeds ~read

  let stats () =
    let html = Cow.Html.to_string (Stats.page ()) in
    Lwt.return (`Html (Lwt.return html))

  let redirect_notes domain =
    redirect domain ["../wiki#Weeklycallsandreleasenotes"]

  let index domain tmpl =
    let read = read_tmpl tmpl in
    let feeds = updates_feeds domain tmpl in
    Pages.Index.t ~domain ~feeds ~read >|= cowabloga

  let about domain tmpl =
    let read = read_tmpl tmpl in
    Pages.About.t ~domain ~read >|= cowabloga

  let asset c domain fs path =
    let path_s = String.concat "/" path in
    let asset () = Lwt.return (`Asset (read_fs fs path_s)) in
    Lwt.catch asset (fun e ->
        log c "got an error while getting %s: %s" path_s (Printexc.to_string e);
        not_found domain path)

  (* dispatch non-file URLs *)
  let dispatch domain c fs tmpl = function
    | [] | [""] | ["index.html"] -> index domain tmpl
    | ["stats"; "gc"] -> stats ()
    | ["about"] | ["community"] -> about domain tmpl
    | "releases" :: tl -> mk (releases_dispatch domain tmpl) tl
    | "blog"     :: tl -> mk (blog_dispatch domain tmpl) tl
    | "links"    :: tl -> mk (links_dispatch domain tmpl) tl
    | "updates"  :: tl -> mk (updates_dispatch domain tmpl) tl
    | ("wiki" | "docs") :: "weekly" :: _ -> redirect_notes domain
    | "docs" :: tl | "wiki" :: tl -> mk (wiki_dispatch domain tmpl) tl
    | path -> asset c domain fs path

  let create domain c dispatch =
    let callback _conn_id request _body =
      let uri = Cohttp.Request.uri request in
      let io = {
        Cowabloga.Dispatch.log = (fun ~msg -> C.log c msg);
        ok = respond_ok;
        notfound = (fun ~uri -> S.respond_not_found ~uri ());
        redirect = (fun ~uri -> S.respond_redirect ~uri ());
      } in
      Cowabloga.Dispatch.f io dispatch uri
    in
    let conn_closed (_,conn_id) =
      let cid = Cohttp.Connection.to_string conn_id in
      log c "conn %s closed" cid
    in
    log c "Listening on %s" (Site_config.base_uri domain);
    Stats.start ~sleep:OS.Time.sleep;
    S.make ~callback ~conn_closed ()

  let start ?(host="localhost") c fs tmpl http =
    let domain = `Http, host in
    http (`TCP 80) (create domain c (dispatch domain c fs tmpl))

end

module type Config = sig
  val host: string
end

module Make (Config: Config)
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (S: Cohttp_lwt.Server)
= struct
  module M = Make_localhost(C)(FS)(TMPL)(S)
  include M
  let start ?(host=Config.host) c fs tmpl http = M.start ~host c fs tmpl http
end
