module List = struct
  include Stdlib.List

  let rec take n = function
    | _ when n = 0 -> []
    | [] -> []
    | hd :: tl -> hd :: take (n - 1) tl

  let uniq lst =
    let seen = Hashtbl.create (List.length lst) in
    List.filter
      (fun x ->
        let tmp = not (Hashtbl.mem seen x) in
        Hashtbl.replace seen x ();
        tmp)
      lst
end
