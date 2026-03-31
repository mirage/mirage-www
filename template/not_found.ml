open Tw_html

let title = "Page not Found | MirageOS"
let description = "This page does not exist."
let tab = Layout.Home

let render () =
  main
    ~tw:
      [
        Tw.min_h_full;
        Theme.tw "bg-cover";
        Theme.tw "bg-top";
        Tw.sm [ Theme.tw "bg-top" ];
      ]
    [
      div
        ~tw:
          [
            Tw.max_w_7xl;
            Tw.mx_auto;
            Tw.px 4;
            Tw.py 16;
            Tw.text_center;
            Tw.sm [ Tw.px 6; Tw.py 24 ];
            Tw.lg [ Tw.px 8; Tw.py 48 ];
          ]
        [
          p
            ~tw:
              [
                Tw.text_sm;
                Tw.font_semibold;
                Theme.text_blue;
                Tw.uppercase;
                Tw.tracking_wide;
              ]
            [ txt "404 error" ];
          h1
            ~tw:
              [
                Tw.mt 2;
                Tw.text_4xl;
                Tw.font_extrabold;
                Tw.text_black;
                Tw.tracking_tight;
                Tw.sm [ Tw.text_5xl ];
              ]
            [ txt "Uh oh! I think you're lost." ];
          p
            ~tw:
              [ Tw.mt 2; Tw.text_lg; Tw.font_medium; Theme.tw "text-black/50" ]
            [ txt "It looks like the page you're looking for doesn't exist." ];
          div
            ~tw:[ Tw.mt 6 ]
            [ Theme.btn ~href:"/" [ span [ txt "Go back home" ] ] ];
        ];
    ]
