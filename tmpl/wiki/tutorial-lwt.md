[Lwt](http://www.ocsigen.org/lwt) is a lightweight cooperative threading library
for OCaml. A good way to understand Lwt and its use in Mirage is to write
some simple code. This document introduces the basic concepts and suggests
programs to write.

Before starting, it is important to know that Lwt has a number of
syntax extensions that are widely used in Mirage. These can look
confusing especially if you are trying to understand Lwt and Mirage at
the same time. A good way to deal with this is to first understand
Lwt without any syntax extensions and then read the syntax extension
section later in this document.

!!Tutorial

The full Lwt manual is available [elsewhere](http://ocsigen.org/lwt/manual/), but the
minimal stuff needed to get started is here.
The first useful function is the `return` statement, which constructs a constant thread:

{{
  val return: 'a -> 'a Lwt.t
}}

It is used to contruct a thread that immediately returns with the provided
value.  Once the value is wrapped in an Lwt thread, it cannot directly be 
used (as the thread may not have completed yet).  This is where `bind` comes in:

> The most important operation you need to know is bind:
>
> `val bind : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t`
>
> `bind t f` creates a thread which waits for `t` to terminates, then pass
> the result to `f`. If `t` is a sleeping thread, then `bind t f` will be a
> sleeping thread too, until `t` terminates. If `t` fails, then the
> resulting thread will fail with the same exception.

There are two important operations to compose threads: `join` and `choose`.

> `val join : unit Lwt.t list -> unit Lwt.t`
>
> `join` takes a list of threads and wait for all of them to terminate:
>
> Moreover, if at least one thread fails, `join l` will fail with the
> same exception as the first to fail, after all threads terminate.

> `val choose : 'a t list -> 'a t`
>
> `choose l` behaves as the first thread in l to terminate. If several threads are
> already terminated, one is chosen at random.

!!Sleep and join

!!!Challenge

Now write a program that spins off two threads, each of which sleep
for some amount of time, say 1 and 2 seconds and then one prints
"Heads", the other "Tails".  After both have finished, it prints
"Finished" and exits.  To sleep for some time use `OS.Time.sleep` and
to print to console use `OS.Console.log`.  Note that `OS` is a Mirage-specific
module. If you are using `Lwt` in another context, use `Lwt_unix.sleep` and
`Lwt_io.write`.

You will need to have Mirage [installed](/install) and the script `mir-unix-socket` available
in your search path.  Create a file `foo.ml` with the following content:

{{
  open Lwt
  open OS

  let main () =
      (* the guts go here *)

  let _ =
    OS.Console.log ("Hello, world! Here we go..");
    OS.Main.run (main ())
}}

Create a file `bar.mir` with the following content:

{{
  Foo
}}

This project file contains the names of all the modules to link
the final program to; in this case, just the one `Foo` module.
To compile the application, execute `mir-unix-socket bar.bin`. You can now run
your example by executing the `_build/bar.bin` file.

!!!Solution

{{
  open Lwt (* provides bind and join *)
  open OS (* provides Time, Console and Main *)

  let main () =
    bind (join [ 
      bind (Time.sleep 1.0) (fun () ->
        Console.log "Heads"; return ()
      );
            bind (Time.sleep 2.0) (fun () -> 
        Console.log "Tails"; return ()
      );
    ]) (fun () -> 
      Console.log ("Finished"); return ()
    )

  let () =
    Console.log ("Hello, world! Here we go..");
    Main.run (main ())
}}

When opening the `Lwt` module, the infix operator `>>=` is also made available.
This operator is an alternative to the `bind` function and often makes the code
more readable. E.g. consider `bind (bind (bind t f) g) h` and the operator based
equivalent expression `t >>= f >>= g >>= h`. We can rewrite the previous
solution more simply:

{{
  open Lwt (* provides >>= and join *)
  open OS (* provides Time, Console and Main *)

  let main () =
    (join [
      Time.sleep 1.0 >>= fun () -> (Console.log "Heads"; return ());
      Time.sleep 2.0 >>= fun () -> (Console.log "Tails"; return ())
     ]) >>= fun () ->
     Console.log ("Finished"); return ())

  let () =
    Console.log ("Hello, world! Here we go..");
    Main.run (main ())
}}

!!Cancelling

In order to cancel a thread, the function `cancel` (provided by the module
`Lwt`) is needed. It has type `'a t -> unit` and does exactly what it
says (except on certain complicated cases that are not in the scope of this tutorial).
A simple timeout function that cancels a thread after a given number of seconds can 
be written easily:

{{
  (* In this examples and all those afterwards, we consider Lwt and OS to be opened *)
  let timeout f t =
    Time.sleep f >>= fun () -> cancel t
}}

!!!Challenge

The `timeout` function does not allow one to use the result returned by the
thread `t`.

Modify the `timeout` function so that it returns either `None` if `t` has not
yet returned after `f` seconds or `Some v` if `t` returns `v` within `f` seconds.
In order to achieve this behaviour it is possible (but not strictly necessary)
to use the function `state` that, given a thread, returns the state it is in,
either `Sleep`, `Return` or `Fail`^[The absence of state reflecting execution
will be explained latter.].

!!!Solution

todo

!!!Challenge

Does your solution match the one given here and return after `t` seconds? If
not, you already solved this challenge and can move to the next one.

This is highly inefficient, modify the function again so that it returns `Some
v` right after `t` returns `v` instead of waiting for the timeout to expire.

!!!Solution

!!A Pipe example


!!Using Mailboxes

!!Mutexes and cooperation

With Lwt, it is often possible to avoid mutexes altogether! The web server from
the [Ocsigen](http://ocsigen.org) project uses only two, and the Mirage source code
none. In usual concurrent systems, mutexes are used to prevent two (or more) threads
executing concurrently on a given piece of data. This can happen when a thread is
preemptively interrupted and another one starts running. In Lwt, a thread executes
serially until it explicitly yields (most commonly via `bind`); for this reason, Lwt
threads are said to be [cooperative](http://en.wikipedia.org/wiki/Cooperative_multitasking#Cooperative_multitasking.2Ftime-sharing).
From the coder point of view, it means that expressions without the `Lwt.t` type
will *never* be interrupted. Thus instead of surrounding an expression with
`lock` and `unlock` statements, in `Lwt` one can simply enforce the type not to
be `Lwt.t`.

The danger associated to cooperative threading is having threads not
cooperating: if an expression takes a lot of time to compute with no cooperation
point, then the whole program hangs. The `Lwt.yield` function introduces an
explicit cooperation point. `sleep`ing obviously makes the thread  coopearates.

If locking a data structure is still needed between yield points, the `Lwt_mutex` module provides the necessary functions.

!!Operators

Here is a list of operators defined in the `Lwt` module:

{{
  let (>>=) t f = Lwt.bind t f
  let (=<<) f t = Lwt.bind t f

  let ( >> ) t f = Lwt.bind t (fun _ -> f ())

  let ( <?> ) t1 t2 = Lwt.choose [t1; t2]
  let ( <&> ) t1 t2 = Lwt.join [t1; t2]

  let (>|=) t f = Lwt.map f t
  let (=|<) f t = Lwt.map f t
}}

!!Syntax Extensions

Using Lwt does sometimes require significantly restructing code, and in particular
doesn't work with many of the more imperative OCaml control structures such as 
`for` and `while`.  Luckily, Lwt includes a comprehensive [pa_lwt](http://ocsigen.org/lwt/api/Pa_lwt)
syntax extension that makes writing threaded code as convenient as vanialla OCaml.
Mirage includes this extension by default, so you can use it anywhere you want.


!!!Anonymous Bind

If you are chaining sequences of blocking I/O, a common pattern is to write:

{{
  write stdio "Foo" >>= fun () ->
  write stdio "Bar" >>= fun () ->
  write stdio "Done"
}}

You can replace these anonymous binds with with `>>` operator instead:

{{
  write stdio "Foo" >>
  write stdio "Bar" >>
  write stdio "Done"
}}

You have to be a little careful when using this shortcut, as it only works
reliably when chaining to another function that returns an Lwt binding. If it
doesnt work, the next extension provides a neat solution.

!!!Lwt Bindings

The binding operation reverses the normal `let` binding by specifying the name
of the bound variable in the second argument. Consider a thread `e1`:

{{
  e1 >>= fun x -> e2
}}

Here, we wait for the result of `e1`, bind the result to `x` and continue into `e2`.  You can replace this with the more natural `lwt` syntax to act as a "blocking let":

{{
  lwt x = e1 in
  e2
}}

Now, the code looks like just normal OCaml code, except that we substitute `lwt` for `let`, with the effect that the call blocks until the result of that thread is available.  Lets revisit our heads and tails example from above and see how it looks when rewritten with these syntax extensions:

{{
open Lwt 
open OS

let main () =
  let heads =
    Time.sleep 1.0 >>
    return (Console.log "Heads");
  in
  let tails =
    Time.sleep 2.0 >>
    return (Console.log "Tails");
  in
  lwt () = heads <&> tails in
  Console.log "Finished";
  return ()

let () =
  Console.log ("Hello, world! Here we go..");
  Main.run (main ())
}}

Now we define two threads, `heads` and `tails`, and block until they are both complete (via the `lwt ()` and the `<&>` join operator).
If you want to print "Finished" before the previous threads are complete, just replace the `lwt ()` with `let _`, and it will not block.

!!!Exceptions and Try/Catch

One very, very important thing to remember with cooperative threading is that raising exceptions is not safe to do between yield points.
In general, you should never call `raise` directly. Lwt provides an alternative syntax:

{{
  exception Foo
  let main () =
    try_lwt
      let x = ... in
      raise_lwt Foo
    with
      |Foo -> return (Console.log "Foo raised")
}}

This looks similar to normal OCaml code, except that the caught exception has an `Lwt.t` return type appended to it.

!!!Control Flow

Lwt also provides equivalents of `for` and `while` that block on each iteration, saving you the trouble of rewriting
the code to use `bind` recursively.  Just use `for_lwt` and `while_lwt` instead; for example:

{{
  for_lwt i = 0 to 10 do
    OS.Time.sleep 1.0 >>
    return (OS.Console.log "foo")
  done
}}

There is also a `match_lwt` which will bind the result of a thread and immediately pattern-match on its value.
Thus, the two fragments of code are equivalent:

{{
  let e1 >>= function
  |true -> ...
  |false -> ...
}}

{{
  match_lwt e1 with
  |true -> ...
  |false -> ...
}}

!!How does it work

Understanding the basic principles behind `Lwt` can be helpful.

