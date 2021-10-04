When tracking down bugs or performance problems, or just trying to understand how something works, it is often useful to look at a trace of the execution of your unikernel.

As a motivating example, we'll track down a (real, but now fixed) bug in MirageOS's TCP stack.

Here's a small program that demonstrates the problem:

```OCaml
let target_ip = Ipaddr.V4.of_string_exn "10.0.0.1"

module Main (S: V1_LWT.STACKV4) = struct
  let buffer = Io_page.get 1 |> Io_page.to_cstruct

  let start s =
    let t = S.tcpv4 s in

    match_lwt S.TCPV4.create_connection t (target_ip, 7001) with
    | `Error _err -> failwith "Connection to port 7001 failed"
    | `Ok flow ->
    
    let payload = Cstruct.sub buffer 0 1 in
    Cstruct.set_char payload 0 '!';

    match_lwt S.TCPV4.write flow payload with
    | `Error _ | `Eof -> assert false
    | `Ok () ->

    S.TCPV4.close flow
end
```

This unikernel opens a TCP connection to 10.0.0.1, sends a single "!" character, and then closes the connection.
Most of the time it works, generating output similar to the following:

```
ARP: sending gratuitous from 10.0.0.2
Manager: configuration done
ARP: transmitting probe -> 10.0.0.1
ARP: updating 10.0.0.1 -> fe:ff:ff:ff:ff:ff
main returned 0
```

Occasionally, however, it hangs after getting the ARP response and doesn't send the data:

```
ARP: sending gratuitous from 10.0.0.2
Manager: configuration done
ARP: transmitting probe -> 10.0.0.1
ARP: updating 10.0.0.1 -> fe:ff:ff:ff:ff:ff
```

#### Enabling tracing

To enable tracing, pass the optional `tracing` argument to the `register` function in `config.ml`.
For example:

```OCaml
open Mirage

let main = main "Unikernel.Main" (stackv4 @-> job)
let stack console = direct_stackv4_with_default_ipv4 console tap0

let tracing = mprof_trace ~size:1000000 ()

let () =
  register "example" ~tracing [
    main $ stack default_console;
  ]
