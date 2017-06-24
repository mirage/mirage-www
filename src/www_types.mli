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

(** Basic types. *)

type domain = [`Http | `Https] * string
(** The type for domain scheme and name. *)

type path = string list
(** The type for URL path values. *)

type headers = (string * string) list
(** The type for header values. *)

type html = [ `Html of string Lwt.t ]
(** The type for raw HTML pages to be included in a template. *)

type page = [ `Page of headers * string Lwt.t ]
(** The type for static page values, to be included in a template. *)

type contents = [
  | page | html
  | `Not_found of Uri.t
  | `Redirect of Uri.t
]
(** The type for raw contents. This will be inserted into the global
    page template by the template engine. *)

type dispatch = domain:domain -> (path -> contents) Lwt.t
(** The type for static dispatch functions. *)

type 'a read = string -> 'a Lwt.t
(** The type to read files on the filesystem. *)

(** {2 Cowabloga helpers} *)

type cowabloga = [
  | html | page
  | `Atom of string Lwt.t
  | `Asset of string Lwt.t
  | `Redirect of string
  | `Not_found of string
]
(** The type for cowabloga pages. FIXEM: upstream {!contents}
    instead. *)
