open Data

(* TODO uri must be a fully qualified hostname *)
let base_uri = function
  | `Https -> "https://openmirage.org/"
  | `Http  -> "http://openmirage.org/"

let google_analytics= ("UA-19610168-1", "openmirage.org")

let blog scheme read_entry = {
  Cowabloga.Atom_feed.base_uri = base_uri scheme;
  id = "blog/";
  title = "The MirageOS Blog";
  subtitle = Some "on building functional operating systems";
  rights;
  author = None;
  read_entry
}

let wiki scheme read_entry = {
  Cowabloga.Atom_feed.base_uri = base_uri scheme;
  id = "wiki/";
  title = "The MirageOS Documentation";
  subtitle = Some "guides and articles on using MirageOS";
  rights;
  author = None;
  read_entry
}

(* Metadata for /updates/atom.xml *)
let updates scheme read_entry = {
  Cowabloga.Atom_feed.base_uri = base_uri scheme;
  id = "updates/";
  title = "MirageOS updates";
  subtitle = None;
  rights;
  author = None;
  read_entry
}

let links scheme read_entry = {
  Cowabloga.Atom_feed.base_uri = base_uri scheme;
  id = "";
  title = "External articles about MirageOS";
  subtitle = None;
  rights;
  author = None;
  read_entry
}
