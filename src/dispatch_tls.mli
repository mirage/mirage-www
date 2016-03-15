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

(** The HTTP dispatcher. *)
module Make
    (S: V1_LWT.STACKV4)
    (KEYS: V1_LWT.KV_RO)
    (C: V1_LWT.CONSOLE)
    (FS: V1_LWT.KV_RO)
    (TMPL: V1_LWT.KV_RO)
    (Clock : V1.CLOCK) :
sig

  val start:
    S.t -> KEYS.t ->
    C.t -> FS.t -> TMPL.t -> unit -> unit -> unit Lwt.t
    (** The HTTP server's start function. *)
end
