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
open Cow.Html
open Www_types

type t = read:string read -> domain:domain -> contents Lwt.t
type dispatch =
  feed:Cowabloga.Atom_feed.t -> read:string read -> Www_types.dispatch

let not_found ~domain section path =
  (* FIXME: put [section] in the [domain] variable? *)
  let uri = Site_config.uri domain (section :: path) in
  `Not_found uri

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
  | Some "md"   -> read Cow.Markdown.of_string
  | Some "html" -> read (fun s -> Cow.Html.of_string s)
  | _           -> Lwt.return []

module Global = struct

  let uri = Uri.of_string

  let nav_links =
    tag "ul" ~cls:"left" (list [
      tag "li" (a ~href:(uri "/blog/") (string "Blog"));
      tag "li" (a ~href:(uri "/docs/") (string "Docs"));
      tag "li" (a ~href:(uri "http://docs.mirage.io") (string "API"));
      tag "li" (a ~href:(uri "http://canopy.mirage.io") (string "Canopy"));
      tag "li"~cls:"has-dropdown" (list [
          a ~href:(uri "/community/") (string "Community");
          ul ~cls:"dropdown" [
            a ~href:(uri "/community/") (string "Background");
            a ~href:(uri "/community/") (string "Contact");
            a ~href:(uri "/community/#team") (string "Team");
            a ~href:(uri "/community/#blogroll") (string "Blogroll");
            a ~href:(uri "/links/") (string "Links");
          ]
        ])])

  let top_nav =
    Cowabloga.Foundation.top_nav
      ~title:(img (uri "/graphics/mirage-logo-small.png"))
      ~title_uri:(Uri.of_string "/")
      ~nav_links

  let t ~title ~headers ~content ~read:_ ~domain =
    let scheme = match fst domain with `Http -> "http" | `Https -> "https" in
    let fonts =
      scheme ^ "://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600,700"
    in
    let font =
      link ~rel:"stylesheet" (Uri.of_string "/css/font-awesome.css")
      ++
      link ~rel:"stylesheet" ~ty:"text/css" (Uri.of_string fonts)
    in
    let headers = font @ headers in
    let content = top_nav @ content in
    let google_analytics = Data.google_analytics domain in
    let body =
      Cowabloga.Foundation.body ~highlight:"/css/magula.css"
        ~google_analytics ~title ~headers ~content ~trailers:[] ()
    in
    let body = Cowabloga.Foundation.page ~body in
    Lwt.return (`Html (Lwt.return body))

end

module Index = struct

  let uri = Uri.of_string

  let t ~feeds ~read ~domain =
    read_file read "/intro-1.md"  >>= fun l1 ->
    read_file read "/intro-3.md"  >>= fun l2 ->
    read_file read "/intro-f.html">>= fun footer ->
    Cowabloga.Feed.to_html ~limit:12 feeds >>= fun recent ->
    let content = list [
        div ~cls:"row" (
          div ~cls:"small-12 columns" (
            h3 ( string "A programming framework for building type-safe, \
                         modular systems")));
        div ~cls:"row" (list [
            div ~cls:"small-12 medium-6 columns" (l1 ++ l2);
            div ~cls:"small-12 medium-6 large-6 columns front_updates"
              (h4 (list [
                   a ~href:(uri "/updates/atom.xml") (i ~cls:"fa fa-rss" empty);
                   string " Recent Updates ";
                   small (a ~href:(uri "/updates/") (string "all"))
                 ])
               ++ recent
              )]);
        div ~cls:"row" (div ~cls:"small-12 columns" footer)
      ]
    in
    Global.t ~title:"MirageOS" ~headers:[] ~content ~domain ~read

end

