module Make
    (Pclock : Mirage_clock.PCLOCK)
    (Time : Mirage_time.S)
    (Stack : Tcpip.Stack.V4V6) =
struct
  module WWW = Mirageio.Make (Pclock) (Time) (Stack)

  let start _ _ stack =
    match Key_gen.redirect () with
    | None -> WWW.http ~port:(Key_gen.http_port ()) stack
    | Some domain ->
        WWW.Dream.(
          http ~port:(Key_gen.http_port ()) (Stack.tcp stack) @@ fun req ->
          redirect ~status:`Moved_Permanently req domain)
end
