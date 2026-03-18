(* gen_site.ml -- Build-time static site generator for mirageos.org

   Renders all pages to HTML, generates CSS from collected Tw utilities,
   generates the Atom feed, and copies static assets.

   Usage: gen_site <output-dir> *)

open Mirageio_template

let take n lst =
  let rec aux acc n = function
    | [] -> List.rev acc
    | _ when n <= 0 -> List.rev acc
    | x :: xs -> aux (x :: acc) (n - 1) xs
  in
  aux [] n lst

let write_file path content =
  let dir = Filename.dirname path in
  let rec mkdir_p d =
    if Sys.file_exists d then ()
    else (
      mkdir_p (Filename.dirname d);
      try Sys.mkdir d 0o755 with Sys_error _ -> ())
  in
  mkdir_p dir;
  let oc = open_out path in
  output_string oc content;
  close_out oc

let copy_file src dst =
  let ic = open_in_bin src in
  let len = in_channel_length ic in
  let buf = Bytes.create len in
  really_input ic buf 0 len;
  close_in ic;
  write_file dst (Bytes.unsafe_to_string buf)

let rec copy_dir src dst =
  if Sys.is_directory src then (
    if not (Sys.file_exists dst) then Sys.mkdir dst 0o755;
    Array.iter
      (fun name ->
        copy_dir (Filename.concat src name) (Filename.concat dst name))
      (Sys.readdir src))
  else copy_file src dst

let () =
  let out_dir = Sys.argv.(1) in
  let blog_posts = Mirageio_data.Blog.all in

  (* --- Build all page content as (path, Tw_html.t tree) --- *)

  let page ~path ~title ~description ~tab inner =
    (path, Layout.render_html ~title ~description ~tab inner)
  in

  let pages =
    [
      page ~path:"index.html" ~title:Homepage.title
        ~description:Homepage.description ~tab:Homepage.tab
        (Homepage.render ~blog_posts:(take 8 blog_posts));
      page ~path:"blog/index.html" ~title:Blog.title
        ~description:Blog.description ~tab:Blog.tab
        (Blog.render ~latest:(take 8 blog_posts) ~recent:blog_posts);
      page ~path:"community/index.html" ~title:Community.title
        ~description:Community.description ~tab:Community.tab
        (Community.render ());
      page ~path:"docs/index.html" ~title:Docs.title
        ~description:Docs.description ~tab:Docs.tab
        (Docs.render ~weeklies:Mirageio_data.Weekly.all);
      page ~path:"papers/index.html" ~title:Papers.title
        ~description:Papers.description ~tab:Papers.tab
        (Papers.render Mirageio_data.Paper.all);
      page ~path:"404.html" ~title:Not_found.title
        ~description:Not_found.description ~tab:Not_found.tab
        (Not_found.render ());
    ]
    @ List.map
        (fun (post : Mirageio_data.Blog.t) ->
          page
            ~path:(Printf.sprintf "blog/%s/index.html" post.permalink)
            ~title:(Blog_inner.title post)
            ~description:(Blog_inner.description post)
            ~tab:Blog_inner.tab (Blog_inner.render post))
        blog_posts
    @ List.map
        (fun (doc : Mirageio_data.Wiki.t) ->
          page
            ~path:(Printf.sprintf "docs/%s/index.html" doc.permalink)
            ~title:(Docs_inner.title doc)
            ~description:(Docs_inner.description doc)
            ~tab:Docs_inner.tab (Docs_inner.render doc))
        Mirageio_data.Wiki.all
    @ List.map
        (fun (w : Mirageio_data.Weekly.t) ->
          page
            ~path:(Printf.sprintf "weekly/%s/index.html" w.permalink)
            ~title:(Weekly.title w)
            ~description:(Weekly.description w)
            ~tab:Weekly.tab (Weekly.render w))
        Mirageio_data.Weekly.all
  in

  (* --- Collect Tw utilities and generate CSS --- *)

  let all_tw =
    pages |> List.map (fun (_path, tree) -> Tw_html.to_tw tree) |> List.flatten
  in
  let css_string =
    Tw.to_css ~base:true ~forms:false all_tw |> Tw.Css.to_string
  in

  (* --- Write all HTML pages --- *)

  List.iter
    (fun (path, tree) ->
      let html = Tw_html.to_string ~doctype:true tree in
      write_file (Filename.concat out_dir path) html)
    pages;

  (* --- Write CSS --- *)

  write_file (Filename.concat out_dir "main.css") css_string;

  (* --- Generate Atom feed --- *)

  let contributors =
    let seen = Hashtbl.create 64 in
    blog_posts
    |> List.concat_map (fun (post : Mirageio_data.Blog.t) -> post.authors)
    |> List.filter (fun (a : Mirageio_data.People.t) ->
           if Hashtbl.mem seen a.name then false
           else (
             Hashtbl.replace seen a.name ();
             true))
  in
  let last_update =
    match blog_posts with p :: _ -> p.updated | [] -> Ptime.epoch
  in
  write_file (Filename.concat out_dir "feed.xml")
    (Atom.render ~blog_posts ~contributors ~last_update);

  (* --- Copy static assets (skip main.css, we generate it) --- *)

  (match List.find_opt Sys.file_exists [ "asset" ] with
  | Some asset_dir ->
      Array.iter
        (fun name ->
          if name <> "main.css" then
            copy_dir
              (Filename.concat asset_dir name)
              (Filename.concat out_dir name))
        (Sys.readdir asset_dir)
  | None -> Printf.eprintf "Warning: asset/ directory not found\n");

  Printf.printf "Generated %d pages, 1 feed, 1 CSS file\n"
    (List.length pages)
