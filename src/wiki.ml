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

type t = Cowabloga.Wiki.entry

module C = Cowabloga

(* Make a full Html.t including Atom link and headers from an wiki
   page *)
let make ?title ?disqus ~read ~domain ~sidebar content =
  (* TODO get atom url from the feed *)
  let url = sprintf "/wiki/atom.xml" in
  let headers =
    <:xml<<link rel="alternate" type="application/atom+xml" href=$str:url$ />&>>
  in
  let title = "Docs " ^ match title with None -> "" | Some x -> " :: " ^ x in
  C.Wiki.html_of_page ?disqus ~content ~sidebar >>= fun content ->
  Pages.Global.t ~domain ~title ~headers ~content ~read

(* Main wiki page Html.t fragment with the index page *)
let wiki_index ~feed ~read ~domain =
  C.Wiki.html_of_index feed >>= fun idx ->
  let sidebar = C.Wiki.html_of_recent_updates feed Data.Wiki.entries in
  make ~read ~domain ~title:"index" ~sidebar (Lwt.return idx)

let wiki_entries ~feed ~entries ~read ~domain =
  let h = Hashtbl.create 1 in
  Lwt_list.iter_s (fun entry ->
      let title = entry.C.Wiki.subject in
      let post = C.Wiki.html_of_entry feed entry in
      make ~domain ~read ~title ~sidebar:[] post >>= fun body ->
      Hashtbl.add h entry.C.Wiki.permalink body;
      Lwt.return_unit
    ) entries
  >>= fun () ->
  Lwt.return h

let atom_feed ~feed ~entries =
  let headers  = Cowabloga.Headers.atom in
  let feed =
    C.Wiki.to_atom ~feed ~entries
    >|= Cow.Atom.xml_of_feed ~self:"/wiki/atom.xml" (* TODO what is self? *)
    >|= Cow.Xml.to_string
  in
  Lwt.return (`Page (headers, feed))

let not_found ~domain x =
  (* FIXME: pass "wiki" in the domain variable? *)
  let uri = Site_config.uri domain ("wiki" :: x) in
  `Not_found uri

(* Construct an HTTP dispatch function for the blog *)
let dispatch ~feed ~entries ~read ~domain =
  atom_feed ~feed ~entries                  >>= fun atom_feed ->
  wiki_index ~domain ~feed ~read            >>= fun wiki_index ->
  wiki_entries ~domain ~read ~feed ~entries >>= fun wiki_entries ->
  let wiki_entry x =
    try Hashtbl.find wiki_entries x
    with Not_found -> not_found ~domain [x]
  in
  let f = function
    | ["index.html"]
    | [""] | []    -> wiki_index
    | ["atom.xml"] -> atom_feed
    | [x]          -> wiki_entry x
    | x            -> not_found ~domain x
  in
  Lwt.return f
