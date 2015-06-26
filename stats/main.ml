(* Copyright (c) 2015, Dave Scott <dave@recoil.org>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)

open Lwt
open Lwt_log_js

let do_get ~uri =
  let open XmlHttpRequest in
  let uri = Uri.to_string uri in
  get uri
  >>= fun frame ->
  if frame.code = 200
  then return frame.content
  else begin
    error_f "GET %s returned code %d" uri frame.code
    >>= fun () ->
    fail (Failure "GET failed")
  end

let chart = ref None

let colon = Re_str.regexp_string ":"

let render_update timescale update =
  let open Rrd_updates in
  let window = Rrd_timescales.to_span timescale in
	let _, legends = Array.fold_left
	  (fun (idx, acc) elt ->
      match Re_str.split_delim colon elt with
      | [ "AVERAGE"; name ] ->
       (idx + 1, (idx, name) :: acc)
     | _ ->
         (idx + 1, acc)
    ) (0, []) update.legend in

  let data = Array.to_list update.data in
  let labels = List.map snd legends in
  let chart = match !chart with
  | Some x -> x
  | None ->
      let segments =
        List.map
          (fun (_, label) ->
            C3.Segment.make ~label ~kind:`Area ~points:[] ()
          ) legends in
      let x =
        C3.Line.make ~kind:`Timeseries ~x_format:"%H:%M:%S" ~x_label:"Time" ~y_label:"words" ()
        |> C3.Line.add_group ~segments
        |> C3.Line.render ~bindto:"#chart" in
      chart := Some x;
      x in

  let x_min = Int64.to_float update.Rrd_updates.end_time -. (float_of_int window) in
  let nans = List.map
    (fun (idx, _) ->
      Array.map (fun x -> classify_float x.row_data.(idx) = FP_nan) update.data
    ) legends in
  let segments =
    List.map (fun (idx, legend) ->
      let points = List.mapi (fun i x ->
        (* if a NaN appears in any archive, set all the others to NaN too. *)
        if List.fold_left (||) false (List.map (fun x -> x.(i)) nans)
        then []
        else [x.time, x.row_data.(idx)]
      ) data |> List.concat in
      if points <> []
      then [ C3.Segment.make ~label:legend ~kind:`Area ~points:(List.map (fun (t, v) -> Int64.to_float t, v) points) () ]
      else []
    ) legends |> List.concat in
  C3.Line.update ~segments chart

let watch_rrds () =
  let get key query =
    if List.mem_assoc key query
    then Some (List.assoc key query)
    else None in
  let default d = function None -> d | Some x -> x in

  let selected_timescale = default "minute" @@ get "?timescale" Url.Current.arguments in

  do_get ~uri:(Uri.make ~scheme:"http" ~path:"/rrd_timescales" ())
  >>= fun txt ->
  let timescales = Rrd_timescales.of_json txt in

  let timescale = List.find (fun t -> Rrd_timescales.name_of t = selected_timescale) timescales in

  let uri start =
    let query = [ "start", [ string_of_int start ]; "interval", [ string_of_int (Rrd_timescales.interval_to_span timescale)] ] in
    Uri.make ~scheme:"http" ~path:"/rrd_updates" ~query () in

  let window = Rrd_timescales.to_span timescale in

  let rec loop start =
    do_get ~uri:(uri start)
    >>= fun txt ->
    let input = Xmlm.make_input (`String (0, txt)) in
    let update = Rrd_updates.of_xml input in
    render_update timescale update;
    Lwt_js.sleep 5.
    >>= fun () ->
    loop (-window + 1) in


  loop (-window + 1)

let _ =
  Lwt_js_events.onload () >>= (fun _ -> watch_rrds ())