module Updates = struct

  (* TODO have a way of rewriting all the pages with an associated Atom feed *)
  let make ~read ~domain content =
    (* TODO need a URL routing mechanism instead of assuming / *)
    let uri = Uri.of_string "/updates/atom.xml" in
    let headers = link ~rel:"alternate" ~ty:"application/atom+xml" uri in
    let title = "Updates" in
    Global.t ~title ~headers ~content ~read ~domain

  let atom_feed ~feed ~feeds =
    let content_type_atom  = Cowabloga.Headers.atom in
    let feed =
      Cowabloga.Feed.to_atom ~meta:feed ~feeds
      >|= Cow.Atom.xml_of_feed ?self:None (* XXX: add a self link? *)
      >|= Cow.Xml.to_string ~decl:false
    in
    Lwt.return (`Page (content_type_atom, feed))

  let dispatch ~feeds ~feed ~read ~domain =
    Cowabloga.Feed.to_html feeds >>= fun recent    ->
    atom_feed ~feed ~feeds       >>= fun atom_feed ->
    make ~domain ~read
      (div ~cls:"row" (
          div ~cls:"small-12 medium-9 large-6 front_updates" (
            h2 (string "Site Updates "
                ++ small (string "across the blogs and documentation"))
            ++ recent)))
    >>= fun content ->
    let f = function
      | ["index.html"]
      | [""] | []    -> content
      | ["atom.xml"] -> atom_feed
      | x            -> not_found ~domain "updates" x
    in
    Lwt.return f

end

module Links = struct

  let uri = Uri.of_string

  let dispatch ~links ~feed ~read ~domain =
    let open Cowabloga.Links in
    Cowabloga.Feed.to_html [ `Links (feed, links) ] >>= fun body ->
    let content =
      div ~cls:"row" (
        div ~cls:"small-12 medium-9 large-6 columns" (list [
            h2 (string "Around the Web");
            p (string
                 "This is a small link blog we maintain as we hear of stories \n\
                  or interesting blog entries that may be useful for MirageOS \n\
                  users. If you'd like to add one, please do "
               ++ a ~href:(uri "/community/") (string "get in touch."));
            br;
            body
          ])
      ) in
    let title = "Around the Web" in
    let headers = [] in
    Global.t ~domain ~title ~headers ~read ~content >>= fun body ->
    let h = Hashtbl.create 1 in
    List.iter
      (fun l -> Hashtbl.add h (sprintf "%s/%s" l.stream.name l.id) l.uri)
      links;
    let f = function
      | ["index.html"]
      | [""] | [] -> body
      | [id;link] ->
        let id = sprintf "%s/%s" id link in
        if Hashtbl.mem h id then `Redirect (Hashtbl.find h id)
        else not_found ~domain "links" [id;link]
      | x -> not_found ~domain "links" x
    in
    Lwt.return f

end

module About = struct

  let t ~read ~domain =
    read_file read "/about-intro.md"     >>= fun intro ->
    read_file read "/about.md"           >>= fun main ->
    read_file read "/about-community.md" >>= fun community ->
    read_file read "/about-b.md"         >>= fun bb ->
    read_file read "/about-funding.md"   >>= fun funding ->
    read_file read "/about-blogroll.md"  >>= fun blogroll ->
    let content = list [
        anchor "about";
        div ~cls:"row" (list [
            div ~cls:"small-12 medium-6 columns" intro;
            div ~cls:"small-12 medium-6 columns" funding;
            hr;
          ]);
        anchor "participate";
        div ~cls:"row" (div ~cls:"small-12 columns" bb ++ hr);
        anchor "team";
        div ~cls:"row"(list [
            div ~cls:"small-12 medium-6 columns" main;
            div ~cls:"small-12 medium-6 columns" community;
            hr
          ]);
        anchor "blogroll";
        div ~cls:"row" (div ~cls:"small-12 medium-6 columns" blogroll)
      ]
    in
    Global.t ~title:"Community" ~headers:[] ~content ~read ~domain

  let dispatch ~feed:_ ~read ~domain =
    t ~read ~domain >>= fun about ->
    let f = function
      | ["index.html"]
      | [""] | [] -> about
      | x         -> not_found ~domain "about" (* FIXME: can also be docs *) x
    in
    Lwt.return f

end

module Releases = struct

  let uri = Uri.of_string

  let t ~read ~domain =
    read_file read "/changelog.md" >>= fun c ->
    let content =
      div ~cls:"row" (
        div ~cls:"small-12 medium-12 large-9 columns" (list [
            h2 (string "Changelogs of ecosystem libraries");
            p (string
                 "MirageOS consists of numerous libraries that are \n\
                  independently developed and released. This page lists \n\
                  the chronological stream of releases, along with the \n\
                  summary of changes that went into each library. \n\
                  The MirageOS"
               ++ a ~href:(uri "https://github.com/mirage")
                 (string "organization")
               ++ string
                 "holds most of the major libraries if you just want to \n\
                  browse.");
            p (string "We also provide a short list of "
               ++ a ~href:(uri "/wiki/breaking-changes")
                 (string "backwards incompatible changes"));
            c
          ]))
    in
    Global.t ~domain ~title:"Changelog" ~headers:[] ~content ~read

  let dispatch ~feed:_ ~read ~domain =
    t ~read ~domain >>= fun releases ->
    let f = function
      | ["index.html"]
      | [""] | [] -> releases
      | x         -> not_found ~domain "releases" x
    in
    Lwt.return f

end

module Security = struct
  let dispatch ~feed:_ ~read ~domain =
    read_file read "/security.md" >>= fun c->
    let content =
      div ~cls:"row" (
        div ~cls:"small-12 medium-12 large-9 columns"
          (h2 (string "Security") ++ c)
      )
    in
    Global.t ~title:"Security" ~headers:[] ~content ~domain ~read >>= fun security ->
    let f = function
    | ["index.html"]
    | [""] | [] -> security
    | x         -> not_found ~domain "security" x in
    Lwt.return f
end
