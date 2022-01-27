module Make
    (Pclock : Mirage_clock.PCLOCK)
    (Time : Mirage_time.S)
    (Stack : Tcpip.Stack.V4V6) =
struct
  module WWW = Mirageio.Make (Pclock) (Time) (Stack)

  let start _ _ stack = WWW.http ~port:(Key_gen.http_port ()) stack
end