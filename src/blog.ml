open Cow
open Printf

(* Date *)

type month = int

let html_of_month m =
  let str = match m with
    | 1  -> "Jan"
    | 2  -> "Feb"
    | 3  -> "Mar"
    | 4  -> "Apr"
    | 5  -> "May"
    | 6  -> "Jun"
    | 7  -> "Jul"
    | 8  -> "Aug"
    | 9  -> "Sep"
    | 10 -> "Oct"
    | 11 -> "Nov"
    | 12 -> "Dec"
    | _  -> "???" in
  <:html<$str:str$>>

type date = {
  month : month;
  day   : int;
  year  : int;
  hour  : int;
  min   : int;
} with html

let date (year, month, day, hour, min) =
  { month; day; year; hour; min }

let atom_date d =
  (d.month, d.day, d.year, d.hour, d.min)

let date_css = <:css<
  .date {
    border: 1px solid #999; 
    line-height: 1; 
    width: 4em;
    position: relative;
    float: left;
    margin-right: 15px;
    text-align: center; 

    .month {
      text-transform: uppercase; 
      font-size: 1.2em;
      padding-top: 0.3em; 
    }
    .day {
      font-size: 2em;
    }
    .year { 
      background-color: #2358B8; 
      color: #FFF; 
      font-size: 1.2em; 
      padding: 0.3em 0; 
      margin-top: 0.3em;
    }
    .hour {
      display: none;
    }
    .min {
      display: none;
    }
  }
>>

(* Entry *)

let html_of_author author =
  match author.Atom.uri with
    | None     -> <:html<Posted by $str:author.Atom.name$>>
    | Some uri -> <:html<Posted by <a href=$str:uri$>$str:author.Atom.name$</a>&>>

type category = string * string  (* category, subcategory, see list of them below *)

type entry = {
  updated    : date;
  author     : Atom.author;
  subject    : string;
  categories : category list;
  body       : string;
  permalink  : string;
}
(* Convert a blog record into an Html.t fragment *)
let html_of_entry read_file e =
  let permalink = sprintf "%s/blog/%s" Config.baseurl e.permalink in
  let permalink_disqus = sprintf "%s/blog/%s#disqus_thread" Config.baseurl e.permalink in
  <:html<
    <div class="blog_entry">
      $html_of_date e.updated$
      <div class="blog_entry_heading">
        <div class="blog_entry_title">
          <a href=$str:permalink$>$str:e.subject$</a>
        </div>
        <div class="blog_entry_info">
          <i>$html_of_author e.author$</i>
        </div>
     </div>
     <div class="blog_entry_body">$read_file e.body$</div>
     <a href=$str:permalink_disqus$>Comments</a>
   </div>
 >>

let entry_css = <:css<
  .blog_entry {
    margin-bottom: 20px;

    $date_css$;

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
      margin-top: 0px;
      margin-left: 4px;
      margin-bottom: 4px;
    }
    .blog_entry_title { 
      font-size: 2em; 
      font-weight: bold;
    }
    .blog_entry_info {
      font-size: 1.5em;
    }
    .blog_entry_body {
      margin-left: 6px;
      font-size: 1em;
    }
  }
>>

(* Category *)

type num = {
  l1 : string -> int;
  l2 : string -> string -> int;
}

