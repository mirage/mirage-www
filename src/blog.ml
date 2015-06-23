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
open Cowabloga.Atom_feed

type t = Cowabloga.Blog.Entry.t

module C = Cowabloga

let not_found ~domain x =
  (* FIXME: pass "blog" in the domain variable? *)
  let uri = Site_config.uri domain ("blog" :: x) in
  `Not_found uri

let make ?title ~read ~domain content =
  (* TODO need a URL routing mechanism instead of assuming / *)
  let uri = Uri.of_string "/blog/atom.xml" in
  let headers =
    <:xml<<link rel="alternate" type="application/atom+xml" href=$uri:uri$ />&>>
  in
  let title = "Blog" ^ match title with None -> "" | Some x -> " :: " ^ x in
  Pages.Global.t ~title ~headers ~content ~domain ~read

let copyright f = match f.rights with None -> [] | Some r -> [`Data r]

let blog_index ~feed ~entries ~read ~domain =
  let recent_posts = C.Blog.recent_posts feed entries in
  let copyright = copyright feed in
  let sidebar =
    C.Foundation.Sidebar.t ~title:"Recent Posts" ~content:recent_posts
  in
  C.Blog.to_html ?sep:None ~feed ~entries >>= fun posts ->
  let { title; subtitle; _ } = feed in
  let content =
    C.Foundation.Blog.t ~title ~subtitle ~sidebar ~posts ~copyright ()
  in
  make ~domain ~read content

let blog_entry ~feed ~entries ~read ~domain entry =
  let recent_posts = C.Blog.recent_posts feed entries in
  let copyright = copyright feed in
  let sidebar =
    C.Foundation.Sidebar.t ~title:"Recent Posts" ~content:recent_posts
  in
  C.Blog.Entry.to_html ~feed ~entry >>= fun posts ->
  let { title; subtitle; _ } = feed in
  let content =
    C.Foundation.Blog.t ~title ~subtitle ~sidebar ~posts ~copyright ()
  in
  let title = entry.C.Blog.Entry.subject in
  make ~domain ~read ~title content >>= fun content ->
  Lwt.return (entry.C.Blog.Entry.permalink, content)

let blog_entries ~feed ~entries ~read ~domain =
  Lwt_list.map_s (blog_entry ~domain ~read ~feed ~entries) entries

let atom_feed ~feed ~entries =
  let headers  = C.Headers.atom in
  let feed =
    C.Blog.to_atom ~feed ~entries
    >|= Cow.Atom.xml_of_feed
    >|= Cow.Xml.to_string
  in
  Lwt.return (`Page (headers, feed))

(* Construct an HTTP dispatch function for the blog *)
let dispatch ~feed ~entries ~read ~domain =
  atom_feed ~feed ~entries                  >>= fun atom_feed ->
  blog_index ~domain ~feed ~entries ~read   >>= fun blog_index ->
  blog_entries ~domain ~read ~feed ~entries >>= fun blog_entries ->
  let blog_entry x =
    try List.assoc x blog_entries
    with Not_found -> not_found ~domain [x]
  in
  let f = function
    | [] | [""]    -> blog_index
    | ["atom.xml"] -> atom_feed
    | [x]          -> blog_entry x
    | x            -> not_found ~domain x
  in
  Lwt.return f
