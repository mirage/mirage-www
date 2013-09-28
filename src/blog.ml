open Cow
open Printf
open Lwt

(* Date *)

type month = int

let xml_of_month m =
  let str = match m with
    | 1  -> "Jan" | 2  -> "Feb" | 3  -> "Mar"
    | 4  -> "Apr" | 5  -> "May" | 6  -> "Jun"
    | 7  -> "Jul" | 8  -> "Aug" | 9  -> "Sep"
    | 10 -> "Oct" | 11 -> "Nov" | 12 -> "Dec"
    | _  -> "???" in
  <:xml<$str:str$>>

type date = {
  month : month;
  day   : int;
  year  : int;
  hour  : int;
  min   : int;
} with xml

let html_of_date d =
  <:xml<
    <div class="date">
      <div class="month">$xml_of_month d.month$</div>
      <div class="day">$int:d.day$</div>
      <div class="year">$int:d.year$</div>
      <div class="hour">$int:d.hour$</div>
      <div class="min">$int:d.min$</div>
    </div>
  >>

let date (year, month, day, hour, min) =
  { month; day; year; hour; min }

let atom_date d =
  ( d.year, d.month, d.day, d.hour, d.min)

(* Entry *)

let html_of_author author =
  match author.Atom.uri with
    | None     -> <:xml<Posted by $str:author.Atom.name$>>
    | Some uri -> <:xml<Posted by <a href=$str:uri$>$str:author.Atom.name$</a>&>>

type entry = {
  updated    : date;
  author     : Atom.author;
  subject    : string;
  body       : string;
  permalink  : string;
}
(* Convert a blog record into an Html.t fragment *)
let html_of_entry read_file e =
  lwt body = read_file e.body in
  let permalink = Config.mk_uri (sprintf "/blog/%s" e.permalink) in
  let permalink_disqus = sprintf "/blog/%s#disqus_thread" e.permalink in
  return <:xml<
    <div class="blog_entry">
      $html_of_date e.updated$
      <div class="blog_entry_heading">
        <div class="blog_entry_title">
          <a href=$str:Uri.to_string permalink$>$str:e.subject$</a>
        </div>
        <div class="blog_entry_info">
          <i>$html_of_author e.author$</i>
        </div>
     </div>
     <div class="blog_entry_body">$body$</div>
     <a href=$str:permalink_disqus$>Comments</a>
   </div>
 >>

let entry_css = <:css<
  .blog_entry {
    margin-top: 0px;
    margin-bottom: 20px;

    pre {
      padding-left: 15px;
      border-left: 1px solid #ddd;
      border: 1px solid #ddd;
      background: #eee;
      font-size: 1.2em;
      margin-left: 2em;
      margin-right: 6em;
    }

    .blog_entry_heading {
      margin-left: 0px;
      margin-bottom: 0px;
    }
    .blog_entry_title { 
      font-size: 1.6em; 
      font-weight: bold;
    }
    .blog_entry_info {
      margin-top: 0px;
      font-size: 1.0em;
    }
    .blog_entry_body {
      margin-left: 0px;
      margin-top: 3px;
      font-size: 1.1em;
    }
  }
>>

(* Entries *)

(* From a list of Html.t entries, wrap it in the Blog Html.t *)
let html_of_entries ?disqus read_file entries =

  (* The disqus comment *)
  let disqus_html permalink = <:xml<
    <div class="blog_comments">
    <h2>Comments</h2>
    <div id="disqus_thread"></div>
    </div>
    <script type="text/javascript">
     var disqus_shortname = 'openmirage';
     var disqus_identifier = '/blog/$str:permalink$';
     var disqus_url = 'http://openmirage.org/blog/$str:permalink$';
     (function() {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
     })();
     </script>
  >> in

  let dh = match disqus with
     | Some perm -> disqus_html perm
     | None -> <:xml< >> in
  lwt entries = Lwt_list.map_s (html_of_entry read_file) entries in
  return <:xml<
  <div class="left_column_blog">
    <div class="summary_information">
      $list:entries$
    </div>
  </div>
  <div style="clear:both;"></div>
  $dh$
>>

let entries_css = <:css<
  .left_column_blog {
    float: left;
    width: 800px;
    $entry_css$;
  }
  .blog_comments {
   width: 640px;
  }
