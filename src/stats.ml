let (>>=) = Lwt.bind

let delay = 60. *. 2.
let history = 10_000

let html_of_stat t =
  let open Gc in
  let k f =
    let str = Printf.sprintf "%.0fk" (f /. 1000.) in
    Cow.Html.of_string str
  in
  <:html<
      <tr>
      <td>$k t.minor_words$</td>
      <td>$k t.major_words$</td>
      <td>$int:t.minor_collections$</td>
      <td>$int:t.major_collections$</td>
      </tr>
    >>

let html_of_stats ts =
  <:html<
    <table>
    <tr>
    <th>Minor Words</th>
    <th>Major Words</th>
    <th>Minor Collections</th>
    <th>Major Collections</th>
    </tr>
    $list:List.map html_of_stat ts$
    </table>
   >>

let stats = Queue.create ()

let start ~sleep =
  let gather () =
    let stat = Gc.quick_stat () in
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
