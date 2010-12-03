open Printf
open Cow

let bar cur =
  let bars = [
    "/","Home";
    "/blog/","Blog"; 
    "http://github.com/avsm/mirage", "Code";
    "/resources/","Resources";
    "/about/","About"
  ] in
  let one (href, title) =
    if title=cur then
      <:html<
        <li class="current_page">
          <a href=$str:href$>$str:title$</a>
        </li>
      >>
    else
      <:html<
        <li><a href=$str:href$>$str:title$</a></li>
      >> in
  <:html< <ul>$list:List.map one bars$</ul> >>

let t ?(extra_header : Html.t = []) title page content =
  let main_html = Filesystem_templates.t "main.html" in
  <:html< $raw:main_html$ >>


