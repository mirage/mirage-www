open Data
open Lwt
open Cowabloga.Atom_feed
open Cowabloga.Blog

(* Construct an HTTP dispatch function for the blog *)
let dispatch ({title; subtitle; rights} as feed) entries =

  let make ?title content =
    (* TODO need a URL routing mechanism instead of assuming / *)
    let uri = Uri.of_string "/blog/atom.xml" in
    let headers =
      <:xml<<link rel="alternate" type="application/atom+xml" href=$uri:uri$ /> >> in
    let title = "Blog" ^ match title with None -> "" | Some x -> " :: " ^ x in
    Pages.Global.page ~title ~headers ~content in

  (* TODO use a mime type db (from cohttp?) *)
  let content_type_xhtml = ["content-type", "text/html"] in
  let content_type_atom  = ["content-type", "application/atom+xml; charset=UTF-8"] in

  let copyright =
    match rights with 
    | None -> [] 
    | Some r -> [`Data r]
  in

  let main_blog_index =
    let recent_posts = recent_posts feed entries in
    let sidebar = Cowabloga.Foundation.Sidebar.t
        ~title:"Recent Posts" ~content:recent_posts in
    lwt posts = Cowabloga.Blog.to_html feed entries in
    let content = Cowabloga.Blog_template.t ~title ~subtitle 
        ~sidebar ~posts ~copyright () in
    return (make content)
  in

  lwt blog_entries =
    Lwt_list.map_s (fun ent ->
        let module C = Cowabloga in
        let recent_posts = recent_posts feed entries in
        let sidebar = C.Foundation.Sidebar.t ~title:"Recent Posts" ~content:recent_posts in
        lwt posts = C.Blog.Entry.to_html feed ent in
        let content = C.Blog_template.t ~title ~subtitle ~sidebar ~posts ~copyright () in
        let content = make content in
        return (ent.C.Blog.Entry.permalink, content)
      ) entries
  in

  let atom_index =
    Cowabloga.Blog.to_atom ~feed ~entries 
    >|= Cow.Atom.xml_of_feed
    >|= Cow.Xml.to_string
  in

  let not_found x =
    return (Printf.sprintf "Not found: %s (known links: %s)"
              (String.concat " ... " x)
              (String.concat " "
                 (List.fold_left (fun a (v,_) -> v::a) [] blog_entries)))
  in

  return (
    function
    | [] | [""] -> content_type_xhtml, main_blog_index
    | ["atom.xml"] -> content_type_atom, atom_index
    | [x] when List.mem_assoc x blog_entries ->
      content_type_xhtml, return ((List.assoc x blog_entries))
    | x -> content_type_xhtml, not_found x
  )
