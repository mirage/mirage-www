module String = struct
  include Stdlib.String

  let lsplit2_exn on s =
    let i = index s on in
    (sub s 0 i, sub s (i + 1) (length s - i - 1))

  let lsplit2 on s = try Some (lsplit2_exn s on) with Not_found -> None
  let prefix s len = try sub s 0 len with Invalid_argument _ -> ""

  let suffix s len =
    try sub s (length s - len) len with Invalid_argument _ -> ""

  let drop_prefix s len = sub s len (length s - len)
  let drop_suffix s len = sub s 0 (length s - len)

  (* ripped off stringext, itself ripping it off from one of dbuenzli's libs *)
  let cut s ~on =
    let sep_max = length on - 1 in
    if sep_max < 0 then invalid_arg "Stringext.cut: empty separator"
    else
      let s_max = length s - 1 in
      if s_max < 0 then None
      else
        let k = ref 0 in
        let i = ref 0 in
        (* We run from the start of [s] to end with [i] trying to match the
           first character of [on] in [s]. If this matches, we verify that the
           whole [on] is matched using [k]. If it doesn't match we continue to
           look for [on] with [i]. If it matches we exit the loop and extract a
           substring from the start of [s] to the position before the [on] we
           found and another from the position after the [on] we found to end of
           string. If [i] is such that no separator can be found we exit the
           loop and return the no match case. *)
        try
          while !i + sep_max <= s_max do
            (* Check remaining [on] chars match, access to unsafe s (!i + !k) is
               guaranteed by loop invariant. *)
            if unsafe_get s !i <> unsafe_get on 0 then incr i
            else (
              k := 1;
              while
                !k <= sep_max && unsafe_get s (!i + !k) = unsafe_get on !k
              do
                incr k
              done;
              if !k <= sep_max then (* no match *) incr i else raise Exit)
          done;
          None (* no match in the whole string. *)
        with Exit ->
          (* i is at the beginning of the separator *)
          let left_end = !i - 1 in
          let right_start = !i + sep_max + 1 in
          Some
            (sub s 0 (left_end + 1), sub s right_start (s_max - right_start + 1))

  let rcut s ~on =
    let sep_max = length on - 1 in
    if sep_max < 0 then invalid_arg "Stringext.rcut: empty separator"
    else
      let s_max = length s - 1 in
      if s_max < 0 then None
      else
        let k = ref 0 in
        let i = ref s_max in
        (* We run from the end of [s] to the beginning with [i] trying to match
           the last character of [on] in [s]. If this matches, we verify that
           the whole [on] is matched using [k] (we do that backwards). If it
           doesn't match we continue to look for [on] with [i]. If it matches we
           exit the loop and extract a substring from the start of [s] to the
           position before the [on] we found and another from the position after
           the [on] we found to end of string. If [i] is such that no separator
           can be found we exit the loop and return the no match case. *)
        try
          while !i >= sep_max do
            if unsafe_get s !i <> unsafe_get on sep_max then decr i
            else
              (* Check remaining [on] chars match, access to unsafe_get s
                 (sep_start + !k) is guaranteed by loop invariant. *)
              let sep_start = !i - sep_max in
              k := sep_max - 1;
              while
                !k >= 0 && unsafe_get s (sep_start + !k) = unsafe_get on !k
              do
                decr k
              done;
              if !k >= 0 then (* no match *) decr i else raise Exit
          done;
          None (* no match in the whole string. *)
        with Exit ->
          (* i is at the end of the separator *)
          let left_end = !i - sep_max - 1 in
          let right_start = !i + 1 in
          Some
            (sub s 0 (left_end + 1), sub s right_start (s_max - right_start + 1))
end
