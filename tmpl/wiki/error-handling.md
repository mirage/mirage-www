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
The difference is that, depending on exactly how the threads are scheduled, a raised exception might make it back to the caller as an exception or as a failed thread.
Although both cases should be handled correctly, using the second form instead of the first is preferred as it makes the behaviour predictable.

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
5. Interfaces define a selection of *private* error types, which concrete implementations can extend.

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

System 4 removes all mention of errors from the return types; it is assumed that every function may result in an error.
Standard exceptions can be declared in the module type, while implementations of the module can define extra exceptions as needed. `sexp_of_exn` and `Printexc.to_string` can provide `Sexp.t` and `string` values for any exception.

```
module type BLOCK = sig
  exception Unimplemented
  exception Disconnected
  exception Is_read_only

  val read:
    t -> int64 -> page_aligned_buffer list ->
    unit io
```

System 5 introduces multiple error types and formatters:

```
module type BLOCK = sig
  type unimplemented
  type disconnected
  type is_read_only

  type read_error = private [>
    | `Unimplemented of unimplemented
    | `Disconnected of disconnected
  ]

  type write_error = private [> read_error |
    | `Is_read_only of is_read_only
  ]

  type error = private [> read_error | write_error ]

  val pp_error : formatter -> error -> unit

  val error_of_write_error : write_error -> error
  val error_of_read_error : read_error -> error

  val read :
    t -> int64 -> page_aligned_buffer list ->
    (int, [> read_error]) result
```

The types must be private to allow modules to add extra error types.
Each standard constructor includes an opaque payload, allowing the implementation to store extra details about each error.
The cast functions are needed because OCaml doesn't provide a way to say that one private type is a subtype of another.
[ The system 5 example is my best guess based on various mailing list comments; an advocate of this system should confirm this is what is intended. ]


Looking back at the three uses above:

- For providing human readable errors, any system except 1 will do.
- Allowing programs to detect and handle certain errors specially works best with systems 1, 4 and 5.
  System 2 only works if callers require a particular concrete implementation, breaking the abstraction.
  System 3 provides (I think) no easy way to match on the type of error.
- For signalling errors in order to trigger rollback or freeing of resources, any system will do.
  To rollback on error, a single exception handler will do with system 4, while the other systems require both an exception handler and something to detect error codes.

It is perhaps worth noting that handling specific error cases specially is extremely rare.
I don't think I've seen any examples of this feature being used with the `Error` variants in the Mirage code-base.
[ anyone have some examples? ]
In general, if code handles an exception, that's a good argument that it should have been a return code instead.
However, having the exceptions available is useful to hot-patch around problems until the API is fixed.

Systems 4 and 5 seem to be the only popular options.

System 4 (exceptions) problems:

- By the time an exception is displayed, the context for it may have been lost.
  For example, it may not be clear to the user seeing "Permission denied" what was being accessed or why.
  The `Error.tag` function can be used to attach context to an `Error.t` and the same can be done for exceptions (0install does this).

- If exceptions are always *raised* (not just returned) then it is difficult to distinguish between expected errors (e.g. network connection refused) and programming errors.
  Having expected errors returned as e.g. `Network_error of exn` avoids this problem (the caller can then simply raise it if they think it should be considered a programming error in this case).

- OCaml does not enforce having a pretty printer for every exception.
  Could we enforce that every exception is declared with `with sexp` to ensure it can be displayed?

System 5 (polymorphic variants) problems:

- There is a performance penalty to wrapping every success value in an `Ok` variant, and a cost to matching on `Error` at every step.

- Programmers often don't care about error cases when writing code. If the error is considered "unlikely" then they often insert poor handling (e.g. `assert false` or `failwith "Error!"`).
  When the error does one day occur, it will be very difficult to track down.
  When using many libraries, the error must be correctly propagated at every step (`P(error_seen) = P(one_step_correct) ^ n_steps`).

- Code that wants to take action on error (e.g. rolling back or moving to a "failed" state) must consider two code paths (error codes and exceptions).
  It is tempting to handle only one case, but they should almost always be treated identically.

- The code becomes cluttered and the system is difficult to explain to new users.

In summary, the typical failure case (lazy/wrong programmer) for system 4 is to give a specific error message without context ("I/O error writing to sector 4000 on disk X"), without saying why it was doing that.
The typical failure case for system 5 is to give the context without the specifics ("Error handling HTTP request").


#### Handling exceptions

Several people suggested that exceptions should be used only for fatal errors, need not be handled in any way, and should always simply terminate the unikernel.
The problem with this approach is that by making exceptions fatal we turn every exception used in existing OCaml code into a security vulnerability.
If exceptions are fatal then an attacker only needs to find some way of triggering some code path to throw an exception in order to launch a low-volume DoS attack.

For example, my (Thomas Leonard's) upload service used `Int64.of_string` to read the `Content-Length` header on user uploads.
If given a non-integer length it will log an exception but continue serving requests.
I consider that to be correct behaviour for this service.

Arguably, `Int64.of_string` should return an option or an error code, but it doesn't and there are plenty more cases like this.
Some are built in and hard to remove, such as out-of-memory or division-by-zero.
Many exist in libraries.
Some more examples:

- If I tried to tell the user what percentage of their file had been uploaded, they could crash my unikernel with a zero-length file.

- If I accepted JSON, they could crash it with a malformed message (Yojson's `from_string` throws).

- If I accepted XML, they could send invalid XML (xmlm throws).

- Even if an XML parser reports errors with return codes, the unicode library it uses may throw.

It is effectively impossible to write a secure (DoS-resistant) unikernel if every exception turns into a crash.

In addition to the problem of DoS attacks, stopping the unikernel suddenly also means e.g. stopping all block device access mid-flow.
For example, if the filesystem is updating the disk then it will stop part way through.
While a good journalling FS will recover the filesystem on reboot, letting an attacker crash it at will doesn't seem sensible.

In some cases a different trade off may be desirable.
A service holding top-secret documents probably should stop if an exception is thrown while handling an HTTP request (or, at least, unplug the network device and log the problem).
However, we shouldn't limit Mirage to this type of service only.

In my opinion, therefore, Mirage code must not treat exceptions as fatal and must be prepared to handle (generically) any exception.
Since Mirage code is already expected to handle the `Unknown` error return code, this shouldn't require any extra work.

I believe this is easily achieved in most cases:

- Any code that allocates a resource that must be freed manually (e.g. a grant ref) must ensure it is freed. This is usually done using a `with_*` function, or with `Lwt.finalize`.
- Any code that puts the system temporarily into an invalid state (inside a lock) must ensure it is restored to a valid state before unlocking.
- Code that runs a polling loop and invokes callbacks (e.g. an HTTP server) must catch and log any exceptions thrown by the callback, abort the operation safely (e.g. close the TCP connection) and continue processing requests.

In particular, note that:

- Code that does not cause side-effects automatically meets these requirements.
- Transactional code (that calculates a new valid state and then atomically switches to that state) automatically meets these requirements.
- It should never be necessary to catch specific exceptions to meet these requirements.

Where possible, it is desirable to provide "Strong exception safety", which provides full "commit-or-rollback" semantics.

For more information, [Exception-Safety in Generic Components: Lessons Learned from Specifying Exception-Safety for the C++ Standard Library][boost-exception-safety] is worth reading in full.

Another suggestion was to use exceptions only in synchronous code and to catch them between yields.
However, this relies on programmers remembering to catch exceptions in all cases, with no prompting, and this seems unrealistic to me.
Conceptually, if synchronous threads can return values or raise exceptions then it seems reasonable that asynchronous threads should do the same.


#### Proposal

- Document the fact that all code can raise exceptions, and that this must not break invariants or leak resources ([Basic exception safety][Exception safety]).
- Use variant types when callers are likely to need to handle individual error cases (e.g. `Not_found` should not be an exception).
- Use exceptions for all other errors (e.g. `Unknown`).
- Declare exceptions using `exception ... with sexp` (or `with sexp_of`). This ensures that values inside the exception can be displayed sensibly and logged.

If you do want to force callers to handle a particular class of cases, consider using a variant with an exception (or `Error.t`) inside.
This makes it easy for callers who don't care to turn it into an exception.
For example, an HTTP client might want to remind callers that network failures may need special handling:

```
  val get : url -> [`Ok of data | `Network_error of exn] io
