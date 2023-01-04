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
end
