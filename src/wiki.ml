open Printf
open Lwt.Infix
open Cowabloga.Wiki

(* Make a full Html.t including Atom link and headers from an wiki
   page *)
let make ~domain ?title ?disqus content sidebar =
  (* TODO get atom url from the feed *)
  let url = sprintf "/wiki/atom.xml" in
  let headers =
    <:xml<<link rel="alternate" type="application/atom+xml" href=$str:url$ />&>>
  in
  let title = "Docs " ^ match title with None -> "" | Some x -> " :: " ^ x in
  html_of_page ?disqus ~content ~sidebar >>= fun content ->
  Lwt.return (Pages.Global.page ~domain ~title ~headers ~content)

(* Main wiki page Html.t fragment with the index page *)
let main_page ~domain feed =
  html_of_index feed >>= fun idx ->
  let sidebar = html_of_recent_updates feed Data.Wiki.entries in
  make ~domain ~title:"index" (Lwt.return idx) sidebar

let doc_entries ~domain feed entries =
  let h = Hashtbl.create 1 in
  List.iter (fun entry ->
      let title = entry.subject in
      let post = html_of_entry feed entry in
      let body = make ~domain ~title post [] in
      Hashtbl.add h entry.permalink body;
    ) entries;
  h

let atom_feed feed entries =
  to_atom ~feed ~entries
  >|= Cow.Atom.xml_of_feed ~self:"/wiki/atom.xml" (* TODO what is self? *)
  >|= Cow.Xml.to_string

let not_found ~domain x doc_entries =
  let all = Hashtbl.fold (fun k _ a -> k :: a) doc_entries [] in
  let left = sprintf "Not found: %s (known links: wiki/%s)"
      (String.concat " ... " x)
      (String.concat " " all)
  in
  make ~domain ~title:"Not Found" (Lwt.return <:xml<$str:left$>>) []

(* Construct an HTTP dispatch function for the blog *)
let dispatch ~domain feed entries =
  (* TODO use a mime type db (from cohttp?) *)
  let content_type_xhtml = Cowabloga.Headers.html in
  let content_type_atom  = Cowabloga.Headers.atom in
  let main_page = main_page ~domain feed in
  let doc_entries = doc_entries ~domain feed entries in
  let atom_feed = atom_feed feed entries in
  let doc_entry x =
    try Hashtbl.find doc_entries x
    with Not_found -> not_found ~domain [x] doc_entries
  in
  let f = function
    | [] | [""]    -> content_type_xhtml, main_page
    | ["atom.xml"] -> content_type_atom , atom_feed
    | [x]          -> content_type_xhtml, doc_entry x
    | x            -> content_type_xhtml, not_found ~domain x doc_entries
  in
  Lwt.return f
