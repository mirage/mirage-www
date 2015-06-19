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
  let nav_links = <:xml<
    <ul class="left">
      <li><a href="/blog/">Blog</a></li>
      <li><a href="/docs/">Docs</a></li>
      <li><a href="http://mirage.github.io/">API</a></li>
      <li><a href="/releases/">Changes</a></li>
      <li class="has-dropdown">
        <a href="/community/">Community</a>
        <ul class="dropdown">
          <li><a href="/community/">Background</a></li>
          <li><a href="/community/">Contact</a></li>
          <li><a href="/community/#team">Team</a></li>
          <li><a href="/community/#blogroll">Blogroll</a></li>
          <li><a href="/links/">Links</a></li>
        </ul>
      </li>
     </ul> >>

  let top_nav =
    Cowabloga.Foundation.top_nav
      ~title:<:html<<img src="/graphics/mirage-logo-small.png" />&>>
      ~title_uri:(Uri.of_string "/")
      ~nav_links

  let page ~title ~headers ~content =
    let font = <:html<
      <link rel="stylesheet" href="/css/font-awesome.css"> </link>
      <link href="http://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600,700" rel="stylesheet" type="text/css"> </link>
    >> in
    let headers = font @ headers in
    let content = top_nav @ content in
    let google_analytics = Site_config.google_analytics in
    let body =
      Cowabloga.Foundation.body ~highlight:"/css/magula.css"
        ~google_analytics ~title ~headers ~content ~trailers:[] ()
    in
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
    return (Global.page ~title:"MirageOS" ~headers:[] ~content)

  let content_type_xhtml = Cowabloga.Headers.html
  let content_type_atom  = Cowabloga.Headers.atom

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

module Links = struct
  let dispatch feed ls =
    let open Cowabloga.Links in
    lwt body = Cowabloga.Feed.to_html [ `Links (feed, ls) ] in
    let content = <:html<
      <div class="row">
        <div class="small-12 medium-9 large-6 columns">
          <h2>Around the Web</h2>
          <p>
            This is a small link blog we maintain as we hear of stories or
            interesting blog entries that may be useful for MirageOS users. If
            you'd like to add one, please do <a href="/community/">get in
            touch</a>.
          </p>
          <br />
          $body$
        </div>
      </div>
    >> in
    let body = Global.page ~title:"Around the Web" ~headers:[] ~content in
    let h = Hashtbl.create 1 in
    List.iter (fun l -> Hashtbl.add h (sprintf "%s/%s" l.stream.name l.id) l.uri) ls;
    return (
      function
      | [] -> `Html (return body)
      | [id;link] ->
        let id = sprintf "%s/%s" id link in
        if Hashtbl.mem h id then
          `Redirect (Uri.to_string (Hashtbl.find h id))
        else
          `Not_found id
      | x -> `Not_found (String.concat "|" x)
    )
end

module About = struct
  let t read_fn =
    lwt i = read_file read_fn "/about-intro.md" in
    lwt l = read_file read_fn "/about.md" in
    lwt r = read_file read_fn "/about-community.md" in
    lwt b = read_file read_fn "/about-b.md" in
    lwt f = read_file read_fn "/about-funding.md" in
    lwt br = read_file read_fn "/about-blogroll.md" in
    let content = <:html<
    <a name="about"> </a>
    <div class="row">
      <div class="small-12 medium-6 columns">$i$</div>
      <div class="small-12 medium-6 columns">$f$</div>
      <hr/>
    </div>
    <a name="participate"> </a>
    <div class="row">
      <div class="small-12 columns">$b$</div>
      <hr />
    </div>
    <a name="team"> </a>
    <div class="row">
      <div class="small-12 medium-6 columns">$l$</div>
      <div class="small-12 medium-6 columns">$r$</div>
      <hr />
    </div>
    <a name="blogroll"> </a>
    <div class="row">
      <div class="small-12 medium-6 columns">$br$</div>
    </div> >> in
    return (Global.page ~title:"Community" ~headers:[] ~content)
end

module Releases = struct

  let content_type_xhtml = Cowabloga.Headers.html

  let changelog read_fn =
    lwt c = read_file read_fn "/changelog.md" in
    let content = <:html<
      <div class="row">
        <div class="small-12 medium-12 large-9 columns">
          <h2>Changelogs of ecosystem libraries</h2>
          <p>MirageOS consists of numerous libraries that are independently developed
             and released.  This page lists the chronological stream of releases, 
             along with the summary of changes that went into each library.  The
             MirageOS <a href="https://github.com/mirage">organization</a> holds most
             of the major libraries if you just want to browse.</p>
          <p>We also provide a short list of <a href='/wiki/breaking-changes'>backwards incompatible changes</a>.</p>
          $c$
        </div>
      </div>
    >> in
    return (Global.page ~title:"Changelog" ~headers:[] ~content)

  let dispatch read_fn =
    return (function
     |[""]|[] -> content_type_xhtml, (changelog read_fn)
     |_ -> content_type_xhtml, (return ""))
end
