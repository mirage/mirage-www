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

module Option = struct
  let value_exn ?(message="") = function
    | Some x -> x
    | None ->
      Lwt.async (fun () -> error_f "Option.value_exn failed %s" message);
      raise Not_found
end

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

(* The memory chart will show these legends *)
let memory_legends = [
  "AVERAGE:live_words";
  "AVERAGE:free_words"
]

let memory, memory_u = Lwt.task ()

let http_legends = [
  "AVERAGE:requests_per_second";
  "AVERAGE:errors_per_second"
]

let http, http_u = Lwt.task ()

(* Return the index of an element in an array, or None *)
let index_of name array =
  Array.fold_left
    (fun (idx, found) elt ->
      idx + 1, (if elt = name then Some idx else found)
    ) (0, None) array |> snd

(* Given an rrd update, update a single chart *)
let render_chart chart legends update =
  let open Rrd_updates in
  let data = Array.to_list update.data in
  let legends = List.map (fun legend ->
    Option.value_exn ~message:legend @@ index_of legend update.legend, legend
  ) legends in
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

(* Given an rrd update, redraw all the charts *)
let render_update update =
  (* Create the memory chart if it doesn't already exist *)
  if Lwt.state memory = Lwt.Sleep then begin
    let segments =
      List.map
        (fun label ->
          C3.Segment.make ~label ~kind:`Area ~points:[] ()
        ) memory_legends in
    C3.Line.make ~kind:`Timeseries ~x_format:"%H:%M:%S" ~x_label:"Time" ~y_label:"words" ()
    |> C3.Line.add_group ~segments
    |> C3.Line.render ~bindto:"#memory"
    |> Lwt.wakeup memory_u
  end;
  memory >>= fun memory ->
  render_chart memory memory_legends update;
  if Lwt.state http = Lwt.Sleep then begin
    let segments =
      List.map
        (fun label ->
          C3.Segment.make ~label ~kind:`Area ~points:[] ()
        ) http_legends in
    let chart = C3.Line.make ~kind:`Timeseries ~x_format:"%H:%M:%S" ~x_label:"Time" ~y_label:"per second" () in
    List.fold_left (fun chart segment -> C3.Line.add ~segment chart) chart segments
    |> C3.Line.render ~bindto:"#http"
    |> Lwt.wakeup http_u
  end;
  http >>= fun http ->
  render_chart http http_legends update;
  return ()

let watch_rrds () =
  let get key query =
    if List.mem_assoc key query
    then Some (List.assoc key query)
    else None in
  let default d = function None -> d | Some x -> x in

  let selected_timescale = default "minute" @@ get "?timescale" Url.Current.arguments in

  do_get ~uri:(Uri.make ~path:"/rrd_timescales" ())
  >>= fun txt ->
  let timescales = Rrd_timescales.of_json txt in

  let timescale = List.find (fun t -> Rrd_timescales.name_of t = selected_timescale) timescales in

  let uri start =
    let query = [ "start", [ string_of_int start ]; "interval", [ string_of_int (Rrd_timescales.interval_to_span timescale)] ] in
    Uri.make ~path:"/rrd_updates" ~query () in

  let window = Rrd_timescales.to_span timescale in

  let rec loop start =
    do_get ~uri:(uri start)
    >>= fun txt ->
    let input = Xmlm.make_input (`String (0, txt)) in
    let update = Rrd_updates.of_xml input in
    render_update update
    >>= fun () ->
    Lwt_js.sleep 5.
    >>= fun () ->
    loop (-window + 1) in


  loop (-window + 1)

let _ =
  Lwt_js_events.onload () >>= (fun _ -> watch_rrds ())
