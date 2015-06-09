(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2015 Citrix Inc
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

open Rrd

let timescales = Rrd_timescales.([
  make ~name:"minute" ~num_intervals:120 ~interval_in_steps:1 ();
  make ~name:"hour"   ~num_intervals:120 ~interval_in_steps:12 ();
  make ~name:"day"    ~num_intervals:168 ~interval_in_steps:720 ();
  make ~name:"year"   ~num_intervals:366 ~interval_in_steps:17280 ();
])

let create_rras use_min_max =
  (* Create archives of type min, max and average and last *)
  Array.of_list (List.flatten
    (List.map (fun { Rrd_timescales.num_intervals; interval_in_steps } ->
      if interval_in_steps > 1 && use_min_max then [
        Rrd.rra_create Rrd.CF_Average num_intervals interval_in_steps 1.0;
        Rrd.rra_create Rrd.CF_Min num_intervals interval_in_steps 1.0;
        Rrd.rra_create Rrd.CF_Max num_intervals interval_in_steps 1.0;
      ] else [Rrd.rra_create Rrd.CF_Average num_intervals interval_in_steps 0.5]
    ) timescales)
  )

let step = 5

module Ds = struct
  type t = {
    name: string;
    description: string;
    value: Rrd.ds_value_type;
    ty: Rrd.ds_type;
    max: float;
    min: float;
    units: string;
  }
  let make ~name ~description ~value ~ty ~units
    ?(min = neg_infinity) ?(max = infinity) () = {
    name; description; value; ty; min; max; units
  }
end

let make_dss stats = [
  Ds.make ~name:"free_words" ~units:"words"
    ~description:"Number of words in the free list"
    ~value:(Rrd.VT_Int64 (Int64.of_int stats.Gc.free_words)) ~ty:Rrd.Gauge ~min:0.0 ();
  Ds.make ~name:"live_words" ~units:"words"
    ~description:"Number of words of live data in the major heap, including the header words."
    ~value:(Rrd.VT_Int64 (Int64.of_int stats.Gc.live_words)) ~ty:Rrd.Gauge ~min:0.0 ();
  ]

(** Create a rrd *)
let create_fresh_rrd use_min_max dss =
  let rras = create_rras use_min_max in
  let dss = Array.of_list (List.map (fun ds ->
      Rrd.ds_create ds.Ds.name ds.Ds.ty ~mrhb:300.0 ~max:ds.Ds.max
      ~min:ds.Ds.min Rrd.VT_Unknown
    ) dss) in
  let rrd = Rrd.rrd_create dss rras (Int64.of_int step) (Clock.time ()) in
  rrd

let update_rrds timestamp dss rrd =
  Rrd.ds_update_named rrd timestamp ~new_domid:false
    (List.map (fun ds -> ds.Ds.name, (ds.Ds.value, fun x -> x)) dss)

let rrd = create_fresh_rrd true (make_dss (Gc.stat ()))

let start ~sleep =
  let rec loop () =
    let timestamp = Clock.time () in
    update_rrds timestamp (make_dss (Gc.stat ())) rrd;
    sleep 5. >>= fun () ->
    loop () in
  Lwt.async loop

let page () =
  let timescales = List.map (fun t ->
    let uri = "?timescale=" ^ t.Rrd_timescales.name in
    <:html<
    <a href="$str:uri$">$str:t.Rrd_timescales.name$</a>
    >>
  ) timescales in
  <:html<
    <head>
      <meta charset="utf-8" />
      <link href="https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.10/c3.css" rel="stylesheet" type="text/css"/>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js" charset="utf-8"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.10/c3.min.js"></script>
      <script src="/js/stats/main.js"> </script>
    </head>
    <body>
      <h1>GC statistics</h1>
      <p>
        $List.concat timescales$
      </p>
      <p>
        <div id="chart"/>
      </p>
    </body>
  >>

let get_rrd_updates uri =
  let query = Uri.query uri in
  let get key =
    if List.mem_assoc key query
    then match List.assoc key query with
      | [] -> None
      | x :: _ -> Some x
    else None in
  let (>>=) m f = match m with None -> None | Some x -> f x in
  let default d = function None -> d | Some x -> x in
  let int64 x = try Some (Int64.of_string x) with _ -> None in
  let cf x = try Some (Rrd.cf_type_of_string x) with _ -> None in
  let start = default 0L (get "start" >>= int64) in
  let interval = default 0L (get "interval" >>= int64) in
  let cfopt = get "cf" >>= cf in
  Rrd_updates.export [ "", rrd ] start interval cfopt

let get_rrd_timescales uri =
  Rrd_timescales.to_json timescales
