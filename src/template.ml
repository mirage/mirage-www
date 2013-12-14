open Printf
open Cow
open Lwt

let bar cur =
  let bars = [
    "/","Home";
    "/blog/","Blog";
    "/wiki/","Wiki";
    "http://github.com/mirage/", "Code";
    "/about/","About"
  ] in
  let one (href, title) =
    if title=cur then
      <:xml<
        <li><a class="current_page" href=$str:href$>$str:title$</a></li>
      >>
    else
      <:xml<
        <li><a href=$str:href$>$str:title$</a></li>
      >> in
  <:xml< <ul>$list:List.map one bars$</ul> >>

let replace (templates: (Re_str.regexp * Xml.t) list) (xml:Xml.t) =
  let rec aux = function
    | `El (t, xs)    -> [`El (t, List.flatten (List.map aux xs))]
    | `Data _ as x ->
      (* Replace one of the templates: *)
      let rec one (regexp, xml) x : Xml.t = match x with
        | `Data str ->
          let bits = Re_str.full_split regexp str in
          List.flatten (List.map (function
              | Re_str.Text x -> [ `Data x ]
              | Re_str.Delim _ -> xml
            ) bits)
        | `El (_, _) as x -> [ x ] in
      List.fold_left (fun acc transform ->
          List.flatten (List.map (one transform) acc)
        ) [ x ] templates in
  List.flatten (List.map aux xml)

let _title         = Re_str.regexp_string "$TITLE$"
let _bar           = Re_str.regexp_string "$BAR$"
let _extra_headers = Re_str.regexp_string "$EXTRA_HEADER$"
let _contents      = Re_str.regexp_string "$CONTENT$"

let t ?extra_header tmpl_read page title content =
  lwt content = content in
  tmpl_read "/main.html"
  >>= fun main_html ->
    let templates = [
      _title         , <:xml<$str:title$>>;
      _bar           , <:xml<$bar page$>>;
      _extra_headers , <:xml<$opt:extra_header$>>;
      _contents      , <:xml<$content$>>;
    ] in
    Html.of_string main_html
    |> replace templates
    |> return
