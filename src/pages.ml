open Printf
open Http
open Log
open Lwt
open Cow

let md_file f =
  let f = match Filesystem_templates.t f with |Some x -> x |None -> "" in
  let md = Markdown.of_string f in
  Markdown.to_html md
 
let html_file f =
  let f = match Filesystem_templates.t f with |Some x -> x |None -> "" in
  <:html<<div class="post">$Html.of_string f$</div>&>>

let read_file f =
  let f = "wiki/" ^ f in
  let suffix =
    try let n = String.rindex f '.' in
        String.sub f (n+1) (String.length f - n - 1)
    with _ -> "" in
  match suffix with
    | "md"   -> md_file f
    | "html" -> html_file f
    | _      -> []

let col_files l r = <:html< 
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

let content_type_xhtml = ["content-type","application/xhtml+xml"]

module Index = struct
  let body = col_files (read_file "intro.md") none
  let t = Html.to_string (Template.t "Home" "home" body)
end

module Resources = struct
  let body = col_files (read_file "docs.md") Paper.html
  let t = Html.to_string (Template.t "Resources" "ressources" body)
end 

module About = struct
  let body = col_files (read_file "about.md") none
  let t = Html.to_string (Template.t "About" "about" body)
end

module Wiki = struct
  open Wiki

  (* the right column of wiki page is always the same *)
  let right_column = Wiki.short_html_of_categories entries categories

  (* Make a full Html.t including RSS link and headers from an wiki page *)
  let make ?title ?disqus left_column =
    let url = sprintf "%s/wiki/atom.xml" Config.baseurl in
    let extra_header = <:html< 
     <link rel="alternate" type="application/atom+xml" href=$str:url$ />
    >> in
    let title = "wiki" ^ match title with None -> "" | Some x -> " :: " ^ x in
    let body = Wiki.html_of_page ?disqus ~left_column ~right_column in  
    let html = Template.t ~extra_header "Wiki" title body in
    Html.to_string html

  (* Main wiki page Html.t fragment with the index page *)
  let main_page =
    let left_column = 
      Wiki.html_of_entry read_file Wiki.index @
      Wiki.html_of_categories Wiki.entries Wiki.categories in
    make ~title:Wiki.index.subject ~disqus:Wiki.index.permalink left_column

  let ent_bodies = Hashtbl.create 1
  let _ =
    List.iter (fun entry ->
      let title = entry.subject in
      let left  = Wiki.html_of_entry read_file entry in
      Hashtbl.add ent_bodies entry.permalink (make ~title ~disqus:entry.permalink left);
    ) Wiki.entries

  let lt1_bodies = Hashtbl.create 1
  let _ =
    List.iter (fun (lt1,_) ->
       let title = lt1 in
       let left  = Wiki.html_of_category Wiki.entries (lt1, None) in
       Hashtbl.add lt1_bodies lt1 (make ~title left);
    ) Wiki.categories

  let lt2_bodies = Hashtbl.create 1
  let _ =
    List.iter (fun (lt1,lt2s) ->
      List.iter (fun lt2 ->
         let title = lt1 ^ " :: " ^ lt2 in
         let left = Wiki.html_of_category Wiki.entries (lt1, Some lt2) in
         Hashtbl.add lt2_bodies lt2 (make ~title left);
      ) lt2s
    ) Wiki.categories

  let atom_feed = 
    let f = Wiki.atom_feed read_file Wiki.entries in
    Xml.to_string (Atom.xml_of_feed ~self:(Config.baseurl ^ "/wiki/atom.xml") f)

  let not_found x =
    let left =
      sprintf "Not found: %s (known links: wiki/%s)"
        (String.concat " ... " x) 
        (String.concat " " 
           (Hashtbl.fold (fun k v a -> k :: a) 
              ent_bodies [])) in
    make ~title:"Not Found" <:html<$str:left$>>

  let t = function
    | []                          -> content_type_xhtml, main_page
    | ["atom.xml"]                -> ["content-type","application/atom+xml; charset=UTF-8"], atom_feed
    | [x] when permalink_exists x -> content_type_xhtml, (Hashtbl.find ent_bodies x)
    | x                           -> content_type_xhtml, not_found x

  let tag = function
    | []        -> main_page
    | [lt1]     -> (try Hashtbl.find lt1_bodies lt1 with Not_found -> not_found [lt1])
    | [lt1;lt2] -> (try Hashtbl.find lt2_bodies lt2 with Not_found -> not_found [lt2])
    | x         -> not_found x
end

