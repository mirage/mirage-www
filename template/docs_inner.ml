open Tw_html

let title (item : Mirageio_data.Wiki.t) =
  Printf.sprintf "%s | MirageOS" item.subject

let description (item : Mirageio_data.Wiki.t) =
  Printf.sprintf "Read the documentation page on %s from our wiki." item.subject

let tab = Layout.Docs

let render (item : Mirageio_data.Wiki.t) =
  div
    [
      div
        ~tw:[ Tw.text_left; Tw.px 8; Tw.py 7 ]
        [
          h1 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt item.subject ];
          p
            ~tw:[ Tw.font_bold; Theme.text_grey; Tw.mt 2 ]
            [
              txt "By ";
              raw (Theme.person item.author);
              txt (" - " ^ item.updated);
            ];
        ];
      hr ~tw:[ Tw.border_black ] ();
      div
        ~tw:[ Tw.p 8; Tw.mt 2; Tw.prose; Tw.prose_sm; Tw.max_w_full ]
        [ raw item.body ];
    ]
