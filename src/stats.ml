(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt.Infix

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
