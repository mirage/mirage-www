open Lwt.Syntax
open Cmdliner

type t = { http_port : int; redirect : string option }

let setup =
  Term.(
    const (fun http_port redirect -> { http_port; redirect })
    $ Cli.http_port $ Cli.redirect)

module Make (KV : Mirage_kv.RO) (Stack : Tcpip.Stack.V4V6) = struct
  module Paf = Paf_mirage.Make (Stack.TCP)

  (* Redirects *)
  let redirects =
    [ ("/wiki", "/docs"); ("/docs/security", "/security") ]

  let redirect_prefixes = [ ("/wiki/", "/docs/") ]

  module Last_modified = struct
    let ptime_to_http_date ptime =
      let (y, m, d), ((hh, mm, ss), _) = Ptime.to_date_time ptime
      and weekday =
        match Ptime.weekday ptime with
        | `Mon -> "Mon" | `Tue -> "Tue" | `Wed -> "Wed" | `Thu -> "Thu"
        | `Fri -> "Fri" | `Sat -> "Sat" | `Sun -> "Sun"
      and month =
        [| "Jan"; "Feb"; "Mar"; "Apr"; "May"; "Jun";
           "Jul"; "Aug"; "Sep"; "Oct"; "Nov"; "Dec" |]
      in
      Printf.sprintf "%s, %02d %s %04d %02d:%02d:%02d GMT"
        weekday d month.(m - 1) y hh mm ss

    let not_modified request store key =
      let* last_modified = KV.last_modified store key in
      match last_modified with
      | Error _ -> Lwt.return_none
      | Ok t ->
          let date = ptime_to_http_date t in
          let cached =
            match H1.Headers.get request.H1.Request.headers "if-modified-since" with
            | Some ts -> String.equal ts date
            | None -> false
          in
          Lwt.return_some (date, cached)
  end

  let mime_type path =
    let content_type = Magic_mime.lookup path in
    match content_type with
    | "text/html" | "text/xml" | "text/plain"
    | "application/javascript" | "application/rss+xml"
    | "application/atom+xml" ->
        content_type ^ "; charset=utf-8"
    | ct -> ct

  let respond_with reqd status headers body =
    let headers =
      ("content-length", string_of_int (String.length body)) :: headers
    in
    let headers = H1.Headers.of_list headers in
    let resp = H1.Response.create ~headers status in
    H1.Reqd.respond_with_string reqd resp body

  let serve_static store reqd path =
    let key = Mirage_kv.Key.v path in
    let* result = KV.get store key in
    match result with
    | Ok data ->
        let request = H1.Reqd.request reqd in
        let* modified = Last_modified.not_modified request store key in
        (match modified with
        | Some (_, true) ->
            respond_with reqd `Not_modified [] "";
            Lwt.return_unit
        | Some (date, false) ->
            respond_with reqd `OK
              [ ("content-type", mime_type path);
                ("last-modified", date);
                ("cache-control", "max-age=3600") ]
              data;
            Lwt.return_unit
        | None ->
            respond_with reqd `OK
              [ ("content-type", mime_type path);
                ("cache-control", "max-age=3600") ]
              data;
            Lwt.return_unit)
    | Error _ ->
        (* Try path/index.html *)
        let index = path ^ "/index.html" in
        let* result = KV.get store (Mirage_kv.Key.v index) in
        (match result with
        | Ok data ->
            respond_with reqd `OK
              [ ("content-type", "text/html; charset=utf-8");
                ("cache-control", "max-age=3600") ]
              data;
            Lwt.return_unit
        | Error _ ->
            let* result =
              KV.get store (Mirage_kv.Key.v "404.html")
            in
            let body =
              match result with Ok b -> b | Error _ -> "Not Found"
            in
            respond_with reqd `Not_found
              [ ("content-type", "text/html; charset=utf-8") ]
              body;
            Lwt.return_unit)

  let handle_request store reqd =
    let request = H1.Reqd.request reqd in
    let path =
      match String.index_opt request.target '?' with
      | Some i -> String.sub request.target 0 i
      | None -> request.target
    in
    (* Strip trailing slash *)
    let path =
      if String.length path > 1 && path.[String.length path - 1] = '/' then
        String.sub path 0 (String.length path - 1)
      else path
    in
    (* Check exact redirects *)
    match List.assoc_opt path redirects with
    | Some loc ->
        respond_with reqd `Moved_permanently [ ("location", loc) ] "";
        Lwt.return_unit
    | None ->
        (* Check prefix redirects *)
        let redir =
          List.find_opt
            (fun (pfx, _) ->
              String.length path >= String.length pfx
              && String.sub path 0 (String.length pfx) = pfx)
            redirect_prefixes
        in
        (match redir with
        | Some (pfx, new_pfx) ->
            let rest =
              String.sub path (String.length pfx)
                (String.length path - String.length pfx)
            in
            respond_with reqd `Moved_permanently
              [ ("location", new_pfx ^ rest) ] "";
            Lwt.return_unit
        | None ->
            (* Strip leading / for KV lookup *)
            let kv_path =
              if String.length path > 0 && path.[0] = '/' then
                String.sub path 1 (String.length path - 1)
              else path
            in
            (* Root path → index.html *)
            let kv_path =
              if kv_path = "" then "index.html" else kv_path
            in
            serve_static store reqd kv_path)

  let request_handler store _flow _dst reqd =
    Lwt.async (fun () -> handle_request store reqd)

  let error_handler _dst ?request:_ _err _respond = ()

  let start store stack { http_port = port; redirect } =
    match redirect with
    | Some domain ->
        let* t = Paf.init ~port (Stack.tcp stack) in
        let service =
          Paf.http_service ~error_handler (fun _flow _dst reqd ->
            let request = H1.Reqd.request reqd in
            let loc = domain ^ request.target in
            respond_with reqd `Moved_permanently [ ("location", loc) ] "")
        in
        let (`Initialized th) = Paf.serve service t in
        th
    | None ->
        let* t = Paf.init ~port (Stack.tcp stack) in
        let service = Paf.http_service ~error_handler (request_handler store) in
        let (`Initialized th) = Paf.serve service t in
        th
end
