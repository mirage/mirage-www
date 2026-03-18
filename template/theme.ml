(* Theme — MirageOS design system built on Tw + Tw_html.

   Defines brand colors, typography, and reusable UI components. *)

open Tw_html

let tw s = match Tw.of_string s with Ok t -> t | Error (`Msg e) -> failwith e

(* {1 Brand colors} *)

let primary = Tw.hex "#181818"
let blue = Tw.hex "#4DB1B8"
let grey = Tw.hex "#7B7B7B"
let dark_grey = Tw.hex "#4D4D4D"
let body_color = Tw.hex "#333333"
let dark_orange = Tw.hex "#EB7F00"
let dark_green = Tw.hex "#17819A"
let orange = Tw.hex "#FF9800"
let green = Tw.hex "#AFE0D5"
let cyan = Tw.hex "#C5F0FB"

(* {1 Typography} *)

let font_inter = tw {|font-["Inter"]|}
let font_space = tw {|font-["Space_Grotesk"]|}

(* {1 Common styles} *)

let text_grey = Tw.text grey 500
let text_dark_grey = Tw.text dark_grey 500
let text_body = Tw.text body_color 500
let text_blue = Tw.text blue 500
let bg_primary = Tw.bg primary 500
let bg_cyan = Tw.bg cyan 500
let bg_green = Tw.bg green 500
let bg_orange = Tw.bg orange 500

(* Fractional widths *)
let w_1_2 = tw "w-1/2"
let w_1_3 = tw "w-1/3"
let w_2_3 = tw "w-2/3"
let w_2_5 = tw "w-2/5"
let w_4_5 = tw "w-4/5"

(* Divide *)
let divide_y = tw "divide-y"
let divide_x = tw "divide-x"
let divide_y_0 = tw "divide-y-0"
let divide_black = tw "divide-black"

(* {1 Components} *)

(** Styled link with brand blue color and hover underline. *)
let link_blue ~href children =
  a ~at:[ At.href href ] ~tw:[ text_blue; Tw.hover [ Tw.underline ] ] children

(** Styled link with dark orange color and hover underline. *)
let link_orange ~href children =
  a
    ~at:[ At.href href ]
    ~tw:[ Tw.text dark_orange 500; Tw.hover [ Tw.underline ] ]
    children

(** Styled link with dark green color and hover underline. *)
let link_green ~href children =
  a
    ~at:[ At.href href ]
    ~tw:[ Tw.text dark_green 500; Tw.hover [ Tw.underline ] ]
    children

(** Render a person as an HTML string (for embedding in raw HTML contexts). *)
let person (p : Mirageio_data.People.t) =
  match p.uri with
  | Some uri -> to_string (link_blue ~href:uri [ txt p.name ])
  | None -> p.name

(** Render a list of people as a comma-separated HTML string. *)
let people ps = String.concat ", " (List.map person ps)

(** Page subtitle line with grey author/date info. *)
let byline children =
  p ~tw:[ Tw.font_bold; text_grey; Tw.mt 2 ] children

(** Standard page header: title + optional subtitle. *)
let page_header ~title ?subtitle () =
  div ~tw:[ Tw.text_left; Tw.px 8; Tw.py 7 ]
    ([ h1 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt title ] ]
    @ (match subtitle with
      | Some s -> [ p ~tw:[ Tw.font_bold; text_grey; Tw.mt 2 ] [ txt s ] ]
      | None -> []))

(** Horizontal rule in brand style. *)
let separator () = hr ~tw:[ Tw.border_black ] ()

(** Prose content area for rendered markdown. *)
let prose_body content =
  div ~tw:[ Tw.p 8; Tw.mt 2; Tw.prose; Tw.prose_sm; Tw.max_w_full ]
    [ raw content ]

(** Section title used in docs grid. *)
let section_title label =
  div ~tw:[ Tw.text_lg; font_space; Tw.font_bold; Tw.mb 4 ] [ txt label ]

(** Doc link with emoji icon prefix. *)
let doc_link ~href ~icon label =
  a ~at:[ At.href href ] ~tw:[ Tw.inline_block; text_blue; Tw.hover [ Tw.underline ] ]
    [ span ~tw:[ Tw.inline_flex; Tw.w 5; Tw.justify_center ] [ txt icon ];
      txt (" " ^ label) ]

(** Homepage feature item (icon + title + description). *)
let feature_item ~icon ~title desc =
  div ~tw:[ Tw.space_y 1 ]
    [ div ~tw:[ Tw.flex; Tw.items_center; tw "space-x-[0.625rem]" ]
        [ img ~at:[ At.src icon; At.alt (title ^ " Icon") ] ();
          div ~tw:[ Tw.font_bold; font_space; Tw.text_lg ] [ txt title ] ];
      p ~tw:[ text_grey; Tw.text_sm ] [ txt desc ] ]

(** Standard button. *)
let btn ~href children =
  a ~at:[ At.href href ]
    ~tw:[ Tw.relative; Tw.inline_flex; Tw.text_sm; font_inter; Tw.font_medium ]
    [ div
        ~tw:[ Tw.h 9; tw "px-3.5"; Tw.flex; Tw.items_center; Tw.gap 2;
              Tw.border_black; Tw.rounded_lg; Tw.border ]
        children ]

(** Primary (dark) button. *)
let btn_primary ~href children =
  a ~at:[ At.href href ]
    ~tw:[ Tw.relative; Tw.inline_flex; Tw.text_sm; font_inter; Tw.font_medium ]
    [ div
        ~tw:[ Tw.h 9; tw "px-3.5"; Tw.flex; Tw.items_center; Tw.gap 2;
              Tw.rounded_lg; bg_primary; Tw.text_white;
              Tw.hover [ Tw.bg_white; Tw.text primary 500 ];
              Tw.border; Tw.border_black ]
        children ]
