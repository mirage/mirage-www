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

(* {1 Link components} *)

let link_blue ~href children =
  a ~at:[ At.href href ] ~tw:[ text_blue; Tw.hover [ Tw.underline ] ] children

let link_orange ~href children =
  a
    ~at:[ At.href href ]
    ~tw:[ Tw.text dark_orange 500; Tw.hover [ Tw.underline ] ]
    children

let link_green ~href children =
  a
    ~at:[ At.href href ]
    ~tw:[ Tw.text dark_green 500; Tw.hover [ Tw.underline ] ]
    children

(* {1 People} *)

let person (p : Mirageio_data.People.t) =
  match p.uri with
  | Some uri -> to_string (link_blue ~href:uri [ txt p.name ])
  | None -> p.name

let people ps = String.concat ", " (List.map person ps)

(* {1 Page structure components} *)

let byline children = p ~tw:[ Tw.font_bold; text_grey; Tw.mt 2 ] children

let page_header ~title ?subtitle () =
  div
    ~tw:[ Tw.text_left; Tw.px 8; Tw.py 7 ]
    ([ h1 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt title ] ]
    @ match subtitle with Some s -> [ byline [ txt s ] ] | None -> [])

let separator () = hr ~tw:[ Tw.border_black ] ()

let prose_body content =
  div
    ~tw:[ Tw.p 8; Tw.mt 2; Tw.prose; Tw.prose_sm; Tw.max_w_full ]
    [ raw content ]

(* {1 Doc components} *)

let section_title label =
  div ~tw:[ Tw.text_lg; font_space; Tw.font_bold; Tw.mb 4 ] [ txt label ]

let doc_link ~href ~icon label =
  a
    ~at:[ At.href href ]
    ~tw:[ Tw.inline_block; text_blue; Tw.hover [ Tw.underline ] ]
    [
      span ~tw:[ Tw.inline_flex; Tw.w 5; Tw.justify_center ] [ txt icon ];
      txt (" " ^ label);
    ]

(* {1 Feature item} *)

let feature_item ~icon ~alt ~title desc =
  div
    ~tw:[ Tw.space_y 1 ]
    [
      div
        ~tw:[ Tw.flex; Tw.items_center; tw "space-x-[0.625rem]" ]
        [
          img ~at:[ At.src icon; At.alt alt ] ();
          div ~tw:[ Tw.font_bold; font_space; Tw.text_lg ] [ txt title ];
        ];
      p ~tw:[ text_grey; Tw.text_sm ] [ txt desc ];
    ]

(* {1 Buttons} *)

let btn_shadow =
  [
    tw "after:absolute";
    tw "after:w-full";
    tw "after:h-full";
    tw "after:content-['']";
    tw "after:border";
    tw "after:border-[#181818]";
    tw "after:top-[3px]";
    tw "after:left-[3px]";
    tw "after:blur-[1px]";
  ]

let btn_base =
  [
    Tw.relative;
    Tw.inline_flex;
    Tw.text_sm;
    font_inter;
    Tw.font_medium;
    Tw.group;
  ]
  @ btn_shadow

let btn_inner_base =
  [
    Tw.h 9;
    tw "px-3.5";
    Tw.flex;
    Tw.items_center;
    Tw.justify_center;
    Tw.border;
    Tw.border_color body_color 500;
    Tw.relative;
    Tw.transition_colors;
    Tw.space_x 2;
  ]

let btn ~href children =
  a
    ~at:[ At.href href ]
    ~tw:btn_base
    [
      div
        ~tw:
          (btn_inner_base
          @ [
              Tw.bg_white;
              tw "group-hover:bg-[#181818]";
              tw "group-hover:text-white";
            ])
        ~at:[ At.style "z-index: 1" ]
        children;
    ]

let btn_primary ~href children =
  a
    ~at:[ At.href href ]
    ~tw:btn_base
    [
      div
        ~tw:
          (btn_inner_base
          @ [
              bg_primary;
              Tw.text_white;
              tw "group-hover:bg-white";
              tw "group-hover:text-[#181818]";
            ])
        ~at:[ At.style "z-index: 1" ]
        children;
    ]
