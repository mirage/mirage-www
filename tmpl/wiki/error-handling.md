[ This DRAFT document is intended to explain how error handling should work in Mirage.
  Currently, it's just my (Thomas Leonard's) opinions.
  Please add comments on the bits you disagree with.
]

#### Goals

POSIX and C generally make for very poor error handling:
the information reported to the user is just a small number stored in `errno` and
errors are easily ignored accidentally.

With Mirage, we have the opportunity to provide something much better.
OCaml's structured types and exceptions can provide rich diagnostic information that is readable to humans and to machines,
and its exhaustiveness checks mean we can force callers to consider errors where necessary.

There are three main aspects to consider:

- Providing diagnostic information to humans.
- Allowing programs to detect and handle certain errors specially.
- Indicating failure in order to abort or roll back the current operation.

Note that the last two points are very different.
Exceptions can be thrown at any point in an OCaml program and robust code must be prepared to handle this.
In particular, this (fictional) code is *wrong*:

```
  let gntref = Gntshr.get () in
  match_lwt f gntref with
  | `Ok () -> Gntshr.put gntref; return (`Ok ())
  | `Error _ as e -> Gntshr.put gntref; return e
```

If `f` throws an exception, the grant ref will be leaked.
The correct pattern is:

```
  Gntshr.with_ref f
```

This will release the resource whether `f` returns success, returns an error code or raises an exception.

#### The old/current system

There are three methods currently used in (Lwt) Mirage code to signal errors.
First, the code can raise an exception:

```
let load x = if ...
  then raise (Permission_denied "Cannot read ...")
  else return ...
```

Secondly, it can evaluate to a failed thread on error and a returned one on success:

```
let load x = if ...
  then fail (Permission_denied "Cannot read ...")
  else return ...
```

Thirdly, it can evaluate to a returned (successful) thread in all cases, containing a variant indicating success or failure:

```
let load x = if ...
  then return (`Error (Permission_denied "Cannot read ..."))
  else return (`Ok ...)
```

The first two are very similar, as if the exception raised in the first example reaches Lwt it will be turned into a failed thread.
The difference is that, depending on exactly how the threads are scheduled, a raised exception might make it back to the caller as an exception or as a failed thread. A buggy caller might fail to handle one or the other case (though using a `try_lwt` block will handle both correctly).
Therefore, using the second form instead of the first is preferred.

The Mirage interfaces generally prefer the third option.
Most of the module types in `V1` include an `error` type. Some leave it abstract, while others define it in various ways:

- `RANDOM` and `FLOW` leave it abstract.
- `ENTROPY`, `CONSOLE`, `BLOCK`, `NETWORK`, `ETHIF`, `IP`, `UDP`, `TCP` and `STACKV4` define it as a polymorphic variant.
- `KV_RO` defines it as a regular variant.
- `FS` defines it, but in terms of the abstract `block_device_error` type.

In theory, explicitly listing all possible errors and forcing callers to consider them should result in more reliable code.
In practice, it results in callers ignoring all errors.

The first problem is that there is no easy way to display an error to the user.
If you look inside any `main.ml` file you will see code like this:

```
let t3 () =
  console1 () >>= function
  | `Error e -> fail (Failure "console1")
  | `Ok console1 ->
  block1 () >>= function
  | `Error e -> fail (Failure "block1")
  | `Ok block1 ->
  return (`Ok (console1, block1))
```

Here, if the console or block devices return an error then we throw it away and report a generic error which just says which device failed, but not why.
This approach to error handling can be seen throughout the Mirage code (grepping for `Error _` will turn up quite a few).
Here's an example from `mirage-skeleton/block/unikernel.ml`, teaching new users how to redefine the bind operator to discard error details:

```
let ( >>= ) x f = x >>= function
  | `Error _ -> fail (Failure "error")
  | `Ok x -> f x
```

Another problem is that we force callers explicitly to handle errors that they would never want to handle.
For example, in `BLOCK` we have:

```
module type BLOCK = sig
  type error = [
    | `Unknown of string (** an undiagnosed error *)
    | `Unimplemented     (** operation not yet implemented in the code *)
    | `Is_read_only      (** you cannot write to a read/only instance *)
    | `Disconnected      (** the device has been previously disconnected *)
  ]

  val read:
    t -> int64 -> page_aligned_buffer list ->
    [ `Error of error | `Ok of unit ] io

  ...
```

The implication is that callers of `read` should write code to handle each case.
But how?

```
    B.read b start bufs >>= function
    | `Error (`Unknown msg) -> fail (Failure msg)
    | `Error `Unimplemented -> assert false
    | `Error `Is_read_only -> assert false
    | `Error `Disconnected -> fail (Failure "Disconnected")
    | `Ok () ->
```

We might as well have just used exceptions and left the user in peace.

```
    B.read b start bufs >>= fun () ->
```

That way, we'd also get a stack trace showing what wasn't implemented, and we might get more information about why it was disconnected.

A particular challenge for Mirage is that its types are abstract module types.
Consider the `KV_RO` type:

```
module type KV_RO = sig
  (** Static Key/value store. *)

  type error = Unknown_key of string

  val read:
    t -> string -> int -> int ->
    [ `Ok of page_aligned_buffer list | `Error of error ] io
```

For a simple in-memory store this error type allows us to represent all possible errors.
However, if we want a store backed by a block device, there is no way to pass through errors such as the `Disconnected` one above.
It is usually impossible to declare all the possible errors that an implementation of a generic interface might produce.


#### Options

Real World OCaml's [Chapter 7. Error Handling][rwo-errors] provides an excellent overview of the options for handling errors in OCaml.
In summary:

- Errors can be signalled using *error-aware return types* or with *exceptions*.
- The `Core_kernel` library provides many useful features for error handling:
  - `Error.t` is used to represent an error.
  - `Error.t` be converted to a `string`, `Sexp.t` or `exn`.
  - `Error.tag` attaches extra context to an existing error.
  - `'a Or_error.t` can hold either a result (of type `'a`) or an `Error.t`.
  - Exceptions can be declared as e.g `exception Wrong_date of Date.t with sexp`, allowing the data inside the exception to be formatted automatically (via some magic in `Sexp_lib`).

It finishes with this good advice:

> To be clear, it doesn't make sense to avoid exceptions entirely. The maxim of "use exceptions for exceptional conditions" applies. If an error occurs sufficiently rarely, then throwing an exception is often the right behavior.
>
> Also, for errors that are omnipresent, error-aware return types may be overkill. A good example is out-of-memory errors, which can occur anywhere, and so you'd need to use error-aware return types everywhere to capture those.
> **Having every operation marked as one that might fail is no more explicit than having none of them marked.**
>
> In short, for errors that are a foreseeable and ordinary part of the execution of your production code and that are not omnipresent, error-aware return types are typically the right solution.

In the case of Mirage, it is typically the case that every operation may fail and that, since the interfaces are abstract, we cannot know all the ways they may fail.
This seems like a good argument for using exceptions.

However, we should still use explicit variants for expected (non-exceptional) cases that callers will probably want to handle.
For example, `KV_RO`'s `Unknown_key` case is something code will often want to use, e.g. to provide a default value.
This probably shouldn't even be considered an error.

There are several systems we could use:

1. Interfaces define concrete error types as polymorphic variants (the current system).
2. Interfaces define abstract error types, plus functions to convert to a `string` or `sexp`.
3. All interfaces use the single general-purpose `Error.t` type.
4. Interfaces throw exceptions.

System 2 (using abstract types) has the advantage that we can support this without breaking existing APIs (updated code still satisfies the old API):

```
module type BLOCK = sig
  type error with sexp
  val error_message : error -> string

  val read:
    t -> int64 -> page_aligned_buffer list ->
    [ `Error of error | `Ok of unit ] io
```

System 3 allows callers to handle errors generically, while the `Or_error.t` provides functions to convert to a `string` or `Sexp.t` automatically:

```
module type BLOCK = sig
  val read:
    t -> int64 -> page_aligned_buffer list ->
    unit Or_error.t io
```

System 4 removes all mention of errors from the interface, while `sexp_of_exn` and `Printexc.to_string` still provide `Sexp.t` and `string` values:

```
module type BLOCK = sig
  val read:
    t -> int64 -> page_aligned_buffer list ->
    unit io
```

It may be useful to predefine some common errors (e.g. `Connection_refused`) as exceptions in `mirage-types`.

Looking back at the three uses above:

- For providing human readable errors, any system except 1 will do.
- Allowing programs to detect and handle certain errors specially works best with systems 1 and 4.
  System 2 only works if callers require a particular concrete implementation, breaking the abstraction.
  System 3 provides (I think) no easy way to match on the type of error.
- For signalling errors in order to trigger rollback or freeing of resources, any system will do.

It is perhaps worth noting that handling specific error cases specially is extremely rare.
I don't think I've seen any examples of this feature being used with the `Error` variants in the Mirage code-base.
[ anyone have some examples? ]
In general, if code handles an exception, that's a good argument that it should have been a return code instead.
However, having the exceptions available is useful to hot-patch around problems until the API is fixed.

System 4 is good for reducing code clutter, and should be slightly more efficient due to avoiding allocation of `Ok` values.

There are a couple of known problems with the automatic propagation of exceptions however:

- If a generic exception is raised then it may not be clear whether it comes from the direct module being used or from some module it is using internally.
  For example, if a `KV_RO` raises `Permission_denied` then it might mean that the user doesn't have permission to read that key, or that the `KV_RO` doesn't have permission to read the underlying block device.
  Since handling specific exceptions is rare and ambiguous cases are also rare, this is unlikely to be a problem in practice.
  It is possible to scope exceptions to modules, instead of using generic ones, if desired (see [functor-exceptions][], although it presents this feature as a possible source of confusion by having two exceptions with the same name).

- By the time an exception is displayed, the context for it may have been lost.
  For example, it may not be clear to the user seeing "Permission denied" what was being accessed or why.
  The `Error.tag` function can be used to attach context to an `Error.t` and the same can be done for exceptions (0install does this).
  Since exceptions contain stack traces, it is easy to discover where they originate and add the tagging then if missing.
  I suspect this problem will be much smaller than the problem with other systems, where the easiest (and therefore most common) thing to do is to discard the cause of the error and keep *only* the context ("Unknown error loading data").

#### Proposal

- Assume all code can raise exceptions, and that this must not break invariants or leak resources ([Basic exception safety][Exception safety]).
- Use variant types when callers are likely to need to handle individual error cases (e.g. `Not_found` should not be an exception).
- Use exceptions for all other errors.
- Declare exceptions using `exception ... with sexp` (or `with sexp_of`). This ensures that values inside the exception can be displayed sensibly and logged.

If you do want to force callers to handle a particular class of cases, consider using a variant with an exception (or `Error.t`) inside.
This makes it easy for callers who don't care to turn it into an exception.
For example, an HTTP client might want to remind callers that network failures may need special handling:

```
  val get : url -> [`Ok of data | `Network_error of exn] io
```

This means, we would:

1. Convert all modules to raise exceptions rather than return error codes.
2. Remove all `error` types from `V1.mli`.
3. List the (few) cases that need special handling as additional variants next to `Ok` (as we do now for `Eof`, for example). If there are no other cases, remove the `Ok` wrapper too.
4. Remove the `Error` cases from return types.
5. Find and fix all places where error information is being discarded.

This will, of course, break all APIs (although there's no need to do it all at once).

#### Error handling in Async

The above text describes Lwt.
An alternative is the Async library.
The two are mostly similar, but they deal with errors differently.
Consider:

```
open Lwt

let main =
  let result = Lwt_unix.sleep 0.5 >>= fun () -> fail Exit in
  catch (fun () -> result)
    (function
      | Exit -> print_endline "Caught exit"; return ()
      | ex -> raise ex
    )

let () =
  Lwt_unix.run main
```

The Lwt program above catches the exception and reports it.
`result` resolves to a failed thread and anything attempting to use the thread will see it.
In this case, the user is the `catch` function, which handles it.

However, in Async the exception is not caught:

```
open Core.Std
open Async.Std

let run () =
  let result = after (sec 0.5) >>= (fun () -> raise Exit) in
  try_with (fun () -> result) >>| function
  | Ok () -> ()
  | Error Exit -> Pervasives.print_endline "Caught exit"
  | Error ex -> raise ex

let () =
  ignore (run ());
  never_returns (Scheduler.go ())
```

Here, the raising thread was created in a dynamic context (fetched from some kind of global variable) with a "monitor", which it inherits.
When it throws the exception, the monitor is called.
In this example, the monitor is the default one, which aborts the program.
In any case, the thread waiting for the result will never be notified and cannot handle the error itself.

If we want to write modules that abstract over the differences between Lwt and Async, we'll probably need to wrap Async to provide the Lwt behaviour.
e.g.

```
module IO = struct
  let sleep x = after x >>| fun () -> Ok ()
  let catch f g =
    f () >>= function
    | Ok x -> return x
    | Error x -> g x

  let (>>=) x f = x >>= function
    | Error _ as x -> return x
    | Ok x -> f x

  let fail x = return (Error x)
  let return x = return (Ok x)
end
```

Which is at least no worse than what we're doing now.

[ Could someone familiar with Async comment on the benefits of Async's monitor system?
  It looks pretty horrible to me, but I have no experience with it. ]


#### Open issues (minor)

[ I don't think it's necessary to support these cases now, but I list them in case someone knows an easy solution. ]

It may be useful to distinguish between exceptions due to bugs (e.g. assertion failure), which should log a stack trace and possibly abort the unikernel, and exceptions that merely indicate that an operation can't go ahead (disk full, network down), which should be logged without a stack trace and should not stop the system.

It may be useful to indicate when an error is safe to display to an untrusted client vs one only the admin should see.
"System too busy; try again later" is an example.
Normally, however, any unknown exceptions should be logged and an untrusted client given a generic "server failed" message.
It would be useful to include an opaque tag in such messages so that the error could be correlated back to the log entry if needed.

In a truly secure system, error details should be hidden not only from remote users but also from other components of the program.
This can be done using "sealed exceptions", whose payload can be read only by the logging system.

Sometimes it's useful to organise errors into a hierarchy, allowing callers to catch e.g. `Exception`, `Network_error`, `TCP_error`, `TCP_connection_refused`, etc.
I don't see any way to do this in OCaml.



[functor-exceptions]: http://lists.xenproject.org/archives/html/mirageos-devel/2014-07/msg00070.html
[rwo-errors]: https://realworldocaml.org/v1/en/html/error-handling.html
[Exception safety]: http://en.wikipedia.org/wiki/Exception_safety
