open Printf
open Net.Http
open Log
open Lwt
open Cow

let md_file f =
  let f = match Filesystem_templates.t f with |Some x -> x |None -> "" in
  let md = Markdown.of_string f in
  Markdown.to_html md
 
let html_file f =
  let f = match Filesystem_templates.t f with |Some x -> x |None -> "" in
  <:html< <div class="post">
            $Html.of_string f$
          </div> >>

let read_file f =
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

module Index = struct
  let body = col_files (read_file "intro.md") none
  let t = Html.to_string (Template.t "Home" "home" body)
end

module Resources = struct
  let body = col_files (read_file "docs.md") Paper.html
  let t = Html.to_string (Template.t "Resources" "ressources" body)
end 

module About = struct
  let body = col_files (read_file "status.html") none
  let t = Html.to_string (Template.t "About" "about" body)
end

module Blog = struct
  open Blog

  (* Make a full Html.t including RSS link and headers from a list
     of Html.t entry fragments *)
  let make ?title body =
    let url = sprintf "%s/blog/atom.xml" Config.baseurl in
    let extra_header = <:html< 
     <link rel="alternate" type="application/atom+xml" href=$str:url$ />
    >> in
    let title = "blog" ^ match title with None -> "" | Some x -> " :: " ^ x in
    let html = Template.t ~extra_header "Blog" title body in
    Html.to_string html

  (* Main blog page Html.t fragment with all blog posts *)
  let main_page =
    make (Blog.html_of_entries read_file Blog.categories Blog.num Blog.entries)

  let ent_bodies = Hashtbl.create 1
  let _ =
    List.iter (fun entry ->
      let title = entry.subject in
      let body  = Blog.html_of_entries ~disqus:entry.permalink read_file Blog.categories Blog.num [entry] in
      Hashtbl.add ent_bodies entry.permalink (make ~title body);
    ) Blog.entries

  let lt1_bodies = Hashtbl.create 1
  let _ =
    List.iter (fun (lt1,_) ->
       let title   = lt1 in
       let entries = List.filter (fun entry ->
         List.exists (fun (c,_) -> c=lt1) entry.categories
       ) Blog.entries in
       let body = Blog.html_of_entries read_file Blog.categories Blog.num entries in
       Hashtbl.add lt1_bodies lt1 (make ~title body);
    ) Blog.categories

  let lt2_bodies = Hashtbl.create 1
  let _ =
    List.iter (fun (lt1,lt2s) ->
      List.iter (fun lt2 ->
         let title   = lt1 ^ " :: " ^ lt2 in
         let entries = List.filter (fun entry ->
           List.exists (fun (_,c) -> c = lt2) entry.categories
         ) Blog.entries in
         let body = Blog.html_of_entries read_file Blog.categories Blog.num entries in
         Hashtbl.add lt2_bodies lt2 (make ~title body);
      ) lt2s
    ) Blog.categories

  let atom_feed = 
    let f = Blog.atom_feed read_file Blog.entries in
    Xml.to_string (Atom.xml_of_feed f)

  let not_found x =
    sprintf "Not found: %s (known links: %s)"
      (String.concat " ... " x) 
      (String.concat " " 
         (Hashtbl.fold (fun k v a -> k :: a) 
            ent_bodies []))

  let t = function
    | []                          -> [], main_page
    | ["atom.xml"]                -> ["content-type","application/atom+xml; charset=UTF-8"], atom_feed
    | [x] when permalink_exists x -> [], (Hashtbl.find ent_bodies x)
    | x                           -> [], not_found x

  let tag = function
    | [lt1]     -> (try Hashtbl.find lt1_bodies lt1 with Not_found -> not_found [lt1])
    | [lt1;lt2] -> (try Hashtbl.find lt2_bodies lt2 with Not_found -> not_found [lt2])
    | x         -> not_found x
end