```

The size argument gives the size in bytes of the ring buffer to use.
When you run `mirage configure`, you will probably be prompted to install a version of Lwt with tracing enabled; just run the `opam pin` command provided.
This will automatically trigger a recompile of all the MirageOS libraries with tracing enabled.

To view the trace data, use [mirage-trace-viewer][].
If you don't want to compile from source, there are [pre-compiled binaries][mtv-feed] for Linux-x86_64 and Linux-armv7l (e.g. for the Cubietruck).
You can get them with 0install:

    sudo apt-get install zeroinstall-injector
    0install add mirage-trace-viewer http://talex5.github.io/mirage-trace-viewer/mtv.xml

If you compiled your MirageOS program as a Unix process, the trace data will appear in a file called `trace.ctf` (you can view the trace while the process is still running).
To view the trace using the GTK viewer, use:

    mirage-trace-viewer trace.ctf

If you don't have GTK, you can use `mirage-trace-viewer --html=htdocs ...` to create an `htdocs` directory with a JavaScript viewer.

The files can also be read by other CTF readers, such as [babeltrace][], with the appropriate [metadata][] file.

#### Tracing Xen guests

To get the trace data from a Xen unikernel, run `mirage-trace-viewer -d NAME` as root.
I use a wrapper script for this (`~/bin/sudo-mtv`):

```
#!/bin/sh
exec 0launch -w sudo mirage-trace-viewer "$@"
```

To dump the trace buffer from the Xen domain `example` to the file `trace.ctf`:

    sudo-mtv -d example -w trace.ctf

To fetch trace data from a remote Xen host (e.g. a Cubietruck board) and view it on your laptop:

    ssh mirage@cubietruck sudo-mtv -d example -w - | mirage-trace-viewer -

Tip: If your Xen guest crashes before you can read the data, put these lines in your `.xl` file:

```
on_crash = 'preserve'
on_poweroff = 'preserve'
```

#### Navigating a trace

Here's the trace for a successful run (where the message was transmitted):

<div class='trace-viewer'>
<canvas tabindex='1' id='good' style='width: 100%; height:500px'>
<noscript>Sorry, you need to enable JavaScript to see this page.</noscript>
</canvas>
</div>
[View full screen](/html/trace-viewer.html?trace=good)

Use your mouse's scroll wheel (or the buttons at the bottom) to zoom.

Time runs left to right:

* At the start (far left), the tracing system shares all the pages of its trace buffer with dom 0, allowing us to read the trace. The `gntref` counter (the red line) increases rapidly during this time.
* Next, the tracing system stores the grant ref details in XenStore, followed immediately by the TCP stack getting the network details from XenStore.
* The `gntref` metric then goes up again as the network code shares its buffer with dom0.
* Then our test code runs, opening the TCP connection and sending the data.
  The `tcp-to-ip` counter goes up here (to 1), showing where the single-byte packet is passed from the TCP buffer to the IP layer for transmission.

Horizontal black lines are Lwt threads. White regions indicate when the thread was running. Vertical black lines indicate threads creating new threads or merging with existing ones. Arrows show interactions between threads:

* A green arrow from A to B means that A resolved sleeping thread B (e.g. with `Lwt.wakeup`).
* A blue arrow from A to B means that B read the result of A.
* A red arrow is similar, but for the case where the thread failed.
* A yellow arrow from A to B means that A tried to read B but it wasn't ready yet.
  In the common case where this is followed by a blue arrow, the yellow arrow isn't shown.
* An orange arrow from A to B means that A sent some other kind of message to B.

Libraries can annotate threads with labels, which makes reading the diagrams much easier.
If a thread doesn't have a label, its unique thread ID is displayed instead.

For more information about reading the visualisation, see the blog post [Visualising an Asynchronous Monad](http://roscidus.com/blog/blog/2014/10/27/visualising-an-asynchronous-monad/).

#### Finding the bug

To find the problem, we can compare a good trace and a bad trace:

<div class='trace-viewer'>
<canvas tabindex='2' id='good-detail' style='width: 100%; height:500px'>No canvas support. </canvas>
</div>
[View full screen](/html/trace-viewer.html?trace=good-detail)

Above: a trace from a successful run. Below: a trace from a failed run.

<div class='trace-viewer'>
<canvas tabindex='3' id='bad-detail' style='width: 100%; height:500px'>No canvas support.</canvas>
</div>
[View full screen](/html/trace-viewer.html?trace=bad-detail)

Normally, when a thread doesn't do anything it is drawn only as a tiny stub in the display.
To make the problem easier to spot, I modified the test program to call `MProf.Trace.should_resolve` on the program's main thread, which adds a hint that this thread is important.
The viewer sees that it didn't resolve, and so draws it in red and extending to the far right of the display.

Looking at the good trace, three important threads are created:

1. A "TCP connect" thread to track the TCP connection (if you can't see it, click the menu button in the bottom left and search for `TCP connect` - it will highlight in yellow as you type.
2. An "ARP response" condition thread to get the MAC address from the target IP address.
3. A "ring.write" thread to track the ARP request being transmitted (you'll have to zoom in to see this).

Soon after creating these threads, the unikernel received an event on port-4, which is the network event channel.
The `Netif` driver determined this was an ack that the ARP request had been sent, and resolved the `ring.write` thread, which then triggered the page of memory containing the request to be unshared.
This then triggered the next step in the process, which was to start waiting for the "ARP response" condition to fire, creating an "ARP response" "task" thread.

Another event then arrived on port-4, which was the ARP response notification.
This resolved the "ARP response" thread, which allowed us to start the TCP connection (sending the SYN packet).
Once the remote end had ack'd the SYN, the TCP connection was ready (the `TCP connect` thread ends) and we sent the data, increasing the `tcp-to-ip` counter.

In the bad case:

- The main thread (that we annotated with `MProf.Trace.should_resolve`) appears as a long red line with `should-resolve thread never resolved` at the end.
- Looking at the start of this red thread, you can see a yellow arrow to a bind thread (indicating that the main thread was waiting for it).
- Following the yellow arrows, you'll eventually end up at a `try` thread waiting on `Wait for ARP response` (tip: to avoid losing track of where you are, you can double-click a thread to highlight it).

Following the ARP response task thread backwards, we can see that the order of the events was different.
In this case, the first event from the network is not the confirmation that the ARP request has been sent, but the notification of the ARP response. You can see that the network code now first notifies the "ARP response" condition (but nothing is waiting for it, so this is ignored). Then, confirmation of the request being sent arrives, ending the "ring.write" thread.
This triggers us to start waiting for a notification from the "ARP response" condition, but this will never arrive because the event has already happened.

Indeed, the bug is in this code in `arpv4.ml`:

```OCaml
let cond = MProf.Trace.named_condition "ARP response" in
(* printf "ARP query: %s -> [probe]\n%!" (Ipaddr.V4.to_string ip); *)
Hashtbl.add t.cache ip (Incomplete cond);
(* First request, so send a query packet *)
output_probe t ip >>= fun () ->
Lwt_condition.wait cond
```

One solution here would be to call `Lwt_condition.wait` before waiting for the result of `output_probe`.
However, a better solution (the one actually adopted) replaces the use of a condition with a simple wait thread.
A wait thread can only be resolved once, so it doesn't matter whether you check it before or after it gets its value.

#### Collecting more information

You might notice that many of the threads are unlabelled, as we haven't fully instrumented all the MirageOS libraries.
To add extra annotations, clone the appropriate library with Git, add some extra reporting, and use `opam pin` to build against your version.
If you think your annotations would be generally useful, please send a pull request.

In general, any code that uses `Lwt.wait`, `Lwt.task`, `Lwt_condition.create`, or `Lwt_mvar.create` should be changed to use the corresponding labelled version in [mirage-profile][] (e.g. `MProf.Trace.named_wait`, etc).
When Lwt is compiled without tracing support, these labels will be optimised out and have no runtime cost.


[babeltrace]: http://www.efficios.com/babeltrace
[metadata]: https://github.com/mirage/mirage-profile/blob/master/metadata
[mtv-feed]: http://talex5.github.io/mirage-trace-viewer/mtv.xml
[mirage-profile]: https://github.com/mirage/mirage-profile
[mirage-trace-viewer]: https://github.com/talex5/mirage-trace-viewer

<script type="text/javascript" src="/js/profile-examples.js"></script>
