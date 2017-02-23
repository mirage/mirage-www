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

(** HTTPS dispatcher *)

module Make
    (S: Mirage_stack_lwt.V4)
    (KEYS: Mirage_types_lwt.KV_RO)
    (FS: Mirage_types_lwt.KV_RO)
    (TMPL: Mirage_types_lwt.KV_RO)
    (Clock : Mirage_types.PCLOCK) :
sig

  val start:
    S.t -> KEYS.t ->
    FS.t -> TMPL.t -> Clock.t -> unit -> unit Lwt.t
    (** The HTTP server's start function. *)
end
