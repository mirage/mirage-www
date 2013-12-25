open Data
let blog read_entry = {
  (* TODO uri must be a fully qualified hostname *)
  Cowabloga.Atom_feed.base_uri="http:///openmirage.org/";
  id = "";
  title = "The Mirage Blog";
  subtitle = Some "on building functional operating systems";
  rights;
  author = None;
  read_entry
}
let wiki read_entry = {
  (* TODO uri must be a fully qualified hostname *)
  Cowabloga.Atom_feed.base_uri="http://openmirage.org/";
  id = "";
  title = "The Mirage Documentation";
  subtitle = Some "guides and articles on using Mirage OS";
  rights;
  author = None;
  read_entry
}
