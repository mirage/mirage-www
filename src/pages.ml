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

module Global = struct
   let nav_links = [
    "Blog", Uri.of_string "/blog";
    "Docs", Uri.of_string "/docs";
    "API", Uri.of_string "http://mirage.github.io";  (* TODO integrate *)
    "Community", Uri.of_string "/community";
  ]

  let top_nav =
    Cowabloga.Foundation.top_nav
      ~title:<:html<<img src="/graphics/mirage-logo-small.png" />&>>
      ~title_uri:(Uri.of_string "/")
      ~nav_links:(Cowabloga.Foundation.Link.top_nav ~align:`Left nav_links)

  let page ~title ~headers ~content =
    let font = <:html<
      <link rel="stylesheet" href="/css/font-awesome.css"> </link>
      <link href="http://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600,700" rel="stylesheet" type="text/css"> </link>
    >> in
    let headers = font @ headers in
    let content = top_nav @ content in
    let body = Cowabloga.Foundation.body ~title ~headers ~content in
    Cowabloga.Foundation.page ~body
end

module Index = struct

  let t ~feeds read_fn =
    lwt l1 = read_file read_fn "/intro-1.md" in
    lwt l2 = read_file read_fn "/intro-3.md" in
    lwt footer = read_file read_fn "/intro-f.html" in
    lwt recent = Cowabloga.Feed.to_html ~limit:12 feeds in
    let content = <:html<
    <div class="row">
      <div class="small-12 columns">
        <h3>A programming framework for building type-safe, modular systems</h3>
      </div>
    </div>
    <div class="row">
      <div class="small-12 medium-6 columns">$l1$ $l2$</div>
      <div class="small-12 medium-6 large-6 columns front_updates">
        <h4><a href="/updates/atom.xml"><i class="fa fa-rss"> </i></a>
         Recent Updates <small><a href="/updates/">(all)</a></small></h4>
        $recent$
      </div>
    </div>
    <div class="row">
      <div class="small-12 columns">$footer$</div>
    </div>
    >> in
    return (Global.page ~title:"Mirage OS" ~headers:[] ~content)

  let content_type_xhtml = ["content-type", "text/html"] (* TODO combine *)
  let content_type_atom  = ["content-type", "application/atom+xml; charset=UTF-8"]

  (* TODO have a way of rewriting all the pages with an associated Atom feed *)
  let make content =
    (* TODO need a URL routing mechanism instead of assuming / *)
    let uri = Uri.of_string "/updates/atom.xml" in
    let headers =
      <:xml<<link rel="alternate" type="application/atom+xml" href=$uri:uri$ /> >> in
    let title = "Updates" in
    Global.page ~title ~headers ~content

  let dispatch ~feed ~feeds =
    lwt atom =
      Cowabloga.Feed.to_atom ~meta:feed ~feeds 
      >|= Cow.Atom.xml_of_feed
      >|= Cow.Xml.to_string
    in
    lwt recent = Cowabloga.Feed.to_html feeds in
    let content = make <:html<
       <div class="row">
         <div class="small-12 medium-9 large-6 front_updates">
         <h2>Site Updates <small>across the blogs and documentation</small></h2>
          $recent$
         </div>
       </div> >> in
    return (function
     |[""]|[] -> content_type_xhtml, (return content)
     |["atom.xml"] -> content_type_atom, (return atom)
     |_ -> content_type_xhtml, (return "")
    )
end

module About = struct

  let t read_fn =
    lwt i = read_file read_fn "/about-intro.md" in
    lwt l = read_file read_fn "/about.md" in
    lwt r = read_file read_fn "/about-community.md" in
    lwt b = read_file read_fn "/about-b.md" in
    lwt f = read_file read_fn "/about-funding.md" in
    let content = <:html<
    <div class="row">
      <div class="small-12 medium-6 columns">$i$</div>
      <div class="small-12 medium-6 columns">$f$</div>
    </div>
    <div class="row">
      <div class="small-12 columns">$b$</div>
    </div>
    <div class="row">
      <div class="small-12 medium-6 columns">$l$</div>
      <div class="small-12 medium-6 columns">$r$</div>
    </div>
    >> in
    return (Global.page ~title:"Community" ~headers:[] ~content)
end