(* XXX: the num_li functions can be optimized *)
let num_of_entries entries =
  let num_l1 l1 =
    List.fold_left (fun a e ->
      List.fold_left (fun a (l1',_) ->
        if l1' = l1 then a+1 else a
      ) 0 e.categories + a
    ) 0 entries in

  let num_l2 l1 l2 =
    List.fold_left (fun a e ->
      List.fold_left (fun a (l1',l2') ->
        if l1'=l1 && l2'=l2 then a+1 else a
      ) 0 e.categories + a
    ) 0 entries in

  {
    l1 = num_l1;
    l2 = num_l2;
  }

(* Generate the category bar Html.t fragment *)
let html_of_category num (l1, l2l) =
  let l2h = List.map (fun l2 ->
    match num.l2 l1 l2 with 
      | 0   -> <:html< <div class="blog_bar_l2">$str:l2$</div> >>
      | nl2 ->
        let num = <:html< <i>$str:sprintf "(%d)" nl2$</i> >> in
        let url = sprintf "%s/tag/%s/%s" Config.baseurl l1 l2 in
        <:html< <div class="blog_bar_l2"><a href=$str:url$>$str:l2$</a>$num$</div> >>
  ) l2l in
  let url = sprintf "%s/tag/%s" Config.baseurl l1 in
  let l1h = match num.l1 l1 with
    | 0   -> <:html< <div class="blog_bar_l1">$str:l1$</div> >>
    | nl1 -> <:html< <div class="blog_bar_l1"><a href=$str:url$>$str:l1$</a></div> >> in
  <:html<
    $l1h$
    $list:l2h$
  >>

let category_css = <:css<
  .blog_bar_l1 {
    font-size: 1.2em;
    padding-right: 5px;
  }
  .blog_bar_l2 {
    font-size: 1em;
    margin-left: 1.5em;
  }
>>

(* The full right bar in blog *)
let html_of_categories num categories =
  let url = sprintf "%s/blog/" Config.baseurl in
  <:html<
    <div class="blog_bar">
      <div class="blog_bar_l0"><a href=$str:url$>Index</a></div>
      $list:List.map (html_of_category num) categories$
    </div>
 >>

let categories_css = <:css<
  .blog_bar {
    text-align: right;
    border-right: 1px solid #eee;
    padding: 5px;

    .blog_bar_l0 {
      font-size: 2.0em;
      padding-right: 5px;
    }
    $category_css$
  }
>>

(* Entries *)

(* From a list of Html.t entries, wrap it in the Blog Html.t *)
let html_of_entries ?disqus read_file categories num entries =

  (* The disqus comment *)
  let disqus_html permalink = <:html<
    <div class="blog_entry_comments">
    <div id="disqus_thread"/>
    <script type="text/javascript"> 
      var disqus_identifer = $str:permalink$; 
      (function() { 
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
         dsq.src = 'http://openmirage.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
       })()
    </script>
    </div>
  >> in

  let dh = match disqus with
     | Some perm -> disqus_html perm
     | None -> <:html< >> in

  <:html<
  <div class="left_column_blog">
    <div class="summary_information">
      $list:List.map (html_of_entry read_file) entries$
    </div>
  </div>
  <div class="right_column_blog">
    $html_of_categories num categories$
  </div>
  $dh$
>>

let entries_css = <:css<
  .left_column_blog {
    float: left;
    width: 840px;
    $entry_css$;
  }
  .right_column_blog {
    float: right;
    width: 100px;
    $category_css$;
  }
  .blog_entry_comments {
    float: left;
    width: 600px;
    position: relative;
  }
>>

(* Data *)

let anil = {
  Atom.name = "Anil Madhavapeddy";
  uri       = Some "http://anil.recoil.org";
  email     = Some "anil@recoil.org";
}
let thomas = {
  Atom.name = "Thomas Gazagnaire";
  uri       = Some "http://gazagnaire.org";
  email     = Some "thomas.gazagnaire@gmail.com";
}

let rights = Some "All rights reserved by the author"

let categories = [
  "overview", [
      "website"; "usage"; "papers"
  ];
  "language", [
      "syntax"; "dyntype"
  ];
  "backend", [
      "unix"; "xen"; "browser"; "arm"; "mips"
  ];
  "network", [
      "ethernet"; "dhcp"; "arp"; "tcpip"; "dns"; "http"; "typeropes"
  ];
  "storage", [
      "block"; "files"; "orm"
  ];
  "concurrency", [
      "threads"; "processes"
  ];
]

let entries = [
  { updated    = date (2010, 11, 13, 18, 10);
    author     = anil;
    subject    = "Developing the Mirage networking stack on UNIX";
    body       = "net-unix.md";
    permalink  = "running-ethernet-stack-on-unix";
    categories = ["overview","usage"; "backend","unix"];
  };

  { updated    = date (2010, 11, 10, 11, 0);
    author     = anil;
    subject    = "Source code layout";
    body       = "repo-layout.md";
    permalink  = "source-code-layout";
    categories = ["overview","usage"];
  };
  { 
    updated    = date (2010, 11, 4, 16, 30);
    author     = thomas;
    subject    = "A (quick) introduction to HTCaML";
    categories = ["language","syntax"];
    body       = "htcaml-part1.md";
    permalink  = "introduction-to-htcaml";
  };
  { updated    = date (2010, 10, 11, 15, 0);
    author     = anil;
    subject    = "Self-hosting Mirage website";
    body       = "blog-welcome.md";
    permalink  = "self-hosting-mirage-website";
    categories = ["overview","website"];
  };
]

let num = num_of_entries entries

let cmp_ent a b = Atom.compare (atom_date a.updated) (atom_date b.updated)

let entries = List.rev (List.sort cmp_ent entries)
let _ = List.iter (fun x -> Printf.printf "ENT: %s\n%!" x.subject) entries

let permalink e =
  sprintf "%s/blog/%s" Config.baseurl e.permalink

let permalink_exists x = List.exists (fun e -> e.permalink = x) entries

let atom_entry_of_ent filefn e =
  let meta = {
    Atom.id      = permalink e;
    title        = e.subject;
    subtitle     = None;
    author       = Some e.author;
    contributors = [];
    updated      = atom_date e.updated;
    rights;
  } in {
    Atom.entry = meta;
    summary    = None;
    content    = filefn e.body
  }
  
let atom_feed filefn es = 
  let es = List.rev (List.sort cmp_ent es) in
  let updated = atom_date (List.hd es).updated in
  let id = sprintf "%s/blog/" Config.baseurl in
  let title = "openmirage blog" in
  let subtitle = Some "a cloud operating system" in
  let author = Some anil in
  let contributors = [ anil; thomas ] in
  let feed = { Atom.id; title; subtitle; author; contributors; rights; updated } in
  let entries = List.map (atom_entry_of_ent filefn) es in
  { Atom.feed=feed; entries }

