open Printf
open Cohttp
open Lwt
open Cow

let read_file tmpl_read f =
  try_lwt
  let suffix =
    try let n = String.rindex f '.' in
        String.sub f (n+1) (String.length f - n - 1)
    with _ -> "" in
  match suffix with
    | "md"   -> tmpl_read f >|= Markdown_omd.of_string
    | "html" -> tmpl_read f >|= Html.of_string
    | _      -> return []
  with exn ->
    printf "Pages.read_file: exception %s\n%!" (Printexc.to_string exn);
    exit 1

type pages = {
  idx: string;
}

 
let col_files l r = <:xml<
  <div class="left_column">
    <div class="summary_information"> $l$ </div>
  </div>
  <div class="right_column"> $r$ </div>
>>

let column_css = <:css<
  /* Column Styling */
  .left_column {
    float: left;
    width: 475px;
    text-align: justify;
  }
  .right_column {
    float: right;
    width: 475px;
  }
>>

let none : Html.t = []

module Index = struct

  let body read_fn =
    lwt l1 =
      read_file read_fn "/intro.md"
      >|= (fun l -> col_files l none) in
    lwt l2 =
      read_file read_fn "/intro-r.html"
       >|= (fun l -> col_files l none) in
    return (<:xml<
    <div class="left_column">
      $l1$
    </div>
    <div class="right_column">
      $l2$
    </div>
    >>)

  let t read_fn =
    Template.t read_fn "Home" "home" (body read_fn)
    >|= Html.to_string
end

module Resources = struct
  let body read_fn =
    read_file read_fn "/docs.md"
    >|= (fun l -> col_files l Paper.html)

  let t read_fn =
    Template.t read_fn "Resources" "resources" (body read_fn)
    >|= Html.to_string
end

module About = struct

  let body read_fn =
    lwt l = read_file read_fn "/about.md" in
    lwt r = read_file read_fn "/about-r.md" in
    return (col_files l r)

  let t read_fn =
    Template.t read_fn "About" "about" (body read_fn)
    >|= Html.to_string
end

module Blog = struct
  open Blog

  (* Make a full Html.t including RSS link and headers from a list
     of Html.t entry fragments *)
  let make ?title body read_fn =
    let url = sprintf "/blog/atom.xml" in
    let extra_header = <:xml<
     <link rel="alternate" type="application/atom+xml" href=$str:url$ />
    >> in
    let title = "blog" ^ match title with None -> "" | Some x -> " :: " ^ x in
    lwt html = Template.t read_fn ~extra_header "Blog" title body in
    return (Html.to_string html)

  (* Main blog page Html.t fragment with all blog posts *)
  let main_page (read_fn:string -> string Lwt.t) =
    make (Blog.html_of_entries (read_file read_fn) Blog.entries) read_fn

  let init read_fn =
    let ent_bodies = Hashtbl.create 1 in
    List.iter (fun entry ->
      let title = entry.subject in
      let body = Blog.html_of_entries ~disqus:entry.permalink
        (read_file read_fn) [entry] in
      Hashtbl.add ent_bodies entry.permalink (make ~title body read_fn);
    ) Blog.entries;
    ent_bodies

  let atom_feed read_fn =
    lwt f = Blog.atom_feed (read_file read_fn) Blog.entries in
    return (Xml.to_string (Atom.xml_of_feed ~self:("/blog/atom.xml") f))

  let not_found ent_bodies x =
    return (sprintf "Not found: %s (known links: %s)"
      (String.concat " ... " x)
      (String.concat " "
         (Hashtbl.fold (fun k v a -> k :: a)
            ent_bodies [])))

  let content_type_xhtml = ["content-type", "text/html"]

  let t ent_bodies read_fn =
    function
    | [] -> content_type_xhtml, (main_page read_fn)
    | ["atom.xml"] -> ["content-type","application/atom+xml; charset=UTF-8"], (atom_feed read_fn)
    | [x] when permalink_exists x -> content_type_xhtml, (Hashtbl.find ent_bodies x)
    | x -> content_type_xhtml, (not_found ent_bodies x)

