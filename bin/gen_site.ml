(* gen_site.ml -- Static site generator for mirageos.org

   Renders all pages to HTML using the existing EML templates,
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

let uniq lst =
  let seen = Hashtbl.create (List.length lst) in
  List.filter
    (fun (x : Mirageio_data.People.t) ->
      if Hashtbl.mem seen x.name then false
      else (
        Hashtbl.replace seen x.name ();
        true))
    lst

let () =
  let out_dir = Sys.argv.(1) in
  let blog_posts = Mirageio_data.Blog.all in
  let pages =
    [
      ("index.html", Homepage.render ~blog_posts:(take 8 blog_posts));
      ( "blog/index.html",
        Blog.render ~latest:(take 8 blog_posts) ~recent:blog_posts );
      ("community/index.html", Community.render ());
      ("docs/index.html", Docs.render ~weeklies:Mirageio_data.Weekly.all);
      ("papers/index.html", Papers.render Mirageio_data.Paper.all);
      ("404.html", Not_found.render ());
    ]
    @ List.map
        (fun (post : Mirageio_data.Blog.t) ->
          ( Printf.sprintf "blog/%s/index.html" post.permalink,
            Blog_inner.render post ))
        blog_posts
    @ List.map
        (fun (doc : Mirageio_data.Wiki.t) ->
          ( Printf.sprintf "docs/%s/index.html" doc.permalink,
            Docs_inner.render doc ))
        Mirageio_data.Wiki.all
    @ List.map
        (fun (w : Mirageio_data.Weekly.t) ->
          (Printf.sprintf "weekly/%s/index.html" w.permalink, Weekly.render w))
        Mirageio_data.Weekly.all
  in
  List.iter
    (fun (path, html) -> write_file (Filename.concat out_dir path) html)
    pages;
  let contributors =
    blog_posts
    |> List.concat_map (fun (post : Mirageio_data.Blog.t) -> post.authors)
    |> uniq
  in
  let last_update =
    match blog_posts with p :: _ -> p.updated | [] -> Ptime.epoch
  in
  write_file
    (Filename.concat out_dir "feed.xml")
    (Atom.render ~blog_posts ~contributors ~last_update);
  (match List.find_opt Sys.file_exists [ "asset" ] with
  | Some asset_dir ->
      Array.iter
        (fun name ->
          copy_dir
            (Filename.concat asset_dir name)
            (Filename.concat out_dir name))
        (Sys.readdir asset_dir)
  | None -> Printf.eprintf "Warning: asset/ directory not found\n");
  Printf.printf "Generated %d pages, 1 feed\n" (List.length pages)
