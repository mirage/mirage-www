open Lwt
open Printf

module Main
  (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (TMPL: V1_LWT.KV_RO)
  (S: Cohttp_lwt.Server)
  = struct

    let start c fs tmpl http =

      let read_tmpl name =
        TMPL.size tmpl name
        >>= function
        | `Error (TMPL.Unknown_key _) -> fail (Failure ("read " ^ name))
        | `Ok size ->
          TMPL.read tmpl name 0 (Int64.to_int size)
          >>= function
          | `Error (TMPL.Unknown_key _) -> fail (Failure ("read " ^ name))
          | `Ok bufs -> return (Cstruct.copyv bufs)
      in

      let read_fs name =
        FS.size fs name
        >>= function
        | `Error (FS.Unknown_key _) -> fail (Failure ("read " ^ name))
        | `Ok size ->
          FS.read fs name 0 (Int64.to_int size)
          >>= function
          | `Error (FS.Unknown_key _) -> fail (Failure ("read " ^ name))
          | `Ok bufs -> return (Cstruct.copyv bufs)
      in

      let respond_ok ?(headers=[]) body =
        body >>= fun body ->
        let status = `OK in
        let headers = Cohttp.Header.of_list headers in
        S.respond_string ~headers ~status ~body ()
      in
      let read_entry =
        (fun name -> read_tmpl name >|= Cow.Markdown.of_string)
      in
      let blog_feed = Site_config.blog (fun n -> read_entry ("/blog/"^n)) in
      let wiki_feed = Site_config.wiki (fun n -> read_entry ("/wiki/"^n)) in
      let updates_feed = Site_config.updates read_entry in
      let links_feed = Site_config.links read_entry in

      let updates_feeds = [
        `Blog (blog_feed, Data.Blog.entries);
        `Wiki (wiki_feed, Data.Wiki.entries);
      ] in

      lwt blog_dispatch = Blog.dispatch blog_feed Data.Blog.entries in
      lwt wiki_dispatch = Wiki.dispatch wiki_feed Data.Wiki.entries in
      lwt links_dispatch =
        Pages.Links.dispatch links_feed Data.Links.entries
      in
      lwt updates_dispatch =
        Pages.Index.dispatch ~feed:updates_feed ~feeds:updates_feeds
      in

      (* dispatch non-file URLs *)
      let dispatcher = function
        | [] | [""] | ["index.html"] ->
          return (`Html (Pages.Index.t ~feeds:updates_feeds read_tmpl))

        | ["about"]
        | ["community"] ->
          return (`Html (Pages.About.t read_tmpl))

        | "blog"    :: tl -> return (`Page (blog_dispatch tl))
        | "links"   :: tl -> return (links_dispatch tl)
        | "updates" :: tl -> return (`Page (updates_dispatch tl))

        | "docs" :: tl
        | "wiki" :: tl -> return (`Page (wiki_dispatch tl))

        | segments ->
          let path = String.concat "/" segments in
          try_lwt
            lwt body = read_fs path in
            return (`Asset (return body))
          with exn ->
            return (`Not_found path)
      in

      (* HTTP callback *)
      let callback conn_id ?body request =
        let uri = S.Request.uri request in
        let io = { Cowabloga.Dispatch.
                   log = (fun ~msg -> C.log c msg);
                   ok = respond_ok;
                   notfound = (fun ~uri -> S.respond_not_found ~uri ());
                   redirect = (fun ~uri -> S.respond_redirect ~uri ());
                 }
        in
        Cowabloga.Dispatch.f io dispatcher uri
      in
      let conn_closed conn_id () =
        let cid = Cohttp.Connection.to_string conn_id in
        C.log c (Printf.sprintf "conn %s closed" cid)
      in
      http { S.callback = callback; conn_closed }

  end
