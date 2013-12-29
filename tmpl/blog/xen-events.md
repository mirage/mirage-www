This article is part of a series documenting how Mirage applications run under
[Xen](http://www.xenproject.org/). This article is about "events"; i.e. how
can an app wait for input to arrive and tell someone that output is available?

Background: Xen, domains, I/O etc
---------------------------------

A running virtual machine under Xen is known as a *domain*. A domain has
a number of virtual CPUs (vCPUs) which run until the Xen scheduler decides
to pre-empt them, or until they ask to block via a *hypercall*
(a system call to the hypervisor).
A typical
domain has no hardware access, instead it performs I/O by talking to other
privileged *driver domains* (often domain 0) via Xen-specific 
disk and network protocols. These protocols use two primitives:

 1. *granting* another domain access to your memory (which then
    may be *shared* or *copied*); and
 2. sending and receiving *events* to and from another domain via
    *event channels*.

This article focuses on how *events* work; a future article will describe how
shared memory works.

What is an event channel?
-------------------------

An *event channel* is a logical connection
between (domain_1, port_1) and (domain_2, port_2) where port_1 and port_2
are integers, like TCP port numbers or Unix file descriptors. An *event*
sent from one domain will cause the other domain to unblock (if it hasn't been
"masked").
To understand how event channels are used, it's worth comparing I/O under
Unix to I/O under Xen:

When a Unix process starts, it runs in a context with environment variables,
pre-connected file descriptors and command-line arguments. When a Xen domain
starts, it runs in a context with a
[start info page](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/lib/start_info.mli),
pre-bound event channels and pre-shared memory for console and xenstore.

A Unix process which wants to perform network I/O will normally connect sockets
(additional file descriptors) to network resources, and the kernel will take
care of talking protocols like TCP/IP. A Xen domain
which wants to perform network I/O will share memory with- and then bind event
channels to- *network driver domains*, and then exchange raw
ethernet frames. The Xen domain will contain its own TCP/IP stack
(such as
[mirage-tcpip](https://github.com/mirage/mirage-tcpip)).

When a Unix process wants to read or write data via a file descriptor
it can use select(2) to wait until data (or space) is available, and then use
read(2) or write(2), passing pointers to buffers as arguments. When a Xen domain
wants to wait for data (or space) it will block until an event arrives, and then
send an event to signal that data has been produced or consumed. Note that neither
blocking nor sending take buffers as arguments-- under Xen, data (or metadata)
is placed into shared memory beforehand: the events are simply a way to say, "look
at the shared buffers again".

How do event channels work?
---------------------------

Every domain maps a special 
[shared info](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/include/public/xen.h#L637)
page which contains bitmaps representing the state of each event channel. This
per-channel state consists of:

  * *evtchn_pending*: which means "an unprocessed event has been received, you should
    check your shared memory buffers (or whatever else is associated with this
    channel)"; and
  * *evtchn_mask*: which means "I'm not interested in events on this channel atm,
    don't bother interrupting me until I clear the mask".

Every vCPU has a
[vcpu_info](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/include/public/xen.h#L588)
record in the shared info page, which stores two relevant domain-global (not
per event channel) bits:

 * *evtchn_upcall_pending*: which means "at least one of the event channels has received an event"; and
 * *evtchn_upcall_mask*: which means "I'm actively processing events, don't bother interrupting me until I clear the mask".

Note that all Mirage guests are single vCPU and therefore we can simplify things
by relying on the (single) per-vCPU evtchn_upcall_mask rather than the fine-grained
evtchn_mask (normally a multi-vCPU guest would use the evtchn_upcall_mask to
control reentrant execution and the evtchn_mask to coalesce event wakeups).

Note the shared info page is shared between the domain and the hypervisor
without any locks, so an architecture-specific protocol must be used to access
it (usually via C macros with names like "test_and_set_bit")

When a domain wants to transmit an event, it calls the
calls the *EVTCHNOP_send* hypercall. Within Xen, this calls
[xen/common/event_channel.c:evtchn_set_pending](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/event_channel.c#L616)
which tests the evtchn_pending bit for this event channel. If it's already set then
no further work is needed and so it returns. If the bit isn't already set, then
it is set and then evtchn_mask is queried.
The evtchn_mask is always clear for
Mirage guests, so control passes to
[xen/arch/x86/domain.c:vcpu_mark_events_pending](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/arch/x86/domain.c#L2011)
which sets the per-vCPU evtchn_upcall_pending bit and then calls
[xen/arch/x86/domain.c:vcpu_kick](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/arch/x86/domain.c#L1994) which calls
[xen/common/schedule.c:vcpu_unblock](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/schedule.c#L386) which calls
[xen/common/schedule.c:vcpu_wake](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/schedule.c#L363) which finally sets the vCPU to a "runnable" state.

When a domain wishes to wait for an event,
it can either call
*SCHEDOP_block* to wait forever for any (unmasked) event, or call *SCHEDOP_poll* to wait
for an event on a small set
(specifically [less than or equal to 128](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/schedule.c#L712))
 of listed ports up to a timeout (like select(2)). Since we don't want to limit
ourselves to 128 ports, Mirage applications on Xen exclusively use SCHEDOP_block.
The 
[implementation of SCHEDOP_block](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/schedule.c#L874)
simply calls
[xen/common/schedule.c:vcpu_block_enable_events](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/schedule.c#L698)
which calls
[xen/include/asm-x86/event.h:local_event_delivery_enable](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/include/asm-x86/event.h#L36)
to clear the evtchn_upcall_mask bit
and then calls
[xen/common/schedule.c:vcpu_block](https://github.com/djs55/xen/blob/1e143e2ae8be3ba86c2e931a1ee8d91efca08f89/xen/common/schedule.c#L680) which performs a final check for incoming events and takes the vCPU offline.

How does Mirage handle Xen events?
---------------------------------

Mirage applications running on Xen are linked with
[a small C library](https://github.com/mirage/mirage-platform/tree/master/xen/runtime/kernel)
derived from
[mini-os](https://github.com/djs55/xen/tree/master/extras/mini-os). This library
takes care of initial boot: mapping the shared info page and initialising the
event channel state. Once the domain state is setup, the OCaml runtime is
initialised and the
[OCaml OS.Main.run callback](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/runtime/kernel/main.c#L47)
is evaluated repeatedly until it returns false, signifying exit.

The OCaml "OS.Main.run" callback is registered in
[mirage-platform/master/xen/lib/main.ml](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/lib/main.ml#L48) and interfaces the
[Lwt](http://ocsigen.org/lwt/) user-level thread scheduler with the Xen event system.
The main loop:

  * checks if the main thread has terminated (Lwt.poll t)
  * if it hasn't, call [mirage-platform/xen/runtime/kernel/eventchn_stubs.c:evtchn_look_for_work](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/runtime/kernel/eventchn_stubs.c#L33) to see if we have received any events
  * if there are no events, set a timer to wake us up and call *SCHEDOP_block*.

[mirage-platform/xen/runtime/kernel/eventchn_stubs.c:evtchn_look_for_work](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/runtime/kernel/eventchn_stubs.c#L33)
contains mini-os boilerplate to safely interrogate the event channel bits in the
shared info page, and copies them to a shadow array which is private to the domain.
The function returns true if there is "work to do" i.e. some of the bits in the
event channel bitmap were set.

Assuming there is "work to do",
[mirage-platform/xen/lib/activations.ml:run](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/runtime/kernel/eventchn_stubs.c#L33)
iterates over the shadow copy of the event channel bits and wakes up any Lwt
threads which have registered themselves as waiters. Typically a Mirage device
driver will repeatedly call
[mirage-platform/xen/lib/activations.mli:after](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/lib/activations.mli#L22)
as follows:
```
let rec process_events channel last_event =
  Activations.after channel last_event >>= fun latest_event ->
  ...
  process_events channel latest_event
in
process_events channel Activations.program_start
```
The Activations module keeps a counter and a condition variable per event channel,
using the condition variable to wake any threads which are already blocked and the
counter to prevent a thread from blocking just *after* an event has been received.

If there is no "work to do", then control passes to
[mirage-platform/xen/runtime/kernel/main.c:caml_block_domain](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/runtime/kernel/main.c#L30)
which sets a timer and calls *SCHEDOP_block*. When Xen wakes up the domain, control
passes first to a global
[hypervisor callback](https://github.com/mirage/mirage-platform/blob/v1.0.0/xen/runtime/kernel/hypervisor.c#L33)
which is where an OS would normally inspect the event channel bitmaps and call
channel-specific interrupt handlers.
In Mirage's case all we do is clear the vCPU's evtchn_upcall_pending flag and
return, safe in the knowledge that the *SCHEDOP_block* call will now return, and
the main OCaml loop will be executed again.

Summary
-------

Now that you understand how events work under Xen and how Mirage uses them,
what else do you need to know?
Future blog posts in this series will answer the following questions:

  * how do Xen guests share memory with each other?
  * how do the console and xenstore rings work?
  * how does the network work?
