open Lwt.Infix
module C = Cowabloga
open C.Atom_feed
open C.Blog

(* TODO this should be a 404! Bad API *)
let not_found x blog_entries =
  let all = List.fold_left (fun a (v,_) -> v::a) [] blog_entries in
  let msg =
    Printf.sprintf "Not found: %s (known links: %s)"
      (String.concat " ... " x)
      (String.concat " " all)
  in
  Lwt.return msg

let make ?title ~domain content =
  (* TODO need a URL routing mechanism instead of assuming / *)
  let uri = Uri.of_string "/blog/atom.xml" in
  let headers =
    <:xml<<link rel="alternate" type="application/atom+xml" href=$uri:uri$ />&>>
  in
  let title = "Blog" ^ match title with None -> "" | Some x -> " :: " ^ x in
  Pages.Global.page ~domain ~title ~headers ~content

let copyright = function None -> [] | Some r -> [`Data r]

let blog_index ~domain ({title; subtitle; rights; _} as feed) entries =
  let recent_posts = recent_posts feed entries in
  let copyright = copyright rights in
  let sidebar =
    C.Foundation.Sidebar.t ~title:"Recent Posts" ~content:recent_posts
  in
  C.Blog.to_html ?sep:None ~feed ~entries >>= fun posts ->
  let content =
    C.Foundation.Blog.t ~title ~subtitle ~sidebar ~posts ~copyright ()
  in
  Lwt.return (make ~domain content)

let blog_entry ~domain ({title; subtitle; rights; _} as feed) entries entry =
  let recent_posts = recent_posts feed entries in
  let copyright = copyright rights in
  let sidebar =
    C.Foundation.Sidebar.t ~title:"Recent Posts" ~content:recent_posts
  in
  C.Blog.Entry.to_html ~feed ~entry >>= fun posts ->
  let content =
    C.Foundation.Blog.t ~title ~subtitle ~sidebar ~posts ~copyright ()
  in
  let content = make ~domain ~title:entry.C.Blog.Entry.subject content in
  Lwt.return (entry.C.Blog.Entry.permalink, content)

let blog_entries ~domain feed entries =
  Lwt_list.map_s (blog_entry ~domain feed entries) entries

let atom_index feed entries =
  C.Blog.to_atom ~feed ~entries
  >|= Cow.Atom.xml_of_feed
  >|= Cow.Xml.to_string

(* Construct an HTTP dispatch function for the blog *)
let dispatch ~domain feed entries =
  let content_type_xhtml = C.Headers.html in
  let content_type_atom  = C.Headers.atom in
  let blog_index = blog_index ~domain feed entries in
  let atom_index = atom_index feed entries in
  blog_entries ~domain feed entries >>= fun blog_entries ->
  let blog_entry x =
    try Lwt.return (List.assoc x blog_entries)
    with Not_found -> not_found [x] blog_entries
  in
  let f = function
    | [] | [""]    -> content_type_xhtml, blog_index
    | ["atom.xml"] -> content_type_atom , atom_index
    | [x]          -> content_type_xhtml, blog_entry x
    | x            -> content_type_xhtml, not_found x blog_entries
  in
  Lwt.return f
