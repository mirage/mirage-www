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

(** Static data for [mirage-www] *)

module Blog: sig
  (** {1 Static data for the blog} *)

  type t = Cowabloga.Blog.Entry.t
  (** The type for blog values. *)

  val entries: t list
  (** The {b static} list of blog entries. *)
end

module Wiki: sig
  (** {1 Static data for the wiki} *)

  type t = Cowabloga.Wiki.entry
  (** The type for wiki values. *)

  val entries: t list
  (** The {b static} list of wiki entries. *)
end

module Links: sig
  (** {1 Static list of external links about MirageOS} *)

  type t = Cowabloga.Links.t
  (** The type for link values. *)

  val entries: t list
  (** The {b static} list of external links about MirageOS. *)
end

module Feed: sig
  (** {1 Static feeds} *)

  type t = Www_types.domain -> Cow.Html.t Www_types.read -> Cowabloga.Atom_feed.t
  (** The type for feed generators. *)

  val blog: t
  (** The static feed for blog entries. *)

  val wiki: t
  (** The static feed for wiki entries. *)

  val updates: t
  (** The static feed for MirageOS updates. *)

  val links: t
  (** The static feed for external articles about MirageOS. *)
end

val google_analytics: Www_types.domain -> string * string
(** Google analytics configuration. *)

val empty_feed: Cowabloga.Atom_feed.t
(** The empty feed. *)
