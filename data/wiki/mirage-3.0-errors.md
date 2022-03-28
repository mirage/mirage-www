---
updated: 2017-02-23
author:
  name: Thomas Gazagnaire
  uri: http://gazagnaire.org
  email: thomas@gazagnaire.org
subject: Error Handling in Mirage3
permalink: mirage-3.0-errors
---

## Error Handling in Mirage3

After more than two years
[of](https://lists.xenproject.org/archives/html/mirageos-devel/2014-07/msg00069.html)
[discussion](https://github.com/mirage/mirage-www/pull/274), we
finally agreed and decided which consistent error scheme will be used
for Mirage3. This blog post describes how library developers are
supposed to expose errors and how users could handle them.

### Goals

POSIX and C generally make for very poor error handling: the
information reported to the user is just a small number stored in
`errno` and errors are easily ignored accidentally.

With Mirage, we have the opportunity to provide something much better.
OCaml's structured types and exceptions can provide rich diagnostic
information that is readable to humans and to machines, and its
exhaustiveness checks mean we can force callers to consider errors
where necessary.

There are three main aspects to consider:

- Providing diagnostic information to humans.
- Allowing programs to detect and handle certain errors specially.
- Indicating failure in order to abort or roll back the current operation.

Note that the last two points are very different. Exceptions can be
thrown at any point in an OCaml program and robust code must be
prepared to handle this. In particular, this (fictional) code is
*wrong*:

```ocaml
  let gntref = Gntshr.get () in
  match_lwt f gntref with
  | `Ok () -> Gntshr.put gntref; return (`Ok ())
  | `Error _ as e -> Gntshr.put gntref; return e
```

If `f` throws an exception, the grant ref will be leaked.
The correct pattern is:

```ocaml
  Gntshr.with_ref f
```

This will release the resource whether `f` returns success, returns an
error code or raises an exception.

### Errors vs. Exceptions

Real World OCaml's [Chapter 7. Error Handling](https://realworldocaml.org/v1/en/html/error-handling.html)
provides an excellent overview of the options for handling errors in OCaml. It
finishes with this good advice:

> To be clear, it doesn't make sense to avoid exceptions entirely. The
> maxim of "use exceptions for exceptional conditions" applies. If an
> error occurs sufficiently rarely, then throwing an exception is often
> the right behavior.
>
> Also, for errors that are omnipresent, error-aware return types may
> be overkill. A good example is out-of-memory errors, which can occur
> anywhere, and so you'd need to use error-aware return types
> everywhere to capture those.  **Having every operation marked as one
> that might fail is no more explicit than having none of them
> marked.**
>
> In short, for errors that are a foreseeable and ordinary part of the
> execution of your production code and that are not omnipresent,
> error-aware return types are typically the right solution.

In the case of Mirage, it is typically the case that every operation
may fail and that, since the interfaces are abstract, we cannot know
all the ways they may fail. This seems like a good argument for using
exceptions.

However, we still want to use explicit variants for expected
(non-exceptional) cases that callers will probably want to handle.
For example,
[KV_RO](https://mirage.github.io/mirage-kv/Mirage_kv.html#TYPEerror)'s
`Unknown_key` case is something code will often want to use, e.g. to
provide a default value. This shouldn't even be considered an error.

### Errors and Results

Since 4.03, the OCaml standard library has introduced the
[result
type](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html#TYPEresult):

```ocaml
type ('a, 'b) result = Ok of 'a | Error of 'b
```

A few useful libraries have also been released with useful
combinators on result values, including Daniel Bünzli's
[Rresult](http://erratique.ch/software/rresult/doc) and
Simon Cruanes's [Lwt_result](https://github.com/ocsigen/lwt/blob/master/src/core/lwt_result.mli).

In Mirage3, all the base components define an abstract `error` type, a
`pp_error` function to print these errors, and all the functions which
can fail return a result value. For instance, `Mirage_block_lwt`
defines a read operation as follows:

```ocaml
module type S = sig
  type error
  val pp_error: error Fmt.t
  val read: t -> int64 -> Cstruct.t list -> (unit, error) result Lwt.t
end
```

To combine multiple `read`s, while propagating read errors to the
caller, one can do:

```ocaml
open Lwt_result.Infix (* Note here that we do not open [Lwt.Infix] *)

module F (B: Mirage_block_lwt.S) = struct
  let read_twice t n bufs =
    B.read t n bufs >>= fun () ->
    B.read t n bufs
end
```

The base components can, when needed, also define more types
as long and their pretty-printer if also provided: `Mirage_block_lwt`
also defines a `write_error` type and a `pp_write_error` function.

### Errors and Abstraction

So far, we did not mention how abstract the errors should be. Most of
the time, it will not really matter, as the most common handling of
errors is to print them (using the provided `pp_error` function), or
to check whether the operation was successful (e.g. that the result is
`Ok`). In these cases, having an abstract error is perfectly fine.

However, there are some cases where it is important to know what
the error was in order to take the proper action. In this case we want
something but want something not fully abstract: welcome to [private
row
types](https://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec222).
The manual says:

> Private row types are type abbreviations where part of the structure
> of the type is left abstract.

For instance, the block `Mirage_block_lwt` actually defines the error
type as a subset of the error cases which could happen when creating a
new block device:

```ocaml
module type S = sig
  type error = private [> `Unimplemented | `Disconnected]
end
```

The `private` and `>` signs mean that an implementation of the Mirage3
block device is allowed to define an `error` type with more
values. But when this implementation is used in the context of a
Mirage3 block device, all these other cases become abstract and it is
not possible to pattern-match on these errors anymore.

For instance, the error type for [Unix
filesystem](https://github.com/mirage/mirage-fs-unix) devices is
defined as follows:

```ocaml
type fs_error = [
  | `Unix_error of Unix.error
  | `Unix_errorno of int
  | `Negative_bytes
]
type error = [ Mirage_fs.error | fs_error ]

include Mirage_fs_lwt.S with type error := error
```

The last line says that `Mirage_fs_unix` satisfies the
`Mirage_fs_lwt.S` signature but also exposes a concrete `error`
type. Users of `Mirage_fs_unix` can then pattern-match on the exact
concrete error (for instance, to do something useful when a
`Unix_error` is raised) -- used in the context of MirageOS, only the
cases defined in `Mirage_fs.error` will be visible to the user. We
strongly advocate using the same approach in your libraries, as it
brings the flexibility of using concrete types vs. proper abstraction
through composition.

### Conclusion

Mirage3 uses the `result` type pervasively, requires libraries to
provide pretty-printer for their error types and recommends using
private row types when abstract error types are not enough.

