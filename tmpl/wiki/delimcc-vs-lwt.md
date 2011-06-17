Mirage is a fully event-driven system, with no support for conventional [preemptive threads](http://en.wikipedia.org/wiki/POSIX_Threads).  Instead, programs are woken by events such as incoming network packets, and event callbacks execute until they themselves need to block (due to I/O or timers) or complete their task.

Event-driven systems are simple to implement, scalable to lots of network clients, and very hip due to frameworks like [node.js](http://nodejs.org). However, programming event callbacks directly leads to the control logic being scattered across many small functions, and so we need some abstractions to hide the interruptions of registering and waiting for an event to trigger.

OCaml has the excellent [Lwt](http://ocsigen.org) threading library that utilises a monadic approach to solving this.
Consider this simplified signature:

{{
  val return : 'a -> 'a Lwt.t 
  val bind : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
  val run : 'a Lwt.t -> 'a
}}

Threads have the type `'a Lwt.t`, which means that the thread will have a result of type `'a` when it finishes.
The `return` function is the simplest way to construct such a thread from an OCaml value.

If we then wish to use the value of thread, we must compose a function that will be called in the future when the thread completes. This is what the `bind` function above is for. For example, assume we have a function that will let us sleep for some time:

{{
  val sleep: int -> unit Lwt.t
}}

We can now use the `bind` function to do something after the sleep is complete:

{{
  let x = sleep 5 in
  let y = bind x (fun () -> print_endline "awake!") in
  run y
}}

`x` has the type `unit Lwt.t`, and the closure passed to `bind` will eventually be called with `unit` when the sleep finishes. Note that we also need a function to actually begin evaluating an Lwt thread, which is the `run` function.

!!Concerns

Mirage currently uses Lwt extensively, and we have been very happy with using it to build a network stack. However, I was surprised to hear a lot of debate at the [2011 OCaml Users Group](http://anil.recoil.org/2011/04/15/ocaml-users-group.html) meeting that Lwt is not to everyone's tastes. There are a few issues:

* The monadic style means that existing code will not just work. Any code that might block must be adapted to use `return` and `bind`, which makes integrating third-party code problematic.

* More concerningly, any potential blocking points require the allocation of a closure. This allocation is very cheap in OCaml, but is still not free. Jun Furuse notes that combinator-based systems are slower during the development of his [Planck parser](http://camlspotter.blogspot.com/2011/05/planck-small-parser-combinator-library.html).

Lwt addresses the first problem via a comprehensive [syntax extension](http://ocsigen.org/lwt/2.3.0/api/Pa_lwt) which provides Lwt equivalents for many common operations. For example, the above example with sleep can be written as:

{{
  lwt x = sleep 5 in
  print_endline "awake"
}}

The `lwt` keyword indicates the result of the expression should be passed through `bind`, and this makes it possible to write code that looks more OCaml-like. There are also other keywords like `for_lwt` and `match_lwt` that similarly help with common control flow constructs.

!!Fibers

After the meeting, I did get thinking about using alternatives to Lwt in Mirage. One exciting option is the [delimcc](http://okmij.org/ftp/continuations/implementations.html) library which implements [delimited continuations](http://en.wikipedia.org/wiki/Delimited_continuation) for OCaml.  These can be used to implement restartable exceptions: a program can raise an exception which can be invoked to resume the execution as if the exception had never happened. 
Delimcc can be combined with Lwt very elegantly, and Jake Donham did just this with the [Lwt_fiber](http://ambassadortothecomputers.blogspot.com/2010/08/mixing-monadic-and-direct-style-code.html) library. His post also has a detailed explanation of how `delimcc` works.

The interface for fibers is also simple:

{{
  val start: (unit -> 'a) -> 'a Lwt.t
  val await : 'a Lwt.t -> 'a
}}

A fiber can be launched with `start`, and during its execution can block on another thread with `await`.  When it does block, a restartable exception saves the program stack back until the point that `start` was called, and it will be resumed when the thread it blocked on completes.

!!Benchmarks

I put together a few microbenchmarks to try out the performance of Lwt threads versus fibers. The fiber test looks like this:

{{
  module Fiber = struct
    let basic fn yields =
      for i = 1 to 15000 do
        for x = 1 to yields do
          Lwt_fiber.await (fn ())
        done
      done

    let run fn yields =
      Lwt_fiber.start (fun () -> basic fn yields)
  end
}}

We invoke the run function with two arguments: a thread to use for blocking and the number of times we should yield serially (so we can confirm that an increasing number of yields scales linearly).  The Lwt version is pretty similar:

{{
  module LWT = struct
    let basic fn yields =
      for_lwt i = 1 to 15000 do
        for_lwt x = 1 to yields do
          fn ()
        done
      done
  
    let run = basic
  end
}}

We do not need to do anything special to launch a thread since we are already in the Lwt main loop, and the syntax extension makes the `for` loops like like the Fiber example above.

The choice of blocking function is important. The first test runs using a fast `Lwt.return ()` that returns immediately:

<img src="http://chart.apis.google.com/chart?cht=lxy&amp;chs=600x250&amp;chtt=Direct%20non-blocking%20overhead&amp;chco=FF0000,00FF00,0000FF,FFAA00,AA00FF,00FFFF&amp;chxt=x,x,y,y&amp;chxl=1:|number-of-yields|3:|seconds&amp;chds=a&amp;chg=10,10,1,5&amp;chd=t:50,100,200,300,400,600,800,1000|0.101,0.195,0.388,0.581,0.775,1.157,1.548,1.926|50,100,200,300,400,600,800,1000|0.095,0.188,0.371,0.553,0.737,1.104,1.469,1.836&amp;chdl=delimcc-basic-quick|lwt-basic-quick&amp;chdlp=t&amp;chls=2|2" />

The x-axis on the above graph represents the number of yields in each loop. Both `Lwt_fiber` and pure `Lwt` optimise the case where a thread returns immediately, and so this graph simply tells us that the fast path is working (which is nice!). The next test replaces the blocking function with two alternatives that force the thread to yield:

<img src="http://chart.apis.google.com/chart?cht=lxy&amp;chs=600x250&amp;chtt=Direct%20blocking%20overhead&amp;chco=FF0000,00FF00,0000FF,FFAA00,AA00FF,00FFFF&amp;chxt=x,x,y,y&amp;chxl=1:|number-of-yields|3:|seconds&amp;chds=a&amp;chg=10,10,1,5&amp;chd=t:50,100,200,300,400,600,800,1000|2.601,5.204,10.401,15.611,20.783,31.221,41.606,52.016|50,100,200,300,400,600,800,1000|1.270,2.539,5.089,7.626,10.188,15.338,20.385,25.473|50,100,200,300,400,600,800,1000|4.011,8.013,15.973,23.995,32.075,47.940,63.966,79.914|50,100,200,300,400,600,800,1000|2.433,4.861,9.692,14.543,19.702,29.579,39.458,49.260&amp;chdl=lwt-basic-slow|lwt-basic-medium|delimcc-basic-slow|delimcc-basic-medium&amp;chdlp=t&amp;chls=2|2|2|2"/>

There are two blocking functions used in the graph above:

* the "slow" version is `Lwt_unix.sleep 0.0` which forces the registration of a timeout.
* the "medium" version is `Lwt.pause ()` which causes the thread to pause and drop into the thread scheduler. In the case of `Lwt_fiber`, this causes an exception to be raised so we can benchmark the cost of using a delimited continuation.

Interestingly, using a fiber is slower than normal Lwt here, even though our callstack is not very deep.  I would have hoped that fibers would be significantly cheaper with a small callstack, as the amount of backtracking should be quite low.  Lets confirm that fibers do in fact slow down as the size of the callstack increases via this test:

{{
  module Fiber = struct
    let recurse fn depth =
      let rec sum n = 
        Lwt_fiber.await (fn ());
        match n with
        |0 -> 0
        |n -> n + (sum (n-1)) 
      in
      for i = 1 to 15000 do
        ignore(sum depth)
      done

    let run fn depth = 
      Lwt_fiber.start (fun () -> recurse fn depth)
  end
}}

The `recurse` function is deliberately not tail-recursive, so that the callstack increases as the `depth` parameter grows.  The Lwt equivalent is slightly more clunky as we have to rewrite the loop to bind and return:

{{
  module LWT = struct
    let recurse fn depth =
      let rec sum n =
        lwt () = fn () in
        match n with
        |0 -> return 0
        |n ->
          lwt n' = sum (n-1) in 
          return (n + n')
      in
      for_lwt i = 1 to 15000 do
        lwt res = sum depth in
        return ()
      done

   let run = recurse
  end
}}

We then run the experiment using the slow `Lwt_unix.sleep 0.0` function, and get this graph:

<img src="http://chart.apis.google.com/chart?cht=lxy&amp;chs=600x250&amp;chtt=Recurse%20vs%20basic&amp;chco=FF0000,00FF00,0000FF,FFAA00,AA00FF,00FFFF&amp;chxt=x,x,y,y&amp;chxl=1:|stack-depth|3:|seconds&amp;chds=a&amp;chg=10,10,1,5&amp;chd=t:50,100,200,300,400,600,800,1000|6.264,15.567,44.297,86.823,142.372,310.036,603.735,939.165|50,100,200,300,400,600,800,1000|2.601,5.204,10.401,15.611,20.783,31.221,41.606,52.016|50,100,200,300,400,600,800,1000|2.769,5.564,11.497,17.631,23.826,36.700,49.314,61.794|50,100,200,300,400,600,800,1000|4.011,8.013,15.973,23.995,32.075,47.940,63.966,79.914&amp;chdl=delimcc-recurse-slow|lwt-basic-slow|lwt-recurse-slow|delimcc-basic-slow&amp;chdlp=t&amp;chls=2|2|2|2"/>

The above graph shows the recursive Lwt_fiber getting slower as the recursion depth increases, with normal Lwt staying linear.  The graph also overlays the non-recursing versions as a guideline (`*-basic-slow`).

!!Thoughts

This first benchmark was a little surprising for me:

* I would have thought that `delimcc` to be ahead of Lwt when dealing with functions with a small call-depth and a small amount of blocking (i.e. the traffic pattern that loaded network servers see). The cost of taking a restartable exception seems quite high however.
* The fiber tests still use the Lwt machinery to manage the callback mechanism (i.e. a `select` loop and the timer priority queue). It may be possible to create a really light-weight version just for `delimcc`, but the Lwt UNIX backend is already pretty lean and mean and uses the [libev](http://software.schmorp.de/pkg/libev.html) to interface with the OS.
* The problem of having to rewrite code to be Lwt-like still exists unfortunately, but it is getting better as the `pa_lwt` syntax extension matures and is integrated into my [favourite editor](https://github.com/raphael-proust/ocaml_lwt.vim) (thanks Raphael!)
* Finally, by far the biggest benefit of `Lwt` is that it can be compiled straight into Javascript using the [js_of_ocaml](http://ocsigen.org/js_of_ocaml/) compiler, opening up the possibility of cool browser visualisations and tickets to cool `node.js` parties that I don't normally get invited to.

I need to stress that these benchmarks are very micro, and do not take into account other things like memory allocation. The standalone code for the tests is [online at Github](http://github.com/avsm/delimcc-vs-lwt), and I would be delighted to hear any feedback.

