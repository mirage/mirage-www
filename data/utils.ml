open Import

let extract_metadata_body s =
  let sep = "---\n" in
  let win_sep = "---\r\n" in
  match (String.cut ~on:sep s, String.cut ~on:win_sep s) with
  | None, None -> raise (Failure "expected metadata at the top of the file")
  | Some (pre, post), _ | _, Some (pre, post) ->
      if String.length pre = 0 then
        match (String.cut ~on:sep post, String.cut ~on:win_sep post) with
        | None, None ->
            raise (Failure "expected metadata at the top of the file")
        | Some (yaml, body), _ | _, Some (yaml, body) -> (
            match Yaml.of_string yaml with
            | Ok yaml -> (yaml, body)
            | Error (`Msg err) ->
                raise
                  (Failure
                     (Printf.sprintf
                        "an error occured while reading yaml: %s\n %s" err s)))
      else raise (Failure "expected metadata at the top of the file")

let decode_or_raise ~loc f x =
  match f x with
  | Ok x -> x
  | Error (`Msg err) ->
      raise (Failure (Printf.sprintf "could not decode %s: %s" loc err))

let ls_dir directory =
  Sys.readdir directory |> Array.to_list |> List.map (Filename.concat directory)

let read_file file =
  let ic = open_in_bin file in
  Fun.protect
    (fun () ->
      let length = in_channel_length ic in
      really_input_string ic length)
    ~finally:(fun () -> close_in ic)

let read_from_dir ?(filter = fun _ -> true) dir =
  ls_dir dir
  |> List.filter_map (fun f -> if filter f then Some (f, read_file f) else None)

let map_files_in_dir f dir =
  read_from_dir dir
  |> List.map (fun (file, x) ->
         try f ~file ~content:x
         with exn ->
           prerr_endline ("Error in " ^ file);
           raise exn)

let map_md_files_in_dir ~decode_meta f dir =
  let filter file = Filename.extension file = ".md" in
  read_from_dir ~filter dir
  |> List.map (fun (file, content) ->
         let meta, body = extract_metadata_body content in
         let meta = decode_or_raise ~loc:file decode_meta meta in
         try f ~file ~meta ~body
         with exn ->
           prerr_endline ("Error in " ^ file);
           raise exn)

let with_yml_file ~decoder f =
  let yaml = decode_or_raise ~loc:f Yaml.of_string (read_file f) in
  match yaml with
  | `A xs -> List.map (decode_or_raise ~loc:f decoder) xs
  | _ -> failwith (Printf.sprintf "expected a list in %s" f)
