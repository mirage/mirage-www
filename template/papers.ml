open Tw_html

let title = "MirageOS Papers"

let description =
  "Discover research papers and articles on MirageOS and related projects."

let tab = Layout.Docs

let render (papers : Mirageio_data.Paper.t list) =
  div
    [
      Theme.page_header ~title:"MirageOS Papers"
        ~subtitle:"and research articles" ();
      Theme.separator ();
      (* Table *)
      div
        ~tw:[ Tw.p 8 ]
        [
          table
            ~tw:[ Tw.max_w_5xl; Tw.lg [ Tw.max_w_full ]; Theme.tw "align-top" ]
            [
              thead
                ~tw:
                  [
                    Theme.bg_primary; Tw.text_white; Tw.text_left; Tw.rounded_xl;
                  ]
                [
                  tr
                    [
                      th
                        ~tw:
                          [
                            Tw.py 4;
                            Tw.px 6;
                            Tw.rounded_l_lg;
                            Tw.text_xs;
                            Theme.w_2_5;
                          ]
                        [ txt "Title" ];
                      th ~tw:[ Tw.py 4; Tw.px 6; Tw.w 56 ] [ txt "Authors" ];
                      th
                        ~tw:[ Tw.py 4; Tw.px 6; Tw.rounded_r_lg ]
                        [ txt "Links" ];
                    ];
                ];
              tbody
                (List.map
                   (fun (paper : Mirageio_data.Paper.t) ->
                     tr
                       [
                         td
                           ~tw:[ Tw.py 4; Tw.px 6; Tw.font_semibold ]
                           [
                             div ~tw:[ Tw.font_semibold ] [ txt paper.title ];
                             div
                               ~tw:
                                 [
                                   Tw.font_normal;
                                   Tw.text_sm;
                                   Tw.mt 2;
                                   Theme.tw "text-gray-400";
                                 ]
                               [ txt paper.abstract ];
                           ];
                         td
                           ~at:[ At.style "vertical-align: top" ]
                           ~tw:[ Tw.py 4; Tw.px 6; Tw.font_medium ]
                           [ txt (String.concat ", " paper.authors) ];
                         td
                           ~at:[ At.style "vertical-align: top" ]
                           ~tw:[ Tw.py 4; Tw.px 6 ]
                           (List.map
                              (fun (link : Mirageio_data.Paper.link) ->
                                a
                                  ~at:[ At.href link.uri ]
                                  ~tw:
                                    [
                                      Theme.text_blue;
                                      Tw.hover [ Tw.underline ];
                                      Tw.font_medium;
                                      Tw.block;
                                      Tw.whitespace_nowrap;
                                    ]
                                  [ txt link.description ])
                              paper.links);
                       ])
                   papers);
            ];
        ];
    ]
