open Tw_html

let title (item : Mirageio_data.Blog.t) =
  Printf.sprintf "%s | MirageOS" item.subject

let description (item : Mirageio_data.Blog.t) =
  Printf.sprintf "Read the post on \"%s\" from our blog." item.subject

let tab = Layout.Blog

let render (item : Mirageio_data.Blog.t) =
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
              raw (Theme.people item.authors);
              txt (" - " ^ Util.date_to_string item.updated);
            ];
        ];
      hr ~tw:[ Tw.border_black ] ();
      div
        ~tw:[ Tw.p 8; Tw.mt 2; Tw.prose; Tw.prose_sm; Tw.max_w_full ]
        [ raw item.body ];
    ]
