let foo () = failwith "foo"
let read_arg _ = failwith "read_arg"
let new_id () = Oo.id (object end)
let on_response_to _ _ : unit = failwith "on_response_to"
let send_request _ _ : unit = failwith "send_request"
let pp_frame _ _ = failwith "pp_fram"
let generate _ = failwith "generate"
let get_input _ : int = 0
let get_input_lwt _ : int Lwt.t = Lwt.return 0

module Time : Mirage_time.S = struct
  let sleep_ns _ : unit Lwt.t = failwith "Time.sleep_ns"
end

module R = struct
  let generate n : Cstruct.t = failwith "R.generate"
end
