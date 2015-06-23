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

open Printf
open Lwt.Infix
open Cow

type t = read:string Types.read -> domain:Types.domain -> Types.contents Lwt.t

let html str = Lwt.return (`Html (Lwt.return str))
let page h c = Lwt.return (`Page (h, Lwt.return c))
let empty = `Html (Lwt.return "")

let get_extension filename =
  try
    let n = String.rindex filename '.' in
    Some (String.sub filename (n+1) (String.length filename - n - 1))
  with Not_found ->
    None

let read_file tmpl_read f =
  let read fn =
    Lwt.catch
      (fun () -> tmpl_read f >|= fn)
      (function exn ->
        printf "Pages.read_file: exception %s\n%!" (Printexc.to_string exn);
        exit 1)
  in
  match get_extension f with
  | Some "md"   -> read Markdown.of_string
  | Some "html" -> read (fun s -> Html.of_string s)
  | _           -> Lwt.return []

module Global = struct

  let nav_links = <:xml<
    <ul class="left">
      <li><a href="/blog/">Blog</a></li>
      <li><a href="/docs/">Docs</a></li>
      <li><a href="http://mirage.github.io/">API</a></li>
      <li><a href="/releases/">Changes</a></li>
      <li class="has-dropdown">
        <a href="/community/">Community</a>
        <ul class="dropdown">
          <li><a href="/community/">Background</a></li>
          <li><a href="/community/">Contact</a></li>
          <li><a href="/community/#team">Team</a></li>
          <li><a href="/community/#blogroll">Blogroll</a></li>
          <li><a href="/links/">Links</a></li>
        </ul>
      </li>
     </ul> >>

  let top_nav =
    Cowabloga.Foundation.top_nav
      ~title:<:html<<img src="/graphics/mirage-logo-small.png" />&>>
      ~title_uri:(Uri.of_string "/")
      ~nav_links

  let t ~title ~headers ~content ~read:_ ~domain =
    let font = <:html<
      <link rel="stylesheet" href="/css/font-awesome.css"> </link>
      <link href="http://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600,700"
            rel="stylesheet" type="text/css"> </link>
    >> in
    let headers = font @ headers in
    let content = top_nav @ content in
    let google_analytics = Data.google_analytics domain in
    let body =
      Cowabloga.Foundation.body ~highlight:"/css/magula.css"
        ~google_analytics ~title ~headers ~content ~trailers:[] ()
    in
    html (Cowabloga.Foundation.page ~body)

end

module Index = struct

  let t ~feeds ~read ~domain =
    read_file read "/intro-1.md"  >>= fun l1 ->
    read_file read "/intro-3.md"  >>= fun l2 ->
    read_file read "/intro-f.html">>= fun footer ->
    Cowabloga.Feed.to_html ~limit:12 feeds >>= fun recent ->
    let content = <:html<
    <div class="row">
      <div class="small-12 columns">
        <h3>A programming framework for building type-safe, modular systems</h3>
      </div>
    </div>
    <div class="row">
      <div class="small-12 medium-6 columns">$l1$ $l2$</div>
      <div class="small-12 medium-6 large-6 columns front_updates">
        <h4><a href="/updates/atom.xml"><i class="fa fa-rss"> </i></a>
         Recent Updates <small><a href="/updates/">(all)</a></small></h4>
        $recent$
      </div>
    </div>
    <div class="row">
      <div class="small-12 columns">$footer$</div>
    </div>
    >> in
    Global.t ~title:"MirageOS" ~headers:[] ~content ~domain ~read

  let content_type_atom  = Cowabloga.Headers.atom

  (* TODO have a way of rewriting all the pages with an associated Atom feed *)
  let make ~read ~domain content =
    (* TODO need a URL routing mechanism instead of assuming / *)
    let uri = Uri.of_string "/updates/atom.xml" in
    let headers =
      <:xml<<link rel="alternate" type="application/atom+xml" href=$uri:uri$ /> >> in
    let title = "Updates" in
    Global.t ~title ~headers ~content ~read ~domain

  let dispatch ~feed ~feeds ~read ~domain =
    Cowabloga.Feed.to_atom ~meta:feed ~feeds
    >|= Cow.Atom.xml_of_feed
    >|= Cow.Xml.to_string
    >>= fun atom ->
    Cowabloga.Feed.to_html feeds >>= fun recent ->
    make ~domain ~read <:html<
       <div class="row">
         <div class="small-12 medium-9 large-6 front_updates">
         <h2>Site Updates <small>across the blogs and documentation</small></h2>
          $recent$
         </div>
       </div> >>
    >>= fun content ->
    page content_type_atom atom >>= fun atom ->
    let f = function
      | [""] | []    -> content
      | ["atom.xml"] -> atom
      | _            -> empty
    in
    Lwt.return f

end

module Links = struct

  let dispatch ~feed ~links ~read ~domain =
    let open Cowabloga.Links in
    Cowabloga.Feed.to_html [ `Links (feed, links) ] >>= fun body ->
    let content = <:html<
      <div class="row">
        <div class="small-12 medium-9 large-6 columns">
          <h2>Around the Web</h2>
          <p>
            This is a small link blog we maintain as we hear of stories or
            interesting blog entries that may be useful for MirageOS users. If
            you'd like to add one, please do <a href="/community/">get in
            touch</a>.
          </p>
          <br />
          $body$
        </div>
      </div>
    >> in
    let title = "Around the Web" in
    let headers = [] in
    Global.t ~domain ~title ~headers ~read ~content >>= fun body ->
    let not_found path =
      (* FIXME: put [links] in the domain variable? *)
      let uri = Site_config.uri domain ("links" :: path) in
      `Not_found uri
    in
    let h = Hashtbl.create 1 in
    List.iter
      (fun l -> Hashtbl.add h (sprintf "%s/%s" l.stream.name l.id) l.uri)
      links;
    let f = function
      | []        -> body
      | [id;link] ->
        let id = sprintf "%s/%s" id link in
        if Hashtbl.mem h id then `Redirect (Hashtbl.find h id)
        else not_found [id;link]
      | x -> not_found x
    in
    Lwt.return f

