(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Data

let base_uri (scheme, domain) = match scheme with
  | `Https -> "https://" ^ domain ^ "/"
  | `Http  -> "http://"  ^ domain ^ "/"

let google_analytics domain = ("UA-19610168-1", domain)

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
