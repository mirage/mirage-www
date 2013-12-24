open Cow
open Printf
open Lwt

open Data.People
open Data.Wiki
open Cowabloga.Wiki

let cmp_ent a b = Atom.compare (atom_date a.updated) (atom_date b.updated)

let entries = List.rev (List.sort cmp_ent entries)
let _ = List.iter (fun x -> Printf.printf "ENT: %s\n%!" x.subject) entries

let permalink_exists x = List.exists (fun e -> e.permalink = x) entries

let atom_entry_of_ent filefn e =
  let links = [
    Atom.mk_link ~rel:`alternate ~typ:"text/html"
      (Local_uri.mk_uri (permalink e))
  ] in
  lwt content = body_of_entry filefn e in
  let meta = {
    Atom.id      = Local_uri.mk_uri_string (permalink e);
    title        = e.subject;
    subtitle     = None;
    author       = Some e.author;
    updated      = atom_date e.updated;
    links;
    rights =       Data.rights;
  } in
  return {
    Atom.entry = meta;
    summary    = None;
    base       = None;
    content
  }

let atom_feed filefn es =
  let es = List.rev (List.sort cmp_ent es) in
  let updated = atom_date (List.hd es).updated in
  let id = Local_uri.mk_uri_string "/wiki/" in
  let title = "openmirage wiki" in
  let subtitle = Some "a cloud operating system" in
  let links = [
    Atom.mk_link (Local_uri.mk_uri "/wiki/atom.xml");
    Atom.mk_link ~rel:`alternate ~typ:"text/html" (Local_uri.mk_uri "/wiki/")
  ] in
  let feed = { Atom.id; title; subtitle; author=None; rights=Data.rights; updated; links} in
  lwt entries = Lwt_list.map_s (atom_entry_of_ent filefn) es in
  return { Atom.feed=feed; entries }

open Cowabloga.Wiki


let read_file read_fn f = Pages.read_file read_fn ("/wiki/" ^ f)

(* Make a full Html.t including RSS link and headers from an wiki page *)
let make ?title ?disqus content sidebar read_fn =
  let url = sprintf "/wiki/atom.xml" in
  let headers = <:xml<
                  <link rel="alternate" type="application/atom+xml" href=$str:url$ />
                >> in
  let title = "Docs " ^ match title with
    |None -> "" |Some x -> " :: " ^ x in
  lwt content = html_of_page ?disqus ~content ~sidebar in
  return (Pages.Global.page ~title ~headers ~content)

(* Main wiki page Html.t fragment with the index page *)
let main_page read_fn =
  lwt idx = html_of_index (read_file read_fn) in
  let sidebar = html_of_recent_updates Data.Wiki.entries in
  make ~title:"index"  (return idx) sidebar read_fn

let init read_fn =
  let ent_bodies = Hashtbl.create 1 in
  List.iter (fun entry ->
      let title = entry.subject in
      let left = html_of_entry (read_file read_fn) entry in
      let body = make ~title ~disqus:entry.permalink left [] read_fn in
      Hashtbl.add ent_bodies entry.permalink body
    ) entries;
  ent_bodies

let atom_feed read_fn =
  lwt f = atom_feed (read_file read_fn) entries in
  return (Xml.to_string (Atom.xml_of_feed ~self:("/wiki/atom.xml") f))

let not_found x ent_bodies read_fn =
  let left =
    sprintf "Not found: %s (known links: wiki/%s)"
      (String.concat " ... " x)
      (String.concat " "
         (Hashtbl.fold (fun k v a -> k :: a)
            ent_bodies [])) in
  make ~title:"Not Found" (return <:xml<$str:left$>>) [] read_fn

let content_type_xhtml = ["content-type", "text/html"]
let t ents read_fn = function
  | []                          -> content_type_xhtml, (main_page read_fn)
  | ["atom.xml"]                -> ["content-type","application/atom+xml; charset=UTF-8"], (atom_feed read_fn)
  | [x] when permalink_exists x -> content_type_xhtml, (Hashtbl.find ents x)
  | x                           -> content_type_xhtml, (not_found x ents read_fn)

