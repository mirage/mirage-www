open Tw_html

let title = "MirageOS Blog"
let description = "Read our latest news and announcements from MirageOS Blog."
let tab = Layout.Blog
let posts_per_page = 8

let post_preview (item : Mirageio_data.Blog.t) =
  div
    ~tw:[ Tw.px 8; Tw.py 6; Tw.border_b; Tw.border_black ]
    [
      a
        ~at:[ At.href ("/blog/" ^ item.permalink) ]
        ~tw:[ Tw.text_lg; Tw.font_bold; Tw.block; Tw.hover [ Tw.underline ] ]
        [ txt item.subject ];
      div
        ~tw:[ Tw.text_sm; Tw.mt 1; Theme.text_grey ]
        [
          txt "By ";
          raw (Theme.people item.authors);
          txt " \xe2\x80\x93 ";
          txt (Util.date_to_string item.updated);
        ];
      div
        ~tw:[ Tw.relative; Tw.mt 3; Tw.max_h 40; Tw.overflow_hidden ]
        [
          div ~tw:[ Tw.prose; Tw.prose_sm ] [ raw item.body ];
          div
            ~tw:[ Tw.absolute; Tw.bottom 0; Tw.left 0; Tw.right 0; Tw.h 20 ]
            ~at:[ At.style "background: linear-gradient(transparent, white)" ]
            [];
        ];
      a
        ~at:[ At.href ("/blog/" ^ item.permalink) ]
        ~tw:
          [
            Theme.text_blue;
            Tw.hover [ Tw.underline ];
            Tw.mt 3;
            Tw.inline_block;
            Tw.font_medium;
          ]
        [ txt "-> Read more" ];
    ]

let page_link ~href ~active label =
  if active then
    span ~tw:[ Theme.bg_primary; Tw.text_white; Tw.px 3; Tw.py 1 ] [ txt label ]
  else
    a
      ~at:[ At.href href ]
      ~tw:
        [
          Tw.border;
          Tw.border_black;
          Tw.px 3;
          Tw.py 1;
          Tw.hover [ Theme.bg_primary; Tw.text_white ];
          Tw.transition_colors;
        ]
      [ txt label ]

let page_href n = if n = 1 then "/blog" else Printf.sprintf "/blog/page/%d" n

let pagination ~current_page ~total_pages =
  if total_pages <= 1 then div []
  else
    let arrow ~href ~enabled label =
      if enabled then
        a
          ~at:[ At.href href ]
          ~tw:
            [
              Theme.text_blue;
              Tw.hover [ Tw.underline ];
              Tw.font_medium;
              Tw.px 2;
            ]
          [ txt label ]
      else
        span
          ~tw:[ Theme.text_grey; Theme.tw "opacity-30"; Tw.px 2 ]
          [ txt label ]
    in
    let page_num n =
      if n = current_page then
        span
          ~tw:
            [
              Theme.bg_primary;
              Tw.text_white;
              Tw.px 3;
              Tw.py 1;
              Tw.text_sm;
              Theme.font_space;
            ]
          [ txt (string_of_int n) ]
      else
        a
          ~at:[ At.href (page_href n) ]
          ~tw:
            [
              Tw.border;
              Tw.border_black;
              Tw.px 3;
              Tw.py 1;
              Tw.text_sm;
              Theme.font_space;
              Tw.hover [ Theme.bg_primary; Tw.text_white ];
              Tw.transition_colors;
            ]
          [ txt (string_of_int n) ]
    in
    div
      ~tw:
        [
          Tw.flex;
          Tw.items_center;
          Tw.justify_center;
          Tw.gap 1;
          Tw.px 8;
          Tw.py 6;
        ]
      ([
         arrow
           ~href:(page_href (current_page - 1))
           ~enabled:(current_page > 1) "\xe2\x86\x90";
       ]
      @ List.init total_pages (fun i -> page_num (i + 1))
      @ [
          arrow
            ~href:(page_href (current_page + 1))
            ~enabled:(current_page < total_pages)
            "\xe2\x86\x92";
        ])

let render ~posts ~current_page ~total_pages =
  div
    [
      Theme.page_header ~title:"The MirageOS Blog"
        ~subtitle:"on building functional operating systems" ();
      Theme.separator ();
      div ~tw:[ Tw.flex_1 ] (List.map post_preview posts);
      pagination ~current_page ~total_pages;
    ]
