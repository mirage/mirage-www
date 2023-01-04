module Make
    (Pclock : Mirage_clock.PCLOCK)
    (Time : Mirage_time.S)
    (Stack : Tcpip.Stack.V4V6) =
struct
  module Dream = Dream__mirage.Mirage.Make (Pclock) (Time) (Stack)

  let head handler request =
    match Dream.method_ request with
    | `HEAD ->
        let open Lwt.Syntax in
        Dream.set_method_ request `GET;
        let* response = handler request in
        let transfer_encoding = Dream.header response "Transfer-Encoding" in
        let* () =
          if
            transfer_encoding = Some "chunked"
            || Dream.has_header response "Content-Length"
          then Lwt.return_unit
          else
            let+ body = Dream.body response in
            body |> String.length |> string_of_int
            |> Dream.add_header response "Content-Length"
        in
        Dream.empty
          ~headers:(Dream.all_headers response)
          (Dream.status response)
    | _ -> handler request

  let no_trailing_slash next_handler request =
    let target = Dream.target request in
    match target with
    | "/" -> next_handler request
    | _ ->
        let length = String.length target in
        if target.[length - 1] = '/' then
          Dream.redirect request (String.sub target 0 (length - 1))
        else next_handler request
end
