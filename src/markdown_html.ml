open Printf
open Markdown

let tag t x = sprintf "<%s>%s</%s>" t x t

let tags t l = String.concat "\n" (List.map (tag t) l)

let rec text = function
    Text t -> t
  | Emph t -> tag "i" t
  | Bold t -> tag "b" t
  | Struck pt -> tag "del" (par_text pt)
  | Code t -> tag "code" t
  | Link href -> sprintf "<a href=\"%s\">%s</a>" href.href_target href.href_desc
  | Anchor a -> sprintf "<a name=\"%s\" />" a
  | Image img -> sprintf "<img src=\"%s\" alt=\"%s\" />" img.img_src img.img_alt

and para = function
    Normal pt -> par_text pt
  | Pre (t,kind) -> tag "pre" (tag "code" t)
  | Heading (lvl,pt) -> tag ("h" ^ (string_of_int lvl)) (par_text pt)
  | Quote pl ->  tag "blockquote" (paras pl)
  | Ulist (pl,pll) -> tag "ul" (tags "li" (List.map paras (pl::pll)))
  | Olist (pl,pll) -> tag "ol" (tags "li" (List.map paras (pl::pll)))

and par_text pt = String.concat "" (List.map text pt)

and paras ps = tags "p" (List.map para ps)

and t pl =
  String.concat "\n" (List.map (fun p -> sprintf "<p>%s</p>" (para p)) pl)