>>

(* Data *)

open People

let entries = [
  { updated    = date (2010, 10, 11, 15, 0);
    author     = anil;
    subject    = "Self-hosting Mirage website";
    body       = "/blog/welcome.md";
    permalink  = "self-hosting-mirage-website";
  };
  { updated    = date (2011, 04, 11, 15, 0);
    author     = anil;
    subject    = "A Spring Wiki Cleaning";
    body       = "/blog/spring-cleaning.md";
    permalink  = "spring-cleaning";
  };
  { updated    = date (2011, 09, 29, 11, 10);
    author     = anil;
    subject    = "An Outing to CUFP 2011";
    body       = "/blog/an-outing-to-cufp.md";
    permalink  = "an-outing-to-cufp";
  };
  { updated    = date (2012, 02, 29, 11, 10);
    author     = mort;
    subject    = "Connected Cloud Control: OpenFlow in Mirage";
    body       = "/blog/announcing-mirage-openflow.md";
    permalink  = "announcing-mirage-openflow";
  };
  { updated    = date (2012, 9, 12, 0, 0);
    author     = dave;
    subject    = "Building a \"xenstore stub domain\" with Mirage";
    body       = "/blog/xenstore-stub.md";
    permalink  = "xenstore-stub-domain";
  };
  { updated    = date (2012, 10, 17, 17, 30);
    author     = anil;
    subject    = "Breaking up is easy to do (with OPAM)";
    body       = "/blog/breaking-up-with-opam.md";
    permalink  = "breaking-up-is-easy-with-opam";
  };
  { updated    = date (2013, 05, 20, 16, 20);
    author     = anil;
    subject    = "The road to a developer preview at OSCON 2013";
    body       = "/blog/the-road-to-a-dev-release.md";
    permalink  = "the-road-to-a-dev-release";
  };
  { updated    = date (2013, 07, 18, 11, 20);
    author     = dave;
    subject    = "Creating Xen block devices with Mirage";
    body       = "/blog/xen-block-devices-with-mirage.md";
    permalink  = "xen-block-devices-with-mirage";
  };
  { updated    = date (2013, 08, 08, 16, 00);
    author     = mort;
    subject    = "Mirage travels to OSCON'13: a trip report";
    body       = "/blog/oscon13-trip-report.md";
    permalink  = "oscon13-trip-report";
  };
  { updated    = date (2013, 08, 23, 17, 43);
    author     = vb;
    subject    = "Introducing vchan";
    body       = "/blog/introducing-vchan.md";
    permalink  = "introducing-vchan";
  };
]

let cmp_ent a b = Atom.compare (atom_date a.updated) (atom_date b.updated)

let entries = List.rev (List.sort cmp_ent entries)
let _ = List.iter (fun x -> Printf.printf "ENT: %s\n%!" x.subject) entries

let permalink e =
  sprintf "/blog/%s" e.permalink

let permalink_exists x = List.exists (fun e -> e.permalink = x) entries

let atom_entry_of_ent filefn e =
  let links = [
    Atom.mk_link ~rel:`alternate ~typ:"text/html"
      (Uri.of_string (permalink e)) 
  ] in
  let meta = {
    Atom.id      = permalink e;
    title        = e.subject;
    subtitle     = None;
    author       = Some e.author;
    updated      = atom_date e.updated;
    links;
    rights;
  } in 
  lwt content = filefn e.body in
  return {
    Atom.entry = meta;
    summary    = None;
    base       = None;
    content;
  }
  
let atom_feed filefn es = 
  let es = List.rev (List.sort cmp_ent es) in
  let updated = atom_date (List.hd es).updated in
  let id = "/blog/" in
  let title = "openmirage blog" in
  let subtitle = Some "a cloud operating system" in
  let links = [
    Atom.mk_link (Config.mk_uri "/blog/atom.xml");
    Atom.mk_link ~rel:`alternate ~typ:"text/html" (Config.mk_uri "/blog/")
  ] in
  let feed = { Atom.id; title; subtitle; author=None; rights; updated; links } in
  lwt entries = Lwt_list.map_s (atom_entry_of_ent filefn) es in
  return { Atom.feed=feed; entries }

