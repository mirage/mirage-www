open Tw_html

let title (item : Mirageio_data.Weekly.t) =
  Printf.sprintf "%s | MirageOS" item.subject

let description (item : Mirageio_data.Weekly.t) =
  Printf.sprintf "Read the notes for the MirageOS developer meeting from %s"
    item.description

let tab = Layout.Docs

let render (item : Mirageio_data.Weekly.t) =
  div
    [
      div
        ~tw:[ Tw.text_left; Tw.px 8; Tw.py 7 ]
        [
          h1 ~tw:[ Tw.text_3xl; Tw.font_bold ]
            [ txt "The MirageOS Documentation" ];
          p
            ~tw:[ Tw.font_bold; Theme.text_grey; Tw.mt 2 ]
            [ txt "and developer guides" ];
        ];
      hr ~tw:[ Tw.border_black ] ();
      div ~tw:[ Tw.p 8 ]
        [
          div ~tw:[ Tw.text_lg; Tw.font_bold ] [ txt item.subject ];
          div ~tw:[ Tw.text_sm; Tw.mt 2 ]
            [
              txt "By ";
              raw (Theme.person item.author);
              txt " - ";
              span ~tw:[ Theme.text_grey ] [ txt item.updated ];
            ];
          div
            ~tw:[ Tw.mt 2; Tw.prose; Tw.prose_sm; Tw.max_w_full ]
            [ raw item.body ];
        ];
    ]
