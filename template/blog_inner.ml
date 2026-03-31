open Tw_html

let title (item : Mirageio_data.Blog.t) =
  Printf.sprintf "%s | MirageOS" item.subject

let description (item : Mirageio_data.Blog.t) =
  Printf.sprintf "Read the post on \"%s\" from our blog." item.subject

let tab = Layout.Blog

let render (item : Mirageio_data.Blog.t) =
  div
    [
      Theme.page_header ~title:item.subject
        ~subtitle:
          ("By " ^ Theme.people item.authors ^ " \xe2\x80\x93 "
          ^ Util.date_to_string item.updated)
        ();
      Theme.separator ();
      Theme.prose_body item.body;
    ]