end

module About = struct

  let t ~read ~domain =
    read_file read "/about-intro.md"     >>= fun i ->
    read_file read "/about.md"           >>= fun l ->
    read_file read "/about-community.md" >>= fun r ->
    read_file read "/about-b.md"         >>= fun b ->
    read_file read "/about-funding.md"   >>= fun f ->
    read_file read "/about-blogroll.md"  >>= fun br ->
    let content = <:html<
    <a name="about"> </a>
    <div class="row">
      <div class="small-12 medium-6 columns">$i$</div>
      <div class="small-12 medium-6 columns">$f$</div>
      <hr/>
    </div>
    <a name="participate"> </a>
    <div class="row">
      <div class="small-12 columns">$b$</div>
      <hr />
    </div>
    <a name="team"> </a>
    <div class="row">
      <div class="small-12 medium-6 columns">$l$</div>
      <div class="small-12 medium-6 columns">$r$</div>
      <hr />
    </div>
    <a name="blogroll"> </a>
    <div class="row">
      <div class="small-12 medium-6 columns">$br$</div>
    </div> >> in
    Global.t ~title:"Community" ~headers:[] ~content ~read ~domain

end

module Releases = struct

  let changelog ~read ~domain =
    read_file read "/changelog.md" >>= fun c ->
    let content = <:html<
      <div class="row">
        <div class="small-12 medium-12 large-9 columns">
          <h2>Changelogs of ecosystem libraries</h2>
          <p>MirageOS consists of numerous libraries that are independently
          developed and released.  This page lists the chronological stream
          of releases, along with the summary of changes that went into each
          library. The MirageOS
          <a href="https://github.com/mirage">organization</a> holds most of
          the major libraries if you just want to browse.</p>
          <p>We also provide a short list of
          <a href='/wiki/breaking-changes'>backwards incompatible changes</a>.
          </p>
          $c$
        </div>
      </div>
    >> in
    Global.t ~domain ~title:"Changelog" ~headers:[] ~content ~read

  let dispatch ~read ~domain =
    changelog ~read ~domain >>= fun changelog ->
    let f = function
      | [""] | [] -> changelog
      | _         -> empty
    in
    Lwt.return f
end

(*

('a -> 'b Lwt.t) -> 'a -> ('a -> 'b) Lwt.t

*)
