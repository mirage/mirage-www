open Lwt
open Printf

let subst_re ~frm ~tos s =
  let rex = Str.regexp_string frm in
  Str.global_replace rex tos s
  
let subst_url =
  subst_re ~frm:"@@URL@@" ~tos:Config.baseurl

let subst_title tos =
  subst_re ~frm:"@@TITLE@@" ~tos

let subst_bar cur =
  prerr_endline cur;
  let bars = [ "/","Home"; "/blog/","Blog"; 
    "http://github.com/avsm/mirage", "Code";
    "/resources/","Resources"; "/about/","About" ] in
  let tos = String.concat "\n" (List.map (fun (href,title) ->
        sprintf "<li><a%s href=\"%s\">%s</a></li>"
          (if ("/"^cur)=href then " class=\"current_page\"" else "")
          href title
    ) bars) in
  subst_re ~frm:"@@BAR@@" ~tos

let subst url title body =
  subst_bar url (subst_title title (subst_url body))

let subst_file url filename title =
  match Filesystem_templates.t filename with
  |Some s -> subst url title s
  |None -> assert false

let t title body =
  let h = subst_file "" "header.inc" title in
  let f = subst_file "" "footer.inc" title in
  h ^ body ^ f

