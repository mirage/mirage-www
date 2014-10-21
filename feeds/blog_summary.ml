(* ocamlfind ocamlopt -package lwt -package cohttp -package cohttp.lwt -package xmlm -package syndic -linkpkg test.ml -o test *)

(* open Lwt 
open Cohttp
open Cohttp_lwt_unix
*)
open Cohttp
open Lwt
open Cow
open Syndic_atom

let (>>=) = Lwt.bind


(* change name to list_of_feeds *)
let list_of_feeds (file : string) : (string * string) list =
  let ic = open_in file in 
  let assoc = ref [] in
  (try
    while true do
      let line = input_line ic in
      let p = Str.split_delim (Str.regexp "|") line in
      assert (List.length p = 2);
      let [n;u] = p in
      assoc := (n,u) :: !assoc
    done
  with End_of_file -> ());
  !assoc


let get (uri_str : string) : string Lwt.t = 
  Cohttp_lwt_unix.Client.get (Uri.of_string uri_str) >>= fun (_, body) -> 
  Cohttp_lwt_body.to_string body

let string_of_text (t:text_construct) : string = match t with
  | Text(s) -> s
  | Html(s) -> s
  | Xhtml(xs) -> List.fold_left (fun acc x -> acc ^ Syndic_xml.to_string x) "" xs
    

(* parsing the XML feeds *)
exception Invalid_feed of string

let parse_feed  (u : string) (s : string) : Syndic_atom.feed = 
  let str : Xmlm.source = `String(0, s) in
  let inp = Xmlm.make_input str in
  (* try *)
  Syndic_atom.parse inp
  (* with _ ->
    try
       Syndic_rss2.to_atom (Syndic_rss2.parse inp)
  *)
  (* with _ -> raise (Invalid_feed u) *)
    
(*    
let parse_atom (s : string) : feed = 
  let str : Xmlm.source = `String(0, s) in
  Syndic_atom.parse (Xmlm.make_input str)
*)

let rec join = function
    []    -> []
  | xs::xss -> xs @ join xss

let by_date (e1 : entry) (e2 : entry) : int =  (* TODO -- published = CalendarLib.Calendar.t *) 
  CalendarLib.Calendar.compare e2.updated e1.updated

let take n xs =
  let rec take_aux n xs acc =
    match (n, xs) with
      (n, _) when n <= 0 -> acc
    | (_, []) -> acc 
    | (n, x::xs) -> take_aux (n-1) xs (x::acc)
  in List.rev (take_aux n xs [])

let rec drop n xs =
    match (n, xs) with
      (n, xs) when n <= 0 -> xs
    | (_, []) -> []
    | (n, x::xs) -> drop (n-1) xs

let rec paginate (n : int) (xs : 'a list) : 'a list list =
  if n < 1 then invalid_arg "paginate";
  match xs with
    [] -> []
  | xs ->  take n xs :: paginate n (drop n xs)


(* Using an ordered set of entries *)
(*
module S = Set.Make(struct type t = Syndic_atom.entry let compare (e1:t) (e2:t) = CalendarLib.Calendar.compare e1.updated e2.updated end);;
*)



let paginated_entries items_per_page : entry list list Lwt.t =
  let l = list_of_feeds "atom_feeds.txt" in
  Lwt_list.map_p (fun (_n, u) -> (* let's not bother about names just yet *)
      get u >>= fun s -> 
      let f = parse_feed u s in 
      Lwt.return (f.entries)) l >>= fun ess ->
  let jess = join ess in
  let sess = List.sort by_date jess in
  let pess = paginate items_per_page sess in
  Lwt.return pess

(* Lwt.return @@ paginate 10 (List.sort by_date (join ess)) *)




(* 
 <:html< $list:List.map items li_of_item$ &>>

<h3>
     <a href="$str:e.link">$title$</a>
     <span class="date">$date$</span>
  </h3>

type text_construct =
  | Text of string
  | Html of string
  | Xhtml of Syndic_xml.t list


type content =
  | Text of string
  | Html of string
  | Xhtml of Syndic_xml.t list
  | Mime of mime * string
  | Src of mime option * Uri.t

*)

let string_of_content = function
 | Text s -> s
 | Html s -> s
 | Xhtml _ -> "" 
 | Mime _ -> ""
 | Src _ -> ""


let news_item (e : entry) = 
    let date = Html.of_string 
        (CalendarLib.Printer.Calendar.to_string e.updated) in 
    let title = Html.of_string (string_of_text e.title) in
    (*
    let content = 
      try Html.of_string (string_of_content (
          match e.content with
            None -> Text ""
          | Some (Mime _) | Some (Xhtml _) 
          | Some (Src _) -> Text "no content"  
          | Some c -> c)
      )
      with _ -> <:html< <p>No content</p> >>
    in
    *)
    let uri = match e.links with
        [] -> ""
      | link :: _ -> Uri.to_string link.href
    in
    <:html<
    <h3>
      <a href="$str:uri$">$title$</a>
      <span class="date">$date$</span>
    </h3>
    <hr />
>>

let news_href n = "news" ^ (string_of_int n) ^ ".html"
  

let pagination (n : int) (total : int) =  
  let older_uri = news_href (n+1) in
  let newer_uri = news_href (n-1) in
  let older = <:html< <a href="$str:older_uri$">Older</a> >> in
  let newer = <:html< <a href="$str:newer_uri$">Newer</a> >> in
  match n with
    0 ->                <:html< $older$ >>
  | n when n = total-1 -> <:html< $newer$ >>
  | _ ->                <:html< $newer$ $older$ >>
 

let news_page (n : int) (total: int) (es : entry list) = 

  <:html<
      <div class="row">
        <div class="small-12 medium-9 large-6 columns">
          <h2>News Feed</h2>
          <p>
              Here, we aggregate various blogs from the Mirage community. If you would like to be added, please send us an email.
          </p>
          <br />
          $list:List.map news_item es$
        </div>
        <p id="pagination">$pagination n total$</p>
      </div>
    >> 


let write_news_page (total :int) (n : int) (es : entry list) : unit Lwt.t =
  let page = news_page n total es in
  let fname = news_href n in
  Lwt_io.with_file 
    Lwt_io.output fname (fun ch -> Lwt_io.fprint ch (Html.to_string page))



let write_news (ess : entry list list) : unit Lwt.t =
  Lwt_list.iteri_p (write_news_page (List.length ess)) ess

let _ =
  (* Lwt_main.run print_titles  *)
  Lwt_main.run (paginated_entries 10 >>= write_news)
