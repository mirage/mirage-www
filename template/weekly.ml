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
      Theme.page_header ~title:"The MirageOS Documentation"
        ~subtitle:"and developer guides" ();
      Theme.separator ();
      div
        ~tw:[ Tw.p 8 ]
        [
          div ~tw:[ Tw.text_lg; Tw.font_bold ] [ txt item.subject ];
          Theme.byline
            [
              txt "By ";
              raw (Theme.person item.author);
              txt " \xe2\x80\x93 ";
              span ~tw:[ Theme.text_grey ] [ txt item.updated ];
            ];
          div
            ~tw:[ Tw.mt 2; Tw.prose; Tw.prose_sm; Tw.max_w_full ]
            [ raw item.body ];
        ];
    ]