end

module Wiki = struct
  open Wiki

  (* the right column of wiki page is always the same *)
  let right_column = Wiki.short_html_of_categories entries categories

  let read_file read_fn f = read_file read_fn ("/wiki/" ^ f)

  (* Make a full Html.t including RSS link and headers from an wiki page *)
  let make ?title ?disqus left_column read_fn =
    let url = sprintf "/wiki/atom.xml" in
    let extra_header = <:xml<
     <link rel="alternate" type="application/atom+xml" href=$str:url$ />
    >> in
    let title = "wiki" ^ match title with
      |None -> "" |Some x -> " :: " ^ x in
    let body = Wiki.html_of_page ?disqus ~left_column ~right_column in
    Template.t ~extra_header read_fn "Wiki" title body
    >|= Html.to_string

  (* Main wiki page Html.t fragment with the index page *)
  let main_page read_fn =
    lwt idx = Wiki.html_of_index (read_file read_fn) in
    let idx2 = Wiki.html_of_recent_updates Wiki.entries in
    let left_column = idx @ idx2 in
    make ~title:"index" (return left_column) read_fn

  let init read_fn =
    let ent_bodies = Hashtbl.create 1 in
    List.iter (fun entry ->
      let title = entry.subject in
      let left  = Wiki.html_of_entry (read_file read_fn) entry in
      let body = make ~title ~disqus:entry.permalink left read_fn in
      Hashtbl.add ent_bodies entry.permalink body
    ) Wiki.entries;
    ent_bodies

  let init_lt1 read_fn =
    let lt1_bodies = Hashtbl.create 1 in
    List.iter (fun (lt1,_) ->
       let title = lt1 in
       let left  = Wiki.html_of_category Wiki.entries (lt1, None) in
       Hashtbl.add lt1_bodies lt1 (make ~title (return left) read_fn);
    ) Wiki.categories;
    lt1_bodies

  let init_lt2 read_fn =
    let lt2_bodies = Hashtbl.create 1 in
    List.iter (fun (lt1,lt2s) ->
      List.iter (fun lt2 ->
         let title = lt1 ^ " :: " ^ lt2 in
         let left = Wiki.html_of_category Wiki.entries (lt1, Some lt2) in
         Hashtbl.add lt2_bodies lt2 (make ~title (return left) read_fn);
      ) lt2s
    ) Wiki.categories;
    lt2_bodies

  let atom_feed read_fn =
    lwt f = Wiki.atom_feed (read_file read_fn) Wiki.entries in
    return (Xml.to_string (Atom.xml_of_feed ~self:("/wiki/atom.xml") f))

  let not_found x ent_bodies read_fn =
    let left =
      sprintf "Not found: %s (known links: wiki/%s)"
        (String.concat " ... " x)
        (String.concat " "
           (Hashtbl.fold (fun k v a -> k :: a)
              ent_bodies [])) in
    make ~title:"Not Found" (return <:xml<$str:left$>>) read_fn

  let content_type_xhtml = ["content-type", "text/html"]
  let t ents lt1 lt2 read_fn = function
    | []                          -> content_type_xhtml, (main_page read_fn)
    | ["atom.xml"]                -> ["content-type","application/atom+xml; charset=UTF-8"], (atom_feed read_fn)
    | [x] when permalink_exists x -> content_type_xhtml, (Hashtbl.find ents x)
    | x                           -> content_type_xhtml, (not_found x ents read_fn)

  let tag ents lt1_bodies lt2_bodies read_fn = function
    | []        -> main_page read_fn
    | [lt1]     -> (try Hashtbl.find lt1_bodies lt1 with Not_found -> not_found [lt1] ents read_fn)
    | [lt1;lt2] -> (try Hashtbl.find lt2_bodies lt2 with Not_found -> not_found [lt2] ents read_fn)
    | x         -> not_found x ents read_fn
end
