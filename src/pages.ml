(*pp camlp4o -I `ocamlfind query lwt.syntax` pa_lwt.cmo *)

open Printf
open Cohttp
open Log
open Lwt

let md_file f =
  let f = match Filesystem_templates.t f with |Some x -> x |None -> "" in
  let t = Str.split (Str.regexp_string "\n") f in
  let md = Markdown.parse_lines t in
  Markdown_html.t md

module Index = struct

  let body = 
     let intro = md_file "intro.md" in 
     (
       "<div class=\"left_column\"><div class=\"summary_information\">"
       ^ intro
       ^ "</div></div>")

 let t =
    let b = body in
    Template.t "index" b
end

module Code = struct
  let code = 
     let intro = md_file "arch.md" in 
     (
       "<div class=\"left_column\"><div class=\"summary_information\">"
       ^ intro
       ^ "</div></div>")
  let t = 
     let b = code in
     Template.t "index" b
end 
