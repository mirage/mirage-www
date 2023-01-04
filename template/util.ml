let date_to_string ptime =
  let (year, month, day) = Ptime.to_date ptime in
  Fmt.str "%04d-%02d-%02d" year month day
