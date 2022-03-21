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

    let metrics _req =
      let data = Prometheus.CollectorRegistry.(collect default) in
      let body = Fmt.to_to_string Metrics.TextFormat_0_0_4.output data in
      Dream.respond
        ~headers:[ ("Content-Type", "text/plain; version=0.0.4") ]
        body
  end

  module Last_modified = struct
    (* https://github.com/roburio/unipi/blob/main/unikernel.ml *)
    let ptime_to_http_date ptime =
      let (y, m, d), ((hh, mm, ss), _) = Ptime.to_date_time ptime
      and weekday =
        match Ptime.weekday ptime with
        | `Mon -> "Mon"
        | `Tue -> "Tue"
        | `Wed -> "Wed"
        | `Thu -> "Thu"
        | `Fri -> "Fri"
        | `Sat -> "Sat"
        | `Sun -> "Sun"
      and month =
        [|
          "Jan";
          "Feb";
          "Mar";
          "Apr";
          "May";
          "Jun";
          "Jul";
          "Aug";
          "Sep";
          "Oct";
          "Nov";
          "Dec";
        |]
      in
      let m' = Array.get month (pred m) in
      Printf.sprintf "%s, %02d %s %04d %02d:%02d:%02d GMT" weekday d m' y hh mm
        ss
  end

  module Static = struct
    open Lwt.Syntax

    let store = Asset.connect ()

    let not_modified ~last_modified request =
      match Dream.header request "If-Modified-Since" with
      | None -> false
      | Some date -> String.equal date last_modified

    let max_age = 60 * 60 (* one hour *)

    let loader _root path request =
      let key = Mirage_kv.Key.v path in
      let* store = store in
      let* last_modified = Asset.last_modified store key in
      match last_modified with
      | Error _ -> Handler.not_found request
      | Ok last_modified -> (
          let last_modified =
            Last_modified.ptime_to_http_date (Ptime.v last_modified)
          in
          if not_modified ~last_modified request then
            Dream.respond ~status:`Not_Modified ""
          else
            let* result = Asset.get store (Mirage_kv.Key.v path) in
            match result with
            | Error _ -> Handler.not_found request
            | Ok asset ->
                Dream.respond
                  ~headers:
                    [
                      ("Cache-Control", Fmt.str "max-age=%d" max_age);
                      ("Last-Modified", last_modified);
                    ]
                  asset)
  end

  module Metrics = struct
    open Prometheus

    let now () = Ptime.to_float_s (Ptime.v (Pclock.now_d_ps ()))

    let response_time =
      Gauge.v ~help:"Mirage.io handler response time" "mirageio_response_time_s"

    let n_requests_pages =
      Counter.v ~help:"Mirage.io number of page requests"
        "mirageio_requests_pages"

    let n_requests_assets =
      Counter.v ~help:"Mirage.io number of asset requests"
        "mirageio_requests_assets"

    let n_cached =
      Counter.v ~help:"Mirage.io number of cache match" "mirageio_cached"

    let n_errors =
      Counter.v ~help:"Mirage.io number of errors" "mirageio_errors"

    let middleware counter handler req =
      let open Lwt.Syntax in
      let start = now () in
      let+ response = handler req in
      let elapsed = now () -. start in
      Gauge.set response_time elapsed;
      Counter.inc_one counter;
      (match Dream.status response with
      | `OK -> ()
      | `Not_Modified -> Counter.inc_one n_cached
      | _ -> Counter.inc_one n_errors);
      response
  end

  module Router = struct
    let routes =
      [
        Dream.get "/metrics" Handler.metrics;
        Dream.scope "/"
          [ Metrics.middleware Metrics.n_requests_pages ]
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
          ];
        Dream.get "/**"
          (Metrics.middleware Metrics.n_requests_assets
          @@ Dream.static ~loader:Static.loader "");
      ]

    let router = Dream.router routes
  end

  let router = Dream.logger @@ Router.router @@ Dream.not_found
  let http ?(port = 80) stack = Dream.http ~port (Stack.tcp stack) router

  let https ?(port = 443) ?tls stack =
    Dream.https ~port ?cfg:tls (Stack.tcp stack) router
end
