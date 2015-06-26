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

(** Various pages. *)

type t = read:string Types.read -> domain:Types.domain -> Types.contents Lwt.t
(** The type for page values. *)

type dispatch =
  feed:Cowabloga.Atom_feed.t -> read:string Types.read -> Types.dispatch
(** The type for page dispatch. *)

module Global: sig
  (** Global page template. *)

  val t: title:string -> headers:Cow.Html.t -> content:Cow.Html.t -> t
  (** [t ~title ~headers ~content] is the page generated from a global
      template based on {!Cowabloga.Foundation.body}. The generated
      page will have [title] as page title, [headers] as additional
      headers and [content] as contents. *)

end

module Releases: sig
  (** Release page. *)

  val dispatch: dispatch
  (** [dispatch] is the dispatch function serving the [/releases] and
      [/releases/index.html] page. *)

end

module Links: sig
  (** External link page. *)

  val dispatch: links:Cowabloga.Links.t list -> dispatch
  (** [dispatch l] is the dispatch function serving a the list of
      external links extracted from [links] for the paths [/] and
      [/index.html]. Moreover, [kind/permalink] are redirected to the
      the external links directly. *)

end

module Index: sig
  (** The main index page. *)

  val t: feeds:Cowabloga.Feed.feed list -> t
  (** [t f] is the [/index.html] page, with a snippet of the recent
      changes extracted from [f]. *)

end

module Updates: sig
  (** Update pages. *)

  val dispatch: feeds:Cowabloga.Feed.feed list -> dispatch
  (** [dispatch f] is the dispatch function serving [/updates/],
      [/updates/index.html] and [/updates/atom.xml] using the contents
      extracted from [f]. *)

end

module About: sig
  (** An about page. *)

  val dispatch: dispatch
  (** [dispatch] is the dispatch function serving [/about] and
      [/about/index.html] page. *)

end
