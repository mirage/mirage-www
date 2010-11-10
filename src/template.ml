open Lwt
open Printf

let subst_re ~frm ~tos s =
  let rex = Str.regexp_string frm in
  Str.global_replace rex tos s
  
let subst_url =
  subst_re ~frm:"@@URL@@" ~tos:Config.baseurl

let subst_title tos =
  subst_re ~frm:"@@TITLE@@" ~tos

let subst_head tos =
  subst_re ~frm:"@@EXTRA_HEAD@@" ~tos

let subst_bar cur =
  let bars = [ "/","Home"; "/blog/","Blog"; 
    "http://github.com/avsm/mirage", "Code";
    "/resources/","Resources"; "/about/","About" ] in
  let tos = String.concat "\n" (List.map (fun (href,title) ->
        sprintf "<li><a%s href=\"%s\">%s</a></li>"
          (if title=cur then " class=\"current_page\"" else "")
          href title
    ) bars) in
  subst_re ~frm:"@@BAR@@" ~tos

let subst headers url title body =
  subst_bar url (subst_head headers (subst_title title (subst_url body)))

let subst_file headers url filename title =
  match Filesystem_templates.t filename with
  |Some s -> subst headers url title s
  |None -> assert false

let t ?(headers="") page title body =
  let h = subst_file headers page "header.inc" title in
  let f = subst_file headers page "footer.inc" title in
  h ^ body ^ f