```

[ There is no agreement yet on whether to have multiple error cases and match using OCaml's `#group` system, to have a single error variant (as shown above), or to use exceptions for these cases too. ThomasL: I don't have a strong opinion here, except that I think callers who don't care must be able to propagate errors easily. ]

This means, we would:

1. Convert all modules to raise exceptions rather than return error codes in cases such as `Unknown` and `Unimplemented`.
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

It may be useful to distinguish between exceptions due to bugs (e.g. assertion failure), which should log a stack trace, and exceptions that merely indicate that an operation can't go ahead (disk full, network down), which should be logged without a stack trace.

It may be useful to indicate when an error is safe to display to an untrusted client vs one only the admin should see.
"System too busy; try again later" is an example.
Normally, however, any unknown exceptions should be logged and an untrusted client given a generic "server failed" message.
It would be useful to include an opaque tag in such messages so that the error could be correlated back to the log entry if needed.

In a truly secure system, error details should be hidden not only from remote users but also from other components of the program.
This can be done using "sealed exceptions", whose payload can be read only by the logging system.

Sometimes it's useful to organise errors into a hierarchy, allowing callers to catch e.g. `Exception`, `Network_error`, `TCP_error`, `TCP_connection_refused`, etc (so that a caller choosing to catch e.g. `TCP_error` will also catch the `TCP_connection_refused` subtype).
I don't see any way to do this in OCaml.



[functor-exceptions]: http://lists.xenproject.org/archives/html/mirageos-devel/2014-07/msg00070.html
[rwo-errors]: https://realworldocaml.org/v1/en/html/error-handling.html
[Exception safety]: http://en.wikipedia.org/wiki/Exception_safety
[boost-exception-safety]: http://www.boost.org/community/exception_safety.html
