open Data

(* TODO uri must be a fully qualified hostname *)
let base_uri = "https://openmirage.org/"

let google_analytics= ("UA-19610168-1", "openmirage.org")

let blog read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "blog/";
  title = "The MirageOS Blog";
  subtitle = Some "on building functional operating systems";
  rights;
  author = None;
  read_entry
}

let wiki read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "wiki/";
  title = "The MirageOS Documentation";
  subtitle = Some "guides and articles on using MirageOS";
  rights;
  author = None;
  read_entry
}

(* Metadata for /updates/atom.xml *)
let updates read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "updates/";
  title = "MirageOS updates";
  subtitle = None;
  rights;
  author = None;
  read_entry
}

let links read_entry = {
  Cowabloga.Atom_feed.base_uri;
  id = "";
  title = "External articles about MirageOS";
  subtitle = None;
  rights;
  author = None;
  read_entry
}
