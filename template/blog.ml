open Tw_html

let title = "MirageOS Blog"
let description = "Read our latest news..."
let tab = Layout.Blog

let render ~latest ~recent =
  div
    [
      div
        ~tw:[ Tw.text_left; Tw.px 8; Tw.py 7 ]
        [
          h1 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt "The MirageOS Blog" ];
          p
            ~tw:[ Tw.font_bold; Theme.text_grey; Tw.mt 2 ]
            [ txt "on building functional operating systems" ];
        ];
      hr ~tw:[ Tw.border_black ] ();
      div
        ~tw:[ Tw.flex; Tw.flex_col; Tw.lg [ Tw.flex_row ] ]
        [
          div ~tw:[ Tw.flex_1 ]
            (List.map
               (fun (item : Mirageio_data.Blog.t) ->
                 div
                   ~tw:[ Tw.px 8; Tw.py 6; Tw.border_b; Tw.border_black ]
                   [
                     div ~tw:[ Tw.text_lg; Tw.font_bold ] [ txt item.subject ];
                     div ~tw:[ Tw.text_sm; Tw.mt 2 ]
                       [
                         txt "By ";
                         raw (Theme.people item.authors);
                         txt " - ";
                         span ~tw:[ Theme.text_grey ]
                           [ txt (Util.date_to_string item.updated) ];
                       ];
                     div
                       ~tw:
                         [
                           Tw.mt 2;
                           Tw.prose;
                           Tw.prose_sm;
                           Tw.max_h 72;
                           Tw.text_ellipsis;
                           Tw.overflow_hidden;
                         ]
                       [ raw item.body ];
                     div ~tw:[ Tw.mt 2 ]
                       [
                         Theme.link_blue
                           ~href:("/blog/" ^ item.permalink)
                           [ txt "-> Read more" ];
                       ];
                   ])
               latest);
          div
            ~tw:
              [
                Theme.bg_primary;
                Tw.w_full;
                Tw.lg [ Theme.w_1_3 ];
              ]
            [
              div ~tw:[ Tw.px 5; Tw.py 6 ]
                [
                  div
                    ~tw:
                      [
                        Tw.text_lg;
                        Tw.text_white;
                        Theme.font_space;
                        Tw.mb 3;
                      ]
                    [ txt "Recent Posts" ];
                  div
                    ~tw:[ Tw.space_y 2; Tw.italic ]
                    (List.map
                       (fun (item : Mirageio_data.Blog.t) ->
                         div
                           ~tw:[ Tw.items_center; Tw.space_x 2 ]
                           [
                             img
                               ~tw:[ Tw.inline ]
                               ~at:
                                 [
                                   At.src "/icon/speech-bubble.svg";
                                   At.alt "Speech Bubble Icon";
                                 ]
                               ();
                             Theme.link_blue
                               ~href:("/blog/" ^ item.permalink)
                               [ txt (" " ^ item.subject ^ " ") ];
                           ])
                       recent);
                ];
            ];
        ];
    ]
