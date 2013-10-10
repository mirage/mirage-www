open Printf
open Lwt
open Cow

module CL = Cohttp_lwt_mirage
module C = Cohttp

module Resp = struct

  (* dynamic response *)
  let dyn ?(headers=[]) req body =
    printf "Dispatch: dynamic URL %s\n%!" (Uri.path (CL.Request.uri req));
    lwt body = body in
    let status = `OK in
    let headers = C.Header.of_list headers in
    CL.Server.respond_string ~headers ~status ~body ()

  let dyn_xhtml = dyn ~headers:Pages.content_type_xhtml

  (* dispatch non-file URLs *)
  let dispatch req =
    function
      | [] | [""] | [""; "index.html"] -> dyn_xhtml req Pages.Index.t
      | [""; "resources"] -> dyn_xhtml req Pages.Resources.t
      | [""; "about"] -> dyn_xhtml req Pages.About.t
      | "" :: "blog" :: tl ->
          let headers, t = Pages.Blog.t tl in
          dyn ~headers req t
      | "" :: "wiki" :: "tag" :: tl -> dyn_xhtml req (Pages.Wiki.tag tl)
      | "" :: "wiki" :: page ->
          let headers, t = Pages.Wiki.t page in
          dyn ~headers req t
      | [""; "styles";"index.css"] -> 
          dyn ~headers:Style.content_type_css req Style.t
      | x -> CL.Server.respond_not_found ~uri:(CL.Request.uri req) ()
end

(* handle exceptions with a 500 *)
let exn_handler exn =
  let body = Printexc.to_string exn in
  eprintf "HTTP: ERROR: %s\n" body;
  return ()

let rec remove_empty_tail = function
  | [] | [""] -> []
  | hd::tl -> hd :: remove_empty_tail tl

module Tar_IO = Tar.Archive(struct
  type 'a t = 'a Lwt.t
  let ( >>= ) = Lwt.bind
  let return = Lwt.return
end)

module StringMap = Map.Make(struct type t = string let compare (a: string) (b: string) = compare a b end)

(* Create a kv_ro disk device from a block device with tar-format data *)
let make_kv_ro_from_tar blkif =
  (* Compare filenames without a leading / *)
  let trim_slash = function
    | "" -> ""
    | x when x.[0] = '/' -> String.sub x 1 (String.length x - 1)
    | x -> x in
  (* Build an in-memory index of the data *)
  lwt map = Tar_IO.fold (fun map tar data_offset ->
    let filename = trim_slash tar.Tar.Header.file_name in
    let map = StringMap.add filename (tar, data_offset) map in
    Printf.printf "Adding [%s] (size %Ld)\n%!" filename tar.Tar.Header.file_size;
    return map
  ) StringMap.empty (fun x -> Lwt_stream.next (blkif#read_512 x 1L)) in
  Printf.printf "Indexed %d files\n%!" (StringMap.cardinal map);
  return (object
    method read name =
      let name = trim_slash name in
      if not(StringMap.mem name map)
      then return None
      else
        let tar, from = StringMap.find name map in
        let sectors = Tar.Header.to_sectors tar in
        let s = blkif#read_512 from sectors in
        (* the stream will be zero-padded, we need to clip the end off *)
        let remaining = ref tar.Tar.Header.file_size in
        return (Some (Lwt_stream.from (fun () ->
          if !remaining = 0L
          then return None
          else match_lwt Lwt_stream.get s with
            | None -> return None (* truncated *)
            | Some chunk ->
              let len_64 = Int64.of_int (Cstruct.len chunk) in
              if len_64 >= !remaining then begin
                remaining := Int64.sub !remaining len_64;
                return (Some chunk)
              end else begin
                let chunk' = Cstruct.sub chunk 0 (Int64.to_int !remaining) in
                remaining := 0L;
                return (Some chunk')
              end
        )))
  end)

let disk =
  lwt () = Blkfront.register () in
  let blkif, u = Lwt.task () in
  let _ = OS.Devices.listen (fun id ->
    OS.Devices.find_blkif id >>= function
    | None -> return ()
    | Some blkif ->
      Printf.printf "Block device %s data available\n%!" id;
      Lwt.wakeup u blkif; return ()
  ) in
  lwt blkif = blkif in
  make_kv_ro_from_tar blkif

let static =
  eprintf "finding the static kv_ro block device\n";
  let t, u = Lwt.task () in
  let _ = OS.Devices.find_kv_ro "static" >>= function
    | None -> return ()
    | Some x ->
      Printf.printf "KV_RO data available\n%!";
      Lwt.wakeup u x; return () in
  t

class type reader = object
  method read: string -> Cstruct.t Lwt_stream.t option Lwt.t
end

let resources = [
  (disk :> reader Lwt.t); 
  (static :> reader Lwt.t);
]

(* main callback function *)
let t conn_id ?body req =
  let path = Uri.path (CL.Request.uri req) in
  let path_elem =
    remove_empty_tail (Re_str.split_delim (Re_str.regexp_string "/") path)
  in
  (* Look through the threads in order, if one is ready then attempt
     to use it, otherwise fall through to the next *)
  let rec lookup = function
  | [] ->
    Resp.dispatch req path_elem
  | t :: ts ->
    begin match Lwt.poll t with
    | None -> lookup ts
    | Some store ->
      lwt contents = store#read path in
      begin match contents with
      | None -> lookup ts
      | Some body ->
        lwt body = Util.string_of_stream body in
        CL.Server.respond_string ~status:`OK ~body ()
      end
    end in
  lookup resources
