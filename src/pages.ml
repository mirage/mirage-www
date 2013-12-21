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
    | "md"   -> tmpl_read f >|= Markdown.of_string
    | "html" -> tmpl_read f >|= Html.of_string
    | _      -> return []
  with exn ->
    printf "Pages.read_file: exception %s\n%!" (Printexc.to_string exn);
    exit 1

let two_cols l r = <:html<
  <div class="row">
    <div class="large-6 columns">$l$</div>
    <div class="large-6 columns">$r$</div>
  </div>
>>

let none : Html.t = []

module Global = struct
   let nav_links = [
    "Blog", Uri.of_string "/blog";
    "Docs", Uri.of_string "/docs";
    "API", Uri.of_string "/api";
    "Community", Uri.of_string "/community";
    "About", Uri.of_string "/about";
  ] 

  let top_nav =
  Cowabloga.Foundation.top_nav 
    ~title:"Mirage OS"
    ~title_uri:(Uri.of_string "/") 
    ~nav_links:(Cowabloga.Foundation.Link.top_nav ~align:`Left nav_links)

  let page ~title ~headers ~content =
    let content = top_nav @ content in
    let body = Cowabloga.Foundation.body ~title ~headers ~content in
    Cowabloga.Foundation.page ~body
end

module Index = struct

  let body read_fn =
    lwt l1 = read_file read_fn "/intro.md" in
    lwt l2 = read_file read_fn "/intro-r.html" in
    return (<:xml<
    <div class="row">
      <div class="large-6 columns">$l1$</div>
      <div class="large-6 columns">$l2$</div>
    </div>
    >>)

  let t read_fn =
    body read_fn
    >|= fun content ->
    Global.page ~title:"Mirage OS" ~headers:[] ~content

end

module Resources = struct
  let body read_fn =
    read_file read_fn "/docs.md"
    >|= (fun l -> two_cols l Paper.html)

  let t read_fn =
    Template.t read_fn "Resources" "resources" (body read_fn)
    >|= Html.to_string
end

module About = struct

  let body read_fn =
    lwt l = read_file read_fn "/about.md" in
    lwt r = read_file read_fn "/about-r.md" in
    return (two_cols l r)

  let t read_fn =
    Template.t read_fn "About" "about" (body read_fn)
    >|= Html.to_string
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
