open Data

(* TODO uri must be a fully qualified hostname *)
let base_uri = "http://openmirage.org/"

let blog read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "";
  title = "The Mirage Blog";
  subtitle = Some "on building functional operating systems";
  rights;
  author = None;
  read_entry
}
let wiki read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "";
  title = "The Mirage Documentation";
  subtitle = Some "guides and articles on using Mirage OS";
  rights;
  author = None;
  read_entry
}
(* Metadata for /updates/atom.xml *)
let updates read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "";
  title = "Mirage OS updates";
  subtitle = None;
  rights;
  author = None;
  read_entry
}
