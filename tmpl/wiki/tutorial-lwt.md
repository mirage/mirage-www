[Lwt](http://www.ocsigen.org/lwt) is a lightweight cooperative
threading library for OCaml. A good way to understand Lwt and its use
in Mirage is to write some simple code. This document introduces the
basic concepts and suggests programs to write.  Note that Lwt has a
number of syntax extensions that are widely used in Mirage. These are
introduced as you go along through the tutorial.


!!Tutorial

The full Lwt manual is available
[elsewhere](http://ocsigen.org/lwt/manual/), but the minimal stuff
needed to get started is here.  The first useful function is the
`return` statement, which constructs a constant thread:

{{
  val return: 'a -> 'a Lwt.t
}}

It is used to contruct a thread that immediately returns with the
provided value.  Once the value is wrapped in an Lwt thread, it cannot
directly be used (as the thread may not have completed yet).  This is
where `bind` comes in:

{{
  val bind: 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
}}

`bind t f` creates a thread which waits for `t` to terminate, then
passes the result to `f`. If `t` is a sleeping thread, then `bind t f`
will be a sleeping thread too, until `t` terminates. If `t` fails,
then the resulting thread will fail with the same exception.

There are two important operations to compose threads: `join` and `choose`.

{{
  val join : unit Lwt.t list -> unit Lwt.t
}}

`join` takes a list of threads and waits for all of them to terminate.
If at least one thread fails then `join l` will fail with the
same exception as the first to fail, after all threads terminate.

{{
 val choose : 'a t list -> 'a t
}}

`choose l` behaves as the first thread in l to terminate. If several
threads are already terminated, one is chosen at random.

The infix operators `<&>` and `<?>` are defined in the `Lwt` module, where
 `a <&> b` is equivalent to `join [a; b]`, and
 `a <?> b` is equivalent to `choose [a; b]`.

!!Sleep and join

!!!Challenge

Now write a program that spins off two threads, each of which sleep
for some amount of time, say 1 and 2 seconds and then one prints
"Heads", the other "Tails".  After both have finished, it prints
"Finished" and exits.  To sleep for some time use `OS.Time.sleep` and
to print to console use `OS.Console.log`.  Note that `OS` is a
Mirage-specific module, if you are using `Lwt` in another context, use
`Lwt_unix.sleep` and `Lwt_io.write`.

You will need to have Mirage [installed](/install) and the script
`mir-build` available in your search path.  Create a file `foo.ml`
with the following content and edit it:

{{
  open Lwt
  open OS

  let main () =
      (* the guts go here *)
}}


To compile the application, execute `mir-build unix-socket/foo.bin`.

You can now run your example by executing the
`_build/unix-socket/foo.bin` file.

The build system will automatically figure out all the dependencies
required, so you do not need to specify them manually.  It will also
automatically create a project file called `foo.mir` and in it it will
put the default entry point of the program in the form
`Module.function`:

{{
  Foo.main
}}

If however a different entry point (not `main`) is to be used then it
has to be explicitly specified.  This is done by putting the entry
point in the required form in a `.mir` file, say `bar.mir`.  To
compile the application, execute `mir-build unix-socket/bar.bin`.


!!!Solution

{{
  open Lwt (* provides bind and join *)
  open OS  (* provides Time, Console and Main *)

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
}}

This is `regress/lwt/heads1.ml` in the Mirage code repository.

!!!Syntax Extensions

Using Lwt does sometimes require significantly restructing code, and
in particular doesn't work with many of the more imperative OCaml
control structures such as `for` and `while`.  Luckily, Lwt includes a
comprehensive [pa_lwt](http://ocsigen.org/lwt/api/Pa_lwt) syntax
extension that makes writing threaded code as convenient as vanilla
OCaml.  Mirage includes this extension by default, so you can use it
anywhere you want.

This is a good place to introduce some of these extensions.  When
opening the `Lwt` module, the infix operator `>>=` is made available.
This operator is an alternative to the `bind` function and often makes
the code more readable. E.g. consider `bind (bind (bind t f) g) h` and
the operator based equivalent expression `t >>= f >>= g >>= h`.  We
can now rewrite the previous solution more simply:

{{
  open Lwt (* provides >>= and join *)
  open OS  (* provides Time, Console and Main *)

  let main () =
    join [
      (Time.sleep 1.0 >>= fun () -> (Console.log "Heads"; return ()));
      (Time.sleep 2.0 >>= fun () -> (Console.log "Tails"; return ()));
     ] >>= fun () ->
       Console.log "Finished";
       return ()
}}
This is `regress/lwt/heads2.ml` in the Mirage code repository.


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

!!!Lwt Bindings

The binding operation reverses the normal `let` binding by specifying the name
of the bound variable in the second argument. Consider the thread:

{{
  e1 >>= fun x -> e2
}}

Here, we wait for the result of `e1`, bind the result to `x` and
continue into `e2`.  You can replace this with the more natural `lwt`
syntax to act as a "blocking let":

{{
  lwt x = e1 in
  e2
}}

Now, the code looks like just normal OCaml code, except that we
substitute `lwt` for `let`, with the effect that the call blocks until
the result of that thread is available.  Lets revisit our heads and
tails example from above and see how it looks when rewritten with
these syntax extensions:

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
}}

This is `regress/lwt/heads_syntax.ml` in the Mirage code repository.

Here we define two threads, `heads` and `tails`, and block until they
are both complete (via the `lwt ()` and the `<&>` join operator).  If
you want to print "Finished" before the previous threads are complete,
just put the print statement (`Console.log`) before the join statement
(`... <&> ...`).


!!Cancelling

In order to cancel a thread, the function `cancel` (provided by the
module `Lwt`) is needed. It has type `'a t -> unit` and does exactly
what it says (except on certain complicated cases that are not in the
scope of this tutorial).  A simple timeout function that cancels a
thread after a given number of seconds can be written easily:

{{
  (* In this examples and all those afterwards, we consider Lwt and OS to be opened *)
  let timeout f t =
    Time.sleep f >>= fun () -> cancel t
}}

!!!Challenge

This `timeout` function does not allow one to use the result returned
by the thread `t`.

Modify the `timeout` function so that it returns either `None` if `t`
has not yet returned after `f` seconds or `Some v` if `t` returns `v`
within `f` seconds.  In order to achieve this behaviour it is possible
to use the function `state` that, given a thread, returns the state it
is in, either `Sleep`, `Return` or `Fail`.

!!!Solution

{{
  let timeout f t =
    Time.sleep f >>
    match state t with 
    | Return v -> return (Some v)
    | _        -> cancel t; return None
}}

This is used in `regress/lwt/timeout1.ml` in the Mirage code
repository.


Does your solution match the one given here and always returns after
`f` seconds, even when `t` returns within `f` seconds?

This is a good place to introduce a third operation to compose
threads: `pick`.

{{
 val pick : 'a t list -> 'a t
}}

`pick` behaves exactly like `choose` except that it cancels all other
sleeping threads when one terminates.


!!!Challenge

In a typical use of a timeout, if `t` returns before the timeout has
expired, one would want the timeout to be cancelled right away.  The
next challenge is to modify the timeout function to return `Some v`
right after `t` returns.  Of course if the timeout does expire then it
should cancel `t` and return `None`.

In order to test your solution, you can compile it to a mirage
executable and run it using the skeleton provided for the first
challenge.


!!!Solution

{{
  let timeout f t =
    let tmout = Time.sleep f in
    pick [
      (tmout >>= fun () -> return None);
      (t >>= fun v -> return (Some v));
    ]
}}
This is in `regress/lwt/timeout2.ml` in the Mirage code
repository.


!!A Pipe example

!!!Challenge

Write an echo server, reading from a dummy input generator and, for
each line it reads, writing it to the console. The server should never
stop listening to the dummy input generator. Here is a basic dummy
input generator:

{{
  let read_line () =
    OS.Time.sleep (Random.float 2.5) >>
    Lwt.return (String.make (Random.int 20) 'a')
}}

!!!Solution

{{
  let rec echo_server () =
    lwt s = read_line () in
    Console.log s;
    echo_server ()
}}

This is in `regress/lwt/echoserver1.ml` in the Mirage code
repository.



!!Using Mailboxes

Among the different modules the Lwt library provides is
`Lwt_mvar`. This module eases inter-thread communication. Any thread
can place a value in a mailbox using the `put` function; dually, the
`take` function removes a value from a mailbox and returns
it. `take`'s type, `'a Lwt_mvar.t -> 'a Lwt.t`, indicates that a call
to the function may block (and let other threads run). The function
actually returns only when a value is available in the mailbox.

Here are the needed functions from the `Lwt_mvar` module:

> `type 'a t` (the type of a mailbox variable)
>
> `val create_empty : unit -> 'a t` (`create ()` creates a new empty mailbox
> variable)
>
> `val put : 'a t -> 'a -> unit Lwt.t` (`put mvar value` puts a value into a
> mailbox variable)
>
> `val take : 'a t -> 'a Lwt.t` (`take mvar` will take any currently available
> value from the mailbox variable)

!!!Challenge

Write a small set of functions to help do pipeline parallelism. The
interface to be implemented is the following (names should give away
the appropriate semantic):

{{
  val map: ('a -> 'b Lwt.t) -> 'a Lwt_mvar.t -> 'b Lwt_mvar.t
  val split : ('a * 'b) Lwt_mvar.t -> 'a Lwt_mvar.t * 'b Lwt_mvar.t
  val filter: ('a -> bool Lwt.t) -> 'a Lwt_mvar.t -> 'a Lwt_mvar.t
}}

!!! Solution

{{
  let map f m_in =
    let m_out = Lwt_mvar.create_empty () in
    let rec map_h () =
      Lwt_mvar.take m_in   >>=
      f                    >>= fun v ->
      Lwt_mvar.put m_out v >>
      map_h ()
    in
    let t = map_h () in
    m_out


  let split mab =
    let ma = Lwt_mvar.create_empty () in
    let mb = Lwt_mvar.create_empty () in
    let rec split_h () =
      Lwt_mvar.take mab >>= fun (va, vb) ->
      Lwt.join [
          Lwt_mvar.put ma va;
          Lwt_mvar.put mb vb;
        ]               >>
      split_h ()
    in
    let t = split_h () in
    (ma, mb)


  let filter f m_in =
    let m_out = Lwt_mvar.create_empty () in
    let rec filter_h () =
      Lwt_mvar.take m_in >>= fun v ->
      f v                >>= function
      | true -> (Lwt_mvar.put m_out v >>
                 filter_h ())
      | false -> filter_h ()
    in
    let t = filter_h () in
    m_out
}}

Note that in each of the above a recursive Lwt thread is created and
will run forever.  However, if the pipline ever needs to be torn down
then this recusive thread should be cancelled.  This can be done by
modifying the above funtions to also return the `'t Lwt.t` returned by
`map_h`, `split_h` and `filter_h`, which can then be cancelled when
required.



!!!Challenge

Using the pipelining helpers, change the echo server into a string
processing server. The new version should output each line of text
uppercased (`String.uppercase` can help) after waiting for `l` seconds
where `l` is the length of the string.

!!!Solution

{{
  let read_line () =
    Lwt.return (String.make (Random.int 20) 'a')

  let wait_strlen str =
    OS.Time.sleep (float_of_int (String.length str)) >>
    Lwt.return str

  let cap_str str =
    Lwt.return (String.uppercase str)

  let rec print_mvar m =
    lwt s = Lwt_mvar.take m in
    Console.log s;
    print_mvar m

  let ( |> ) x f = f x

  let echo_server () =
    (*define mailboxes*)
    let m_input = create_empty () in
    let m_output =
      m_input |> map wait str_length |> map cap_str
    in
    (*define loops*)
    let rec read () =
      read_line ()             >>= fun s ->
      Lwt_mvar.put m_input str >>=
      feed
    in
    let rec write () =
      Lwt_mvar.take m_output >>= fun r ->
      Console.log r;
      write ()
    in
    (*starts loops*)
    (read ()) <&> (write ())
}}

This is in `regress/lwt/echoserver2.ml` in the Mirage code
repository.


!!!Challenge

To exercise all the pipelining helpers, set up an integer processing
server with the following stages:

Every second write a tupple containing a pair of small random integers
`(Random.int 1000, Random.int 1000)` into a mailbox.  Process it
through a stage that produces a tupple containing the sum and the
product of the input integers, `split` the tupple into two mvars and
for each of the mvars insert a stage that simply prints the value and
then puts it to an output mvar.  Next insert a filter stage that only
lets odd numbers through.  Finally add a stage that prints the word
"Odd" if anything reaches it.


!!!Solution

{{
  let add_mult (a, b) =
    return (a + b, a * b)

  let print_and_go str a =
    Console.log (Printf.sprintf "%s %d" str a);
    return a

  let test_odd a =
    return (1 = (a mod 2))

  let rec print_odd m =
    lwt a = Lwt_mvar.take m in
    Console.log (Printf.sprintf "Odd: %d" a);
    print_odd m

  let ( |> ) x f = f x

  let int_server () =
    let m_input = Lwt_mvar.create_empty () in
    let (ma, mm) = m_input |> map add_mult |> split in
    let _ = ma |> map (print_and_go "Add:") |> filter test_odd |> print_odd in
    let _ = mm |> map (print_and_go "Mult:") |> filter test_odd |> print_odd in
    let rec inp () =
      Lwt_mvar.put m_input (Random.int 1000, Random.int 1000) >>
      Time.sleep 1. >>
      inp () in
    inp ()
}}

This is in `regress/lwt/intserver.ml` in the Mirage code repository.



!!Mutexes and cooperation

With Lwt, it is often possible to avoid mutexes altogether! The web
server from the [Ocsigen](http://ocsigen.org) project uses only two,
and the Mirage source code none. In usual concurrent systems, mutexes
are used to prevent two (or more) threads executing concurrently on a
given piece of data. This can happen when a thread is preemptively
interrupted and another one starts running. In Lwt, a thread executes
serially until it explicitly yields (most commonly via `bind`); for
this reason, Lwt threads are said to be
[cooperative](http://en.wikipedia.org/wiki/Cooperative_multitasking#Cooperative_multitasking.2Ftime-sharing).
From the coder point of view, it means that expressions without the
`Lwt.t` type will *never* be interrupted. Thus instead of surrounding
an expression with `lock` and `unlock` statements, in `Lwt` one can
simply enforce the type not to be `Lwt.t`.

The danger associated to cooperative threading is having threads not
cooperating: if an expression takes a lot of time to compute with no
cooperation point, then the whole program hangs. The `Lwt.yield`
function introduces an explicit cooperation point. `sleep`ing
obviously makes the thread coopearates.

If locking a data structure is still needed between yield points, the
`Lwt_mutex` module provides the necessary functions.



!!!Exceptions and Try/Catch

One very, very important thing to remember with cooperative threading
is that raising exceptions is not safe to do between yield points.  In
general, you should never call `raise` directly. Lwt provides an
alternative syntax:

{{
  exception Foo
  let main () =
    try_lwt
      let x = ... in
      raise_lwt Foo
    with
      |Foo -> return (Console.log "Foo raised")
}}

This looks similar to normal OCaml code, except that the caught
exception has an `Lwt.t` return type appended to it.

!!!Control Flow

Lwt also provides equivalents of `for` and `while` that block on each
iteration, saving you the trouble of rewriting the code to use `bind`
recursively.  Just use `for_lwt` and `while_lwt` instead; for example:

{{
  for_lwt i = 0 to 10 do
    OS.Time.sleep (float_of_int i) >>
    return (OS.Console.log "foo")
  done
}}

There is also a `match_lwt` which will bind the result of a thread and
immediately pattern-match on its value.  Thus, the two fragments of
code are equivalent:

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

The core of Lwt is based on an event loop. In "standard" (non-Mirage)
settings, this loop is started using the `Lwt_main.run` function, However,
when using Mirage, the loop is automatically started using the program's
entry point (as specified in the optional `.mir` file).

Because it's based on an event loop, threads are actually very cheap in Lwt.
(Hence the name.) Sleeping actually registers an event that will wake up the
associated thread when possible. Depending on the backend, the event
registering slightly differs.


