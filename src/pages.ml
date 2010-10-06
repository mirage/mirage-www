(*pp camlp4o -I `ocamlfind query lwt.syntax` pa_lwt.cmo *)

open Printf
open Cohttp
open Log
open Lwt

let md_file f =
  let f = match Filesystem_templates.t f with |Some x -> x |None -> "" in
  let md = Markdown.parse_text f in
  Markdown_html.t md

let col_files l r = 
  "<div class=\"left_column\"><div class=\"summary_information\">"
  ^ (md_file l)
  ^ "</div></div>" 
  ^ "<div class=\"right_column\">"
  ^ (md_file r) 
  ^ "</div>"

module Index = struct
  let body = col_files "intro.md" "ne.md"
  let t = Template.t "index" body
end

module Resources = struct
  let body = col_files "docs.md" "papers.md"
  let t = Template.t "index" body
end 

module About = struct
  let body = col_files "status.md" "ne.md"
  let t = Template.t "index" body
end
