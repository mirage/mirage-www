open Data
let blog read_entry = {
  (* TODO uri must be a fully qualified hostname *)
  Cowabloga.Blog.base_uri="/";
  id = "";
  title = "The Mirage Blog";
  subtitle = Some "on building functional operating systems";
  rights;
  read_entry
}
