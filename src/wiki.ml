open Cow
open Printf
open Lwt
open Data.People
open Data.Wiki
open Cowabloga.Wiki

(* Construct an HTTP dispatch function for the blog *)
let dispatch ({Cowabloga.Atom_feed.title; subtitle; rights} as feed) entries =

  (* Make a full Html.t including Atom link and headers from an wiki page *)
  let make ?title ?disqus content sidebar =
    (* TODO get atom url from the feed *)
    let url = sprintf "/wiki/atom.xml" in
    let headers = <:xml<<link rel="alternate" type="application/atom+xml" href=$str:url$ />&>> in
    let title = "Docs " ^
      match title with
      | None -> ""
      | Some x -> " :: " ^ x in
    lwt content = html_of_page ?disqus ~content ~sidebar in
    return (Pages.Global.page ~title ~headers ~content)
  in

  (* TODO use a mime type db (from cohttp?) *)
  let content_type_xhtml = ["content-type", "text/html"] in
  let content_type_atom  = ["content-type", "application/atom+xml; charset=UTF-8"] in

  (* Main wiki page Html.t fragment with the index page *)
  let main_page =
    lwt idx = html_of_index feed in
    let sidebar = html_of_recent_updates feed Data.Wiki.entries in
    make ~title:"index"  (return idx) sidebar
  in

  lwt doc_entries =
    let h = Hashtbl.create 1 in
    lwt () = Lwt_list.iter_s (fun entry ->
      let title = entry.subject in
      let post = html_of_entry feed entry in
      let body = make ~title post [] in
      Hashtbl.add h entry.permalink body;
      return ()
    ) entries in
    return h
  in

  let atom_feed =
    to_atom ~feed ~entries
    >|= Cow.Atom.xml_of_feed ~self:"/wiki/atom.xml" (* TODO what is self? *)
    >|= Cow.Xml.to_string
  in

  let not_found x =
    let left = sprintf "Not found: %s (known links: wiki/%s)"
      (String.concat " ... " x)
      (String.concat " "
         (Hashtbl.fold (fun k v a -> k :: a) doc_entries [])) in
     make ~title:"Not Found" (return <:xml<$str:left$>>) []
  in

  return (
    function
    | [] | [""] -> content_type_xhtml, main_page
    | ["atom.xml"] -> content_type_atom, atom_feed
    | [x] when Hashtbl.mem doc_entries x -> content_type_xhtml, (Hashtbl.find doc_entries x)
    | x -> content_type_xhtml, not_found x
  )
