open Import

module Make
    (Pclock : Mirage_clock.PCLOCK)
    (Time : Mirage_time.S)
    (Stack : Tcpip.Stack.V4V6) =
struct
  module Dream = Dream__mirage.Mirage.Make (Pclock) (Time) (Stack)

  module Handler = struct
    open Mirageio_template

    let not_found _req = Dream.html ~code:404 (Not_found.render ())

    let index _req =
      let blog_posts = Mirageio_data.Blog.all |> List.take 8 in
      Dream.html (Homepage.render ~blog_posts)

    let community _req = Dream.html (Community.render ())

    let blog _req =
      let latest = Mirageio_data.Blog.all |> List.take 8 in
      let recent = Mirageio_data.Blog.all in
      Dream.html (Blog.render ~latest ~recent)

    let blog_inner req =
      let permalink = Dream.param req "permalink" in
      let post_opt =
        Mirageio_data.Blog.all
        |> List.find_opt (fun (x : Mirageio_data.Blog.t) ->
              x.permalink = permalink)
      in
      match post_opt with
      | Some post -> Dream.html (Blog_inner.render post)
      | None -> not_found req

    let docs _req =
      let weeklies = Mirageio_data.Weekly.all in
      Dream.html (Docs.render ~weeklies)

    let docs_inner req =
      let permalink = Dream.param req "permalink" in
      let doc_opt =
        Mirageio_data.Wiki.all
        |> List.find_opt (fun (x : Mirageio_data.Wiki.t) ->
              x.permalink = permalink)
      in
      match doc_opt with
      | Some doc -> Dream.html (Docs_inner.render doc)
      | None -> not_found req

    let weekly req =
      let permalink = Dream.param req "permalink" in
      let weekly_opt =
        Mirageio_data.Weekly.all
        |> List.find_opt (fun (x : Mirageio_data.Weekly.t) ->
              x.permalink = permalink)
      in
      match weekly_opt with
      | Some weekly -> Dream.html (Weekly.render weekly)
      | None -> not_found req

    let papers _req = Dream.html (Papers.render Mirageio_data.Paper.all)

    let atom _req =
      let blog_posts = Mirageio_data.Blog.all in
      let contributors =
        Mirageio_data.Blog.all
        |> List.map (fun blog -> blog.Mirageio_data.Blog.authors)
        |> List.flatten |> List.uniq
      in
      let last_update = (List.hd blog_posts).Mirageio_data.Blog.updated in
      Dream.respond
        ~headers:[ ("Content-Type", "application/atom+xml") ]
        (Atom.render ~blog_posts ~contributors ~last_update)
  end

  module Router = struct
    let loader _root path request =
      match Asset.read path with
      | None -> Handler.not_found request
      | Some asset -> Dream.respond asset

    let routes =
      [
        Dream.get "/" Handler.index;
        Dream.get "/blog" Handler.blog;
        Dream.get "/blog/:permalink" Handler.blog_inner;
        Dream.get "/community" Handler.community;
        Dream.get "/docs" Handler.docs;
        Dream.get "/docs/:permalink" Handler.docs_inner;
        Dream.get "/weekly/:permalink" Handler.weekly;
        Dream.get "/papers" Handler.papers;
        Dream.get "/feed.xml" Handler.atom;
        Dream.get "/**" (Dream.static ~loader "");
      ]

    let router = Dream.router routes
  end

  let start _ _ stack =
    let router = Dream.logger @@ Router.router @@ Dream.not_found in
    Dream.http ~port:8080 (Stack.tcp stack) router
end
