open Lwt
open Cohttp
open Cow
open Cowabloga
open Syndic_atom


(*** Syndic and RSS feeds ***)

let string_of_text (t:text_construct) : string = match t with
  | Text(s) -> s
  | Html(_,s) -> s
  | Xhtml(_,xs) -> List.fold_left (fun acc x -> acc ^ Syndic_xml.to_string x) "" xs

(* given a feed as a string, try parsing it as Atom, then as RSS2 *)
let feed_of_string  (u : string) (s : string) : Syndic_atom.feed option =
  try
    Some (Syndic_atom.parse (Xmlm.make_input (`String(0, s))))
  with _ -> try
      let rss = Syndic_rss2.parse (Xmlm.make_input (`String(0, s))) in
      let atom = Syndic_rss2.to_atom rss in
      Some atom
    with _ ->
      Printf.fprintf stderr "Error parsing feed: %s\n" u;
      None

(* compare Syndic entries by date *)
let by_date (e1 : entry) (e2 : entry) : int =
  Syndic_date.compare e2.updated e1.updated


(*** HTML formatting ***)
type news_item = {
  title: string; 
  author:string; 
  date:int * string * int; 
  uri:string
}

(* extract data required to display a news item *)
let mk_news_item ((n: string), (e : entry)) : news_item =
  let date = e.updated in
  let title = string_of_text e.title in
  let uri = match e.links with
        [] -> ""
      | link :: _ -> Uri.to_string link.href
  in
  let open Syndic_date in
  let day = day date in
  let year = year date in
  let month = month date |> string_of_month in
  {title; author=n; date=(day, month, year); uri}


(* format a news item for news page *)
let news_page_item ((n: string), (e : entry)) =
  let {title; author; date=(day, month, year); uri} = mk_news_item (n,e) in
  let date = Printf.sprintf "%d %s %d" day month year in
  <:html<
      <div>
        <h4><a href="$str:uri$">$str:title$</a></h4>
        <p><i>$str:author$</i> <i class="front_date">($str:date$)</i></p>
      </div>
    <hr />&>>

(* format a news item for home page *)
let home_page_item ((n: string), (e : entry)) =
  let {title; date=(day, month, year); uri} = mk_news_item (n,e) in
  let date = Printf.sprintf "%d %s %d" day month year in
  <:html<
     <li><i class="fa-li fa fa-file-text-o"> </i>
     <a href=$str:uri$>$str:title$</a>
     <i class="front_date">($str:date$)</i></li>&>>


(* format a feed an HTML list item *)
let syndication_item (name, uri) =
  <:html<
   <li><a href="$str:uri$">$str:name$</a></li>
>>

(* format the news page as a list of entries and a list of feeds *)
let news_page feeds (es : (string * entry) list) =
  <:html<
    <div class="row">
      <div class="large-9 columns">
        <h2>News</h2>
      </div>
    </div>
    <div class="row">
       <div class="large-9 columns">
          <p>
             Here, we aggregate various blogs from the Mirage community.
             If you would like to be added, please
             <a href="/community/">get in touch</a>.
          </p>
          <br />
          $list:List.map news_page_item es$
       </div>
       <aside class="small-12 large-3 columns panel">
         <h5>Syndication</h5>
         <ul class="side-nav">
          $list:List.map syndication_item feeds$
         </ul>
       </aside>
    </div>
    >>

(* format the latest news as a list *)
let latest_news es =
  let ns = List.map (fun (n, e) -> home_page_item (n, e)) es in
  <:html< <ul class="fa-ul">$list:ns$</ul>&>>


(*** Feeds retrieval and processing ***)

(* return a list of named, Syndic entries, in chronological order *)
let named_entries feeds : (string * entry) list Lwt.t =
  let http_get (uri : string) : string Lwt.t =
    Cohttp_lwt_unix.Client.get (Uri.of_string uri) >>= fun (_, body) ->
    Cohttp_lwt_body.to_string body
  in
  let rec join = function [] -> [] | xs::xss -> xs @ join xss
  in
  Lwt_list.map_p (fun (n, u) ->
      http_get u >>= fun s -> return
      (match feed_of_string u s with
        Some(f) -> List.map (fun e -> (n, e)) f.entries
      | None -> [])
      ) feeds >>= fun ess ->
  let es = join ess in
  Lwt.return @@ List.sort (fun (_,e1) (_,e2) -> by_date e1 e2) es

(* write HTML news page *)
let write_news_page feeds (es : (string * entry) list) : unit Lwt.t =
  let html_page = news_page feeds es in
  let fname = "../tmpl/news.html" in
  Lwt_io.with_file
    Lwt_io.output fname (fun ch -> Lwt_io.fprint ch (Html.to_string html_page))

(* write a list of latest news for homepage *)
let write_latest_news es =
  let take n xs =
    let rec take_aux n xs acc =
      match (n, xs) with
        (n, _) when n <= 0 -> acc
      | (_, []) -> acc
      | (n, x::xs) -> take_aux (n-1) xs (x::acc)
    in List.rev (take_aux n xs [])
  in
  let latest_news = latest_news (take 10 es) in
  let fname = "../tmpl/latest_news.html" in
  Lwt_io.with_file
    Lwt_io.output fname (fun ch -> Lwt_io.fprint ch (Html.to_string latest_news))

let write_news feeds es =
  (write_news_page feeds es) <&> (write_latest_news es)
let _ =
  let feeds = List.sort (fun (n1,_) (n2,_) -> compare n1 n2) Feeds.feeds in
  Lwt_main.run (named_entries feeds >>= (write_news feeds))
