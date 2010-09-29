open Lwt

let subst_re ~frm ~tos s =
  let rex = Str.regexp_string frm in
  Str.global_replace rex tos s
  
let subst_url =
  subst_re ~frm:"@@URL@@" ~tos:Config.baseurl

let subst_title tos =
  subst_re ~frm:"@@TITLE@@" ~tos

let subst_content tos = 
  subst_re ~frm:"@@CONTENT@@" ~tos

let subst t body s =
  subst_title t (subst_url (subst_content body s))

let subst_file filename title body =
  match Filesystem_templates.t filename with
  |Some s -> subst title body s
  |None -> assert false

let index =
  subst_file Config.index

let t title body =
  index title body
