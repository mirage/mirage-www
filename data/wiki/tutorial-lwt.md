---
updated: 2024-03-23
author:
  name: Balraj Singh
  uri:
  email: balraj.singh@cl.cam.ac.uk
subject: Getting Started with Lwt threads
permalink: tutorial-lwt
---

[Lwt](https://www.ocsigen.org/lwt) is a lightweight cooperative
threading library for OCaml. A good way to understand Lwt and its use
in MirageOS is to write some simple code. This document introduces the
basic concepts and suggests programs to write. Code for all examples
is in the `mirage-skeleton/tutorial/lwt/`
[repository](https://github.com/mirage/mirage-skeleton/tree/master/tutorial/lwt).

## Basics

The full Lwt manual is available [elsewhere](https://ocsigen.org/lwt),
but the minimal stuff needed to get started is here.

The core type in Lwt is a "thread" (also known as a "promise" in some
other systems).  An `'a Lwt.t` is a thread that should produce a value
of type `'a` (for example, an `int Lwt.t` should produce a single
`int`).  Initially a thread is _sleeping_ (the result is not yet
known). At some point, it changes to be either _returned_ (with a
value of type `'a`) or _failed_ (with an exception). Once returned or
failed, a thread never changes state again.

Lwt provides a number of functions for working with threads.  The
first useful function is `return`, which constructs a trivial,
already-returned thread:

```ocaml
# Lwt.return;;
- : 'a -> 'a Lwt.t = <fun>
```

This is useful if an API requires a thread, but you already happen to
know the value.  Once the value is wrapped in its Lwt thread, it
cannot directly be used (as in general a thread may not have
terminated yet). This is where the `>>=` infix operator (pronounced
"bind") comes in:

```ocaml
# Lwt.( >>= );;
- : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t = <fun>
```

`t >>= f` creates a thread which first waits for thread `t` to return
some value `x`, then behaves as the new thread `f x`. If `t` is a
sleeping thread, then `t >>= f` will initially be a sleeping thread
too. If `t` fails, then the resulting thread will fail with the same
exception.

If you ignore the `Lwt.t` bits in the types above, you can see that
`return` looks like the identity function and `>>=` looks like `|>`
("pipe" or "apply").  You can convert any synchronous program into an
equivalent Lwt-threaded one using just `>>=` and `return`.  For
example consider this code to input two values and add them:

```ocaml
let x =
  let a = get_input "Enter a" in
  let b = get_input "Enter b" in
  a + b
```

Removing the `let ... in ...` syntax, we could also write:

```ocaml
let x =
  get_input "Enter a" |> fun a ->
  get_input "Enter b" |> fun b ->
  a + b
```

If the `get_input` function's type is changed from `string -> int` to
the threaded-equivalent, `string -> int Lwt.t`, then our example could
be changed to:

```ocaml
open Lwt.Infix

let x =
  get_input_lwt "Enter a" >>= fun a ->
  get_input_lwt "Enter b" >>= fun b ->
  Lwt.return (a + b)
```

Note that the final result, `x`, is itself a thread now. Since we
didn't change `+` to return a thread, we must wrap the result with
`return` to give it the correct type.

Of course, the reason for using Lwt is to write programs that do more
than just behave like synchronous programs: we want to be doing
multiple things at once, by composing threads in more ways than just
"_a_ then _b_".  Two important functions to compose threads are `join`
and `choose`.

```ocaml
# Lwt.join;;
- : unit Lwt.t list -> unit Lwt.t = <fun>
```

`join` takes a list of threads and waits for all of them to
terminate. If at least one thread fails then `join l` will fail with
the same exception as the first to fail, after all threads terminate.

```ocaml
# Lwt.choose;;
- : 'a Lwt.t list -> 'a Lwt.t = <fun>
```

`choose l` behaves as the first thread in `l` to terminate. If several
threads are already terminated, one is chosen at random.

The [Lwt_list](https://ocsigen.org/lwt/latest/api/Lwt_list) module
provides many other functions for handling lists of threads.

## Challenge 1: Sleep and join

Now write a program that spins off two threads, each of which sleeps for some
amount of time, say 1 and 2 seconds and then one prints "Heads", the other
"Tails". After both have finished, it prints "Finished" and exits.

To sleep for some number of nanoseconds use the function `Mirage_sleep.ns`
declared in the interface
[Mirage_sleep](https://mirage.github.io/mirage-sleep/mirage-sleep/Mirage_sleep/index.html),
and to print to the console use `Logs.info`. Note that `Mirage_sleep`
is a Mirage-specific module; if you are using Lwt in another context,
use `Lwt_unix.sleep` and `Lwt_io.write`. (You will also need to
manually start the main event loop with `Lwt_main.run`.)

For convenience, you'll likely want to also use the
[Duration](https://github.com/hannesm/duration) library, which provides handy
functions for converting between seconds, milliseconds, nanoseconds, and other
units of time.

```ocaml
(* sleep for n seconds *)
let sleep_s n = Mirage_sleep.ns (Duration.of_sec n)
```

You will need to have MirageOS [installed](/wiki/install). Create a file
`config.ml` with the following content:

```ocaml file=files/tutorial-lwt/heads1.ml
open Mirage

let main = main ~packages:[ package "duration" ] "Unikernel" job
let () = register "heads1" [ main ]
```
Add a file `unikernel.ml` with the following content and edit it:

```ocaml
open Lwt.Infix

let start () =
  (* Add your implementation here... *)
  Logs.info (fun m -> m "Finished")
```

Assuming you want to build as a normal Unix process, compile the application with:

```sh skip
$  mirage configure -t unix
$  make depend
$  dune exec -- ./main.exe
```

If you prefer to build for another target (like `xen` or `hvt`),
change the `-t` argument to `mirage configure`.  To see the available
backends, have a look at the documentation available with `mirage
configure --help`.

### Solution

```ocaml
open Lwt.Infix

let start () =
  Lwt.join
    [
      ( Mirage_sleep.ns (Duration.of_sec 1) >|= fun () ->
        Logs.info (fun m -> m "Heads") );
      ( Mirage_sleep.ns (Duration.of_sec 2) >|= fun () ->
        Logs.info (fun m -> m "Tails") );
    ]
  >|= fun () -> Logs.info (fun m -> m "Finished")
```

This code is also found in
[tutorial/lwt/heads1/unikernel.ml][heads1_unikernel.ml] in the
[mirage-skeleton](https://github.com/mirage/mirage-skeleton) code
repository.  Build it with `mirage configure -t unix && make depend &&
make`, as described above.

## Challenge 2: Looping echo server

Write an echo server that reads from a dummy input generator and, for
each line it reads, writes it to the console. The server should stop
after reading 10 lines.

Hint: it's easier to convert a program to use Lwt if you write loops
in a functional style (using tail recursion) rather than using special
syntax (e.g. `while` and `for`).

For convenience, here is a `config.ml` which you might use for this exercise:

```ocaml file=files/tutorial-lwt/echo_server.ml
open Mirage

let main =
  let packages = [ package "duration"; package ~max:"0.2.0" "randomconv" ] in
  main ~packages "Unikernel" job

let () = register "echo_server" [ main ]
```

You might notice that it's very similar to the previous example
`config.ml`, but it requires an extra package `randomconv`.
`randomconv` has convenience functions for dealing with random data,
which this challenge asks you to do.  Here is a basic dummy input
generator you can use for testing:

```ocaml
let read_line () =
  Mirage_sleep.ns (Duration.of_ms (Randomconv.int ~bound:2500 generate))
  >|= fun () -> String.make (Randomconv.int ~bound:20 Mirage_crypto_rng.generate) 'a'
```

By the way, the `>|=` operator ("map") used here is similar to `>>=`
but automatically wraps the result of the function you provide with
`return`. It's used here because `String.make` is synchronous (it
doesn't return a thread). We could also have used `>>=` and `return`
together to get the same effect.

### Solution

```ocaml
open Lwt.Infix

let read_line () =
  Mirage_sleep.ns (Duration.of_ms (Randomconv.int ~bound:2500 Mirage_crypto_rng.generate))
  >|= fun () -> String.make (Randomconv.int ~bound:20 Mirage_crypto_rng.generate) 'a'

let start () =
  let rec echo_server = function
    | 0 -> Lwt.return ()
    | n ->
        read_line () >>= fun s ->
        Logs.info (fun m -> m "%s" s);
        echo_server (n - 1)
  in
  echo_server 10
```

This is in [tutorial/lwt/echo_server/unikernel.ml][echo_server_unikernel.ml] in
the [mirage-skeleton](https://github.com/mirage/mirage-skeleton) code repository.

Note: Lwt's `>>=` operator does the threaded equivalent of a tail-call
optimisation, so this won't consume more and more memory as it runs.


## The main event loop

Understanding the basic principles behind Lwt can be helpful.

The core of Lwt is based on an event loop. In "standard" (non-MirageOS) settings,
this loop is started using the `Lwt_main.run` function. However, when using
MirageOS, the loop is automatically started by the `main.ml` file autogenerated
by the `mirage` command-line tool.

Because it's based on an event loop, threads are very cheap in Lwt
when compared to preemptive system threads. Sleeping registers an
event that will wake up the associated thread when possible.


## Mutexes and cooperation

With Lwt, it is often possible to avoid mutexes altogether! The web
server from the [Ocsigen](https://ocsigen.org) project uses only two,
for example. In usual concurrent systems, mutexes are used to prevent
two (or more) threads executing concurrently on a given piece of
data. This can happen when a thread is preemptively interrupted and
another one starts running. In Lwt, a thread executes serially until
it explicitly yields (most commonly via `>>=`); for this reason, Lwt
threads are said to be
[cooperative](https://en.wikipedia.org/wiki/Cooperative_multitasking#Cooperative_multitasking.2Ftime-sharing).

For example, consider this code to generate unique IDs:

```ocaml
let next =
  let i = ref 0 in
  fun () ->
    incr i;
    !i
```

It is entirely safe to call this from multiple Lwt threads, since we
know that `incr`, the only function we call, isn't going to somehow
recursively call `next` while it's running.

Calling `x >>= f` (and similar) will run other threads while waiting
for `x` to terminate, and these may well invoke the function again, so
you can't assume things won't be modified across a bind.  For example,
this version is _not_ safe:

```ocaml
let next =
  let i = ref 0 in
  fun () ->
    incr i;
    foo () >|= fun () ->        (* Another thread might call [next] here *)
    !i
```

Of course, this is true of _any_ function that might, directly or
indirectly, call `next`, not just Lwt ones.

The obvious danger associated with cooperative threading is having
threads not cooperating: if an expression takes a lot of time to
compute with no cooperation point, then the whole program hangs. The
`Lwt.yield` function introduces an explicit cooperation
point. `sleep`ing also obviously makes the thread cooperate.

If locking a data structure is still needed, the `Lwt_mutex` module
provides the necessary functions. To obtain more information on thread
switching (and how to prevent it) read the Lwt mailing list archive:
[Lwt_stream, thread switch within push
function](https://sympa.inria.fr/sympa/arc/ocsigen/2011-09/msg00029.html)
which continues
[here](https://sympa.inria.fr/sympa/arc/ocsigen/2011-10/msg00001.html).


## Spawning background threads

If you want to spawn a thread without waiting for the result, use `Lwt.async`:

```ocaml
let spawn () =
  Lwt.async (fun () ->
    Mirage_sleep.ns (Duration.of_sec 10) >|= fun () ->
    Logs.info (fun m -> m "Tails")
  )
```

**Note**: do _not_ do `let _ = my_background_thread ()`. This ignores
  the result of the thread, which means that if it fails with an
  exception then the error will never be reported.

`Lwt.async` reports errors to the user's configured
`Lwt.async_exception_handler`, which may or may not terminate the
unikernel depending on how it has been configured.

It is often better to catch such exceptions and log them with some
contextual information.  Here's some real Mirage code that spawns a
new background thread to handle a new frame received from the network.
The log message includes the exception it caught, a dump of the
troublesome frame and, like all log messages, information about when
it occurred and in which module.

```ocaml
(* Handle a frame of data from the network... *)
let process fn data =
  Lwt.async (fun () ->
    Lwt.catch (fun () -> fn data)
      (fun ex ->
         Logs.err (fun f -> f "uncaught exception from listen callback \
                              while handling frame:@\n%a@\nException: @[%s@]"
                              pp_frame data (Printexc.to_string ex));
         Lwt.return ()
      )
  )
```

By the way, the reason `async` and `catch` take functions that create
threads rather than just plain threads is so they can start the thread
inside a `try .. with` block and so handle OCaml exceptions
consistently.  Be careful not to disable this safety feature by
accident - consider:

```ocaml
let test1 () =
  let t = raise (Failure "early failure") in
  Lwt.catch (fun () -> t)
    (fun ex -> print_endline "caught exception!"; Lwt.return ())

let test2 () =
  let t = Mirage_sleep.ns (Duration.of_sec 1) >>= fun () -> raise (Failure "late failure") in
  Lwt.catch (fun () -> t)
    (fun ex -> print_endline "caught exception!"; Lwt.return ())
```

Because `test1`'s `t` raises an exception immediately (without waiting
for a sleeping thread and thus getting added to an event queue),
`test1` will exit with an exception before even reaching the `catch`
function.

However, `test2`'s `t` blocks first. In this case, the sleeping `t` is
passed to `catch`, which handles the exception.

Moving the `let t = ` inside the `catch` callback avoids this problem
(as does using `Lwt.fail` instead of `raise`).

## Error handling

In Mirage code, we typically distinguish two types of error:
programming errors (bugs, which should be reported to the programmer
to be fixed) and expected errors (e.g. network disconnected or invalid
TCP packet received).  We try to use the type system to ensure that
expected errors are handled gracefully.

### Use result for expected errors

For expected errors, you should use the `result` type, which provides
`Ok` and `Error` constructors.  This is a built-in in OCaml 4.03 and
available from the `result` opam package for older versions.

Here's an example that calls `read_arg` twice and returns the sum of
the results on success. If either `read_arg` returns an error then
that is returned immediately.

```ocaml
let example () =
  read_arg () >>= function
  | Error _ as e -> Lwt.return e
  | Ok a ->
  read_arg () >>= function
  | Error _ as e -> Lwt.return e
  | Ok b ->
  Lwt.return (Ok (a + b))
```

It is often useful to provide some helpers to handle this pattern
(using Lwt threads and result types together) more simply:

```ocaml
let ok x = Lwt.return (Ok x)

let (>>*=) m f =
  m >>= function
  | Error _ as e -> Lwt.return e
  | Ok x -> f x

let example () =
  read_arg () >>*= fun a ->
  read_arg () >>*= fun b ->
  ok (a + b)
```

### Use raise or fail for bugs

If a bug is detected, you should raise an exception. In threaded code
you should use `Lwt.fail`, although Lwt will catch exceptions and turn
them into failures automatically if you forget.

### Catching exceptions

You shouldn't normally need to catch specific exceptions (it would be
better to use an `Error` return in that case), but it is sometimes
necessary.

The Lwt-equivalent of

```ocaml skip
try foo x
with
| Error_you_want_to_catch -> (* handle error here *)
```

is

```ocaml skip
 Lwt.catch
  (fun () -> foo x)
  (function
   | Error_you_want_to_catch -> (* handle error here *)
   | ex -> Lwt.fail ex  (* Pass others on *)
  )
```

### Finalize

Depending on how the unikernel is set up, an exception may or may not
be fatal. In general, if you allocate a resource that won't be
automatically freed by the garbage collector then you should use
`Lwt.finalize` to ensure it is cleaned up whether the function using
it succeeds or not:

```ocaml skip
  let r = Resource.alloc () in
  Lwt.finalize
    (fun () -> use r)
    (fun () -> Resource.free r)
```

To make it harder to get this wrong, it is a good idea to provide a
`with_` function, so users can just do:

```ocaml skip
  with_resource (fun r -> use r)
```


## User-defined threads

You can create a thread that sleeps until you explicitly make it
return a result with `Lwt.wait`, which returns a thread and a _waker_:

```ocaml
let invoke_remote msg =
  let t, waker = Lwt.wait () in
  let id = new_id () in
  on_response_to id (fun resp -> Lwt.wakeup waker resp);
  send_request id msg;
  t
```

This is mainly useful when interacting with external processes (as in
this example), or libraries that don't support Lwt directly.


## Cancelling

In order to cancel a thread, the function `cancel` (provided by the
module Lwt) is needed. It has type `'a t -> unit` and does exactly
what it says (except on certain complicated cases that are not in the
scope of this tutorial). A simple timeout function that cancels a
thread after a given number of seconds can be written easily:

```ocaml
let timeout delay t =
  Mirage_sleep.ns delay >|= fun () -> Lwt.cancel t
```

### Challenge 3: Timeouts

This `timeout` function does not allow one to use the result returned
by the thread `t`.

Modify the `timeout` function so that it returns either `None` if `t`
has not yet returned after `delay` seconds or `Some v` if `t` returns
`v` within `delay` seconds. In order to achieve this behaviour it is
possible to use the function `Lwt.state` that, given a thread, returns
the state it is in, either `Sleep`, `Return` or `Fail`.

You can test your solution with this application, which creates a
thread that may be cancelled before it returns:

```ocaml
let timeout s t : string option Lwt.t = failwith "TODO"

let start () =
  let t =
    Mirage_sleep.ns (Duration.of_ms (Randomconv.int ~bound:3000 Mirage_crypto_rng.generate))
    >|= fun () -> "Heads"
  in
  timeout (Duration.of_sec 2) t >|= function
  | None -> Logs.info (fun m -> m "Cancelled")
  | Some v -> Logs.info (fun m -> m "Returned %S" v)
```

For convenience, here is a `config.ml` which you might use for this exercise:

```ocaml file=files/tutorial-lwt/timeout1.ml
open Mirage

let main =
  main
    ~packages:[ package "duration"; package ~max:"0.2.0" "randomconv" ]
    "Unikernel" job

let () = register "timeout1" [ main ]
```

### Solution

```ocaml
open Lwt.Infix

let timeout delay t =
  Mirage_sleep.ns delay >>= fun () ->
  match Lwt.state t with
  | Lwt.Sleep ->
      Lwt.cancel t;
      Lwt.return None
  | Lwt.Return v -> Lwt.return (Some v)
  | Lwt.Fail ex -> Lwt.fail ex

let start () =
  let t =
    Mirage_sleep.ns (Duration.of_ms (Randomconv.int ~bound:3000 Mirage_crypto_rng.generate))
    >|= fun () -> "Heads"
  in
  timeout (Duration.of_sec 2) t >|= function
  | None -> Logs.info (fun m -> m "Cancelled")
  | Some v -> Logs.info (fun m -> m "Returned %S" v)
```

This solution and application are found in
[tutorial/lwt/timeout1/unikernel.ml][timeout1_unikernel.ml] in the
repository.

Does your solution match the one given here and always returns after
`f` seconds, even when `t` returns within `delay` seconds?

This is a good place to introduce a third operation to compose threads: `pick`.

```ocaml
# Lwt.pick ;;
- : 'a Lwt.t list -> 'a Lwt.t = <fun>
```

`pick` behaves exactly like `choose` except that it cancels all other
sleeping threads when one terminates.

### Challenge 4: Better timeouts

In a typical use of a timeout, if `t` returns before the timeout has
expired, one would want the timeout to be cancelled right away. The
next challenge is to modify the timeout function to return `Some v`
right after `t` returns. Of course if the timeout does expire then it
should cancel `t` and return `None`.

In order to test your solution, you can compile it to a mirage
executable and run it using the skeleton provided for the previous
challenge.


### Solution

```ocaml
let timeout delay t =
  let tmout = Mirage_sleep.ns delay in
  Lwt.pick [
    (tmout >|= fun () -> None);
    (t >|= fun v -> Some v);
  ]
```

Found in [lwt/tutorial/timeout2/unikernel.ml][timeout2_unikernel.ml]
in the repository.

### Warning

The `cancel` function should be used very sparingly, since it
essentially throws an unexpected exception into the middle of some
executing code that probably wasn't expecting it.  A cancel that
occurs when the thread happens to be performing an uncancellable
operation will be silently ignored.

A safer alternative is to use
[Lwt_switch](https://ocsigen.org/lwt/latest/api/Lwt_switch).  This
means that cancellation will only happen at well defined points,
although it does require explicit support from the code being
cancelled.  If you have a function that only responds to cancel, you
might want to wrap it in a function that takes a switch and cancels it
when the switch is turned off.

## Other Lwt features

Lwt provides many more features. See [the
manual](https://ocsigen.org/lwt/) for details. However, the vast
majority of code will only need the basic features described here.

[echo_server_unikernel.ml]: https://github.com/mirage/mirage-skeleton/blob/master/tutorial/lwt/echo_server/unikernel.ml
[heads1_unikernel.ml]: https://github.com/mirage/mirage-skeleton/blob/master/tutorial/lwt/heads1/unikernel.ml
[heads2_unikernel.ml]: https://github.com/mirage/mirage-skeleton/blob/master/tutorial/lwt/heads2/unikernel.ml
[timeout1_unikernel.ml]: https://github.com/mirage/mirage-skeleton/blob/master/tutorial/lwt/timeout1/unikernel.ml
[timeout2_unikernel.ml]: https://github.com/mirage/mirage-skeleton/blob/master/tutorial/lwt/timeout2/unikernel.ml
