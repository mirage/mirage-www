open Lwt

(* XXX very inefficient *)
let string_of_stream s = 
  Lwt_stream.to_list s >|= Bitstring.concat >|= Bitstring.string_of_bitstring
