let (>>=) = Lwt.bind

let delay = 60. *. 2.
let history = 100

let html_of_stat t =
  let open Gc in
  let k f =
    let str = Printf.sprintf "%dk" (f / 1_000) in
    Cow.Html.of_string str
  in
  let m f =
    let str = Printf.sprintf "%.0fm" (f /. 1_000_000.) in
    Cow.Html.of_string str
  in
  <:html<
      <tr>
      <td>$m (Gc.allocated_bytes ())$</td>
      <td>$k t.heap_words$</td>
      <td>$k t.live_words$</td>
      </tr>
    >>

let html_of_stats ts =
  <:html<
    <table>
    <tr>
    <th>Allocated Bytes</th>
    <th>Heap Words</th>
    <th>Live Words</th>
    </tr>
    $list:List.map html_of_stat ts$
    </table>
   >>

let stats = Queue.create ()

let start ~sleep =
  let gather () =
    let stat = Gc.stat () in
    if Queue.length stats >= history then ignore (Queue.pop stats);
    Queue.push stat stats
  in
  let rec loop () =
    gather ();
    sleep delay >>= fun () ->
    loop ()
  in
  Lwt.async loop

let page () =
  let stats = Queue.fold (fun acc s -> s :: acc) [] stats in
  html_of_stats stats
