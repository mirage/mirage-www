let date_to_string ptime =
  let year, month, day = Ptime.to_date ptime in
  Printf.sprintf "%04d-%02d-%02d" year month day
