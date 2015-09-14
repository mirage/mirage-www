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

(** HTTP dispatcher *)

(** The HTTP dispatcher. *)
module Make
    (C: V1_LWT.CONSOLE)
    (FS: V1_LWT.KV_RO)
    (TMPL: V1_LWT.KV_RO)
    (S: Cohttp_lwt.Server)
    (Clock: V1.CLOCK) :
sig

  type dispatch = Types.path -> Types.cowabloga Lwt.t
  (** The type for dispatch functions. *)

  val redirect: Types.domain -> dispatch
  (** [redirect d path] redirects the user to [path] on domain [d]. *)

  val dispatch: Types.domain -> C.t -> FS.t -> TMPL.t -> dispatch
  (** [dispatcher d fs tmpl path] is the object served by the HTTP
      server.

      {ul
      {- [d] is the current domain scheme and hostname;}
      {- [fs] is a read-only key/value store holding the static files such as
      images or CSS files;}
      {- [tmpl] is a read-only key/value store holding the proccessed data such
      as blog posts and wiki entries.}} *)

  val create: Types.domain -> C.t -> dispatch -> S.t
  (** [create c f] is an HTTP server function using [f] as callback
      and logging on the console [c].  *)

  type s = Conduit_mirage.server -> S.t -> unit Lwt.t
  (** The type for HTTP callbacks. *)

  val start: C.t -> FS.t -> TMPL.t -> s -> unit -> unit Lwt.t
  (** The HTTP server's start function. *)

end

val domain_of_string: string -> Types.domain
(** [domain_of_string d] parses the string [d] to build a
    domain. Should be of the form {i http://host} or {i
    https://host}. *)
