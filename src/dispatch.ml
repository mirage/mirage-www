(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2015 Citrix Inc
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

let err fmt = Printf.kprintf (fun f -> raise (Failure f)) fmt

let domain_of_string x =
  let uri = Uri.of_string x in
  let scheme = match Uri.scheme uri with
    | Some "http"  -> `Http
    | Some "https" -> `Https
    | _ ->
      err "%s: wrong scheme for redirect. Should be either http:// or https://." x
  in
  let host = match Uri.host uri with
    | Some x -> x
    | None   -> err "%s: missing hostname for redirect." x
  in
  scheme, host

module Make
    (S: Cohttp_lwt.Server)
    (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
    (Clock: V1.PCLOCK)
= struct

  type dispatch = Types.path -> Types.cowabloga Lwt.t
  type s = Conduit_mirage.server -> S.t -> unit Lwt.t

  let log c fmt = Printf.kprintf (C.log c) fmt
  let err_not_found name = err "%s not found" name

  let read_tmpl tmpl name =
    TMPL.size tmpl name >>= function
    | `Error _ -> err_not_found name
    | `Ok size ->
      TMPL.read tmpl name 0 (Int64.to_int size) >>= function
      | `Error _ -> err_not_found name
      | `Ok bufs -> Lwt.return (Cstruct.copyv bufs)

  let read_fs fs name =
    FS.size fs name >>= function
    | `Error _ -> err_not_found name
    | `Ok size ->
      FS.read fs name 0 (Int64.to_int size) >>= function
      | `Error _ -> err_not_found name
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
    incr Stats.total_errors;
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

  let blog domain tmpl =
    let feed = blog_feed domain tmpl in
    let entries = Data.Blog.entries in
    let read = read_tmpl tmpl in
    Blog.dispatch ~domain ~feed ~entries ~read

  let wiki domain tmpl =
    let read = read_tmpl tmpl in
    let feed = wiki_feed domain tmpl in
    let entries = Data.Wiki.entries in
    Wiki.dispatch ~domain ~read ~feed ~entries

  let releases domain tmpl =
    let read = read_tmpl tmpl in
    let feed = Data.empty_feed in
    Pages.Releases.dispatch ~feed ~domain ~read

  let links domain tmpl =
    let read = read_tmpl tmpl in
    let feed = links_feed domain tmpl in
    let links = Data.Links.entries in
    Pages.Links.dispatch ~domain ~read ~feed ~links

  let updates domain tmpl =
    let feed = updates_feed domain tmpl in
    let feeds = updates_feeds domain tmpl in
    let read = read_tmpl tmpl in
    Pages.Updates.dispatch ~domain ~feed ~feeds ~read

  let security domain tmpl =
    let feed = updates_feed domain tmpl in
    let read = read_tmpl tmpl in
    Pages.Security.dispatch ~domain ~read ~feed

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
    let feed = Data.empty_feed in
    Pages.About.dispatch ~feed ~domain ~read

  let asset c domain fs path =
    let path_s = String.concat "/" path in
    let asset () = Lwt.return (`Asset (read_fs fs path_s)) in
    Lwt.catch asset (fun e ->
        log c "got an error while getting %s: %s" path_s (Printexc.to_string e) >>= fun () ->
        not_found domain path)

  (* dispatch non-file URLs *)
  let dispatch domain c fs tmpl =
    let index = index domain tmpl in
    let about = about domain tmpl in
    let releases = releases domain tmpl in
    let blog = blog domain tmpl in
    let links = links domain tmpl in
    let updates = updates domain tmpl in
    let security = security domain tmpl in
    let wiki = wiki domain tmpl in
    function
    | ["index.html"]
    | [""] | []       -> index
    | ["stats"; "gc"] -> stats ()
    | ("about"|"community") :: tl-> mk about tl
    | "releases" :: tl -> mk releases tl
    | "blog"     :: tl -> mk blog tl
    | "links"    :: tl -> mk links tl
    | "updates"  :: tl -> mk updates tl
    | "security" :: tl -> mk security tl
    | ("wiki"|"docs") :: ["weekly"] -> redirect_notes domain
    | ("wiki"|"docs") :: tl -> mk wiki tl
    | path -> asset c domain fs path

  let moved_permanently ~uri () =
    let headers = Cohttp.Header.init_with "location" (Uri.to_string uri) in
    S.respond ~headers ~status:`Moved_permanently ~body:`Empty ()

  let not_found ~uri () =
    (* FIXME: better 404 page *)
    incr Stats.total_errors;
    S.respond_not_found ~uri ()

  let create domain c dispatch =
    let hdr = match fst domain with `Http -> "HTTP" | `Https -> "HTTPS" in
    let callback (_, conn_id) request _body =
      let uri = Cohttp.Request.uri request in
      let cid = Cohttp.Connection.to_string conn_id in
      let io = {
        Cowabloga.Dispatch.log = (fun ~msg -> Lwt.async (fun () -> log c "[%s %s] %s" hdr cid msg));
        ok = respond_ok;
        notfound = (fun ~uri -> not_found ~uri ());
        redirect = (fun ~uri -> moved_permanently ~uri ());
      } in
      incr Stats.total_requests;
      (* Cowabloga hides the URI which we need for query parameters *)
      if Uri.path uri = "/rrd_updates" then (
        Stats.get_rrd_updates uri >>= fun body ->
        S.respond_string ~status:`OK ~body ()
      ) else if Uri.path uri = "/rrd_timescales"
      then S.respond_string ~status:`OK ~body:(Stats.get_rrd_timescales uri) ()
      else Cowabloga.Dispatch.f io dispatch uri
    in
    let conn_closed (_,conn_id) =
      let cid = Cohttp.Connection.to_string conn_id in
      Lwt.async (fun () -> log c "[%s %s] OK, closing" hdr cid)
      
    in
    S.make ~callback ~conn_closed ()

  let start http c fs tmpl clock =
    let host = Key_gen.host () in
    let red = Key_gen.redirect () in
    let sleep sec = OS.Time.sleep_ns (Duration.of_sec sec) in
    Stats.start ~sleep ~time:(fun () -> Clock.now_d_ps clock);
    let domain = `Http, host in
    let dispatch = match red with
      | None        -> dispatch domain c fs tmpl
      | Some domain -> redirect (domain_of_string domain)
    in
    let callback = create domain c dispatch in
    log c "Listening on %s" (Site_config.base_uri domain) >>= fun () ->
    http (`TCP (Key_gen.http_port ())) callback

end
