open Tw_html

let title (item : Mirageio_data.Wiki.t) =
  Printf.sprintf "%s | MirageOS" item.subject

let description (item : Mirageio_data.Wiki.t) =
  Printf.sprintf "Read the documentation page on %s from our wiki." item.subject

let tab = Layout.Docs

let render (item : Mirageio_data.Wiki.t) =
  div
    [
      Theme.page_header ~title:item.subject
        ~subtitle:
          ("By " ^ Theme.person item.author ^ " \xe2\x80\x93 " ^ item.updated)
        ();
      Theme.separator ();
      Theme.prose_body item.body;
    ]
