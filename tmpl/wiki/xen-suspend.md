This article is part of a series documenting how Mirage applications run under
[Xen](http://www.xenproject.org/). This article is about suspend, resume and
live migration.

#### Background:

One of the particularly important advantages of using virtual machines
over physical machines to run your operating systems is that
management of VMs is simpler and more powerful than managing physical
computers. One new tool in the management toolkit is that of
suspending and resuming to a state file. In many ways equivalent to
shutting the lid on a laptop and having it go to sleep, a VM can be
suspended such that it no longer consumes any memory or CPU resources
on its host, and resumed at a later point when required. Unlike a
laptop, the state of the virtual machine is encapsulated in a state
file on disk, which can be copied if you want to take a backup,
replicated many times if you want to have multiple instances of your
VM running, or copied to another physical host if you would like to
run it elsewhere. This operation also forms the basis of live
migration, where a running VM has its state replicated to another
physical host in such a way that it's execution can be stopped on the
original host and almost immediately started on the destination, and
users of the services provided by that VM are none the wiser.

For fully virtualised VMs, doing this is actually relatively
straightforward. The VM is stopped from executing, then the memory
is saved to disk, and the state of any device emulator (qemu, in
xen's case) is also persisted to disk. To resume, load the qemu
state back in, restore the memory, and unpause your domain. The
OS within the VM continues running, unaware that anything has
changed.

However, most operating systems inside VMs have software installed
that is aware that it is running in a VM, and generally speaking, this
is where work is required to ensure that these components survive a
suspend and resume. In the case of the Mirage Xen unikernels, it is
mainly the IO devices that need to be aware of the changes that happen
over the course of the operation. Since our unikernels are not fully
virtualised but are paravirtualised kernels, there is also some
infrastructure work that is required. The aim of this page is to
document how these operations work.

#### Philosophy

The guiding principle in this work is to minimise the number of
exceptional conditions that have to be handled. In some cases,
application must be made aware that they have gone through a
suspend/resume cycle - for example, anything that is communicating
with xenstore. However, in most cases, the application logic
doesn't have to be aware of anything in particular happening.
For example, the block and network layers can reissue requests that were
in flight at the time of the suspend, and therefore any applications
using these can carry on without any special logic required.

#### Walkthrough

To explain the process of suspend and resume in Mirage Xen guests,
we will walk though the various operations in sequence.

#### Suspend

The suspend example in the [mirage-skeleton](https://github.com/mirage/mirage-skeleton) repository
contains the control logic needed to get the guest to be able to
suspend, and is therefore a good place to start looking.
The first thing that happens when a suspend is requested is that the
toolstack organising the operation will signal to the guest that it
should begin the process. This can be done via several mechanisms, but
the one supported in mirage today is by writing a particular key to
xenstore:

    /local/domain/<n>/control/shutdown = "suspend"

The code that watches for this path is
[here](https://github.com/mirage/mirage-skeleton/blob/b9729f90cfd2c0ddf39a1217749440f2a9288090/suspend/mirage_guest_agent.ml#L17).
The guest then acknowledges this by
[removing the key](https://github.com/mirage/mirage-skeleton/blob/b9729f90cfd2c0ddf39a1217749440f2a9288090/suspend/mirage_guest_agent.ml#L21).
It then jumps to the suspend code in
[sched.ml](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/lib/sched.ml#L32).

The first thing that happens there is that we call the Xenstore
library to
[suspend Xenstore](https://github.com/mirage/ocaml-xenstore/blob/master/client/xs_client_lwt.ml#L227). This
works by waiting for any in-flight requests to be responded to, then
cancelling any threads that are waiting on watches. These have to be
cancelled because watches rely on state in the xenstore daemon and
therefore have to be reissued (potentially with different paths) when the VM resumes.

Then, the
[grant tables are suspended](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/lib/sched.ml#L35)
via the call to Gnt.suspend, which ends up calling a
[c function](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/kernel/gnttab_stubs.c#L164)
in the mirage kernel code. The main reason for calling this is that
the mechanism by which the grant code works is via shared memory
pages, and these pages are [owned by xen](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/xen/common/grant_table.c#L1239) and not by the domain itself,
which causes problems when suspending the VM as we will see shortly.
Although the grant pages are mapped on demand, and thus could be
remapped before we've finished, this is fine as
we are actually now in a non-blocking part of the suspend code, and no other
Lwt threads will be scheduled.

At this point we call the C function in
[sched_stubs.c](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/kernel/sched_stubs.c#L48).
The first thing done there is to rewrite two fields in the start\_info
page: The MFNs of the xenstore page (store\_mfn) and of the console
page (console\_mfn) are turned into PFNs. This is done so that when
the guest is resumed, xenstored and xenconsoled can be given the pages
that the guest is expecting to talk to them on. It is the restore code in
libxc where the [remapping takes place](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/tools/libxc/xc_domain_restore.c#L2035).

We then [unmap the shared_info page](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/kernel/sched_stubs.c#L59).
This is required because the shared_info page again belongs to
xen rather than to the guest, in a similar fashion to the grant
pages. The page is allocated [during domain creation](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/xen/arch/x86/domain.c#L543).

We are now in a position to do the [actual suspend hypercall](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/kernel/sched_stubs.c#L62).
Interestingly, the suspend hypercall is defined in the header as a
[three parameter call](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/include/mini-os/x86/hypercall-x86_64.h#L293),
but the implementation in xen [ignores the 3rd parameter 'srec'](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/xen/common/schedule.c#L924).
This is actually used by libxc to [locate the start_info page](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/tools/libxc/xc_domain_save.c#L1882).
Also of note is that xen will always return success when the domain
has suspended, but the hypercall has the notion of being 'cancelled',
by which it means the guest has woken up in the same domain as it
was when it called the hypercall. This is achieved by having libxc
[alter the VCPU registers](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/tools/libxc/xc_resume.c#L105) on resume.

At this point, the domain will now be shutdown with reason 'suspend',
There is still work that needs to be done however. PV guests have
pagetables that reference the real MFNs rather than PFNs, so when
the guest is resumed into a different area of a hosts memory,
these will need to be rewritten. This is done by [canonicalizing](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/tools/libxc/xc_domain_save.c#L420)
the pagetables, which in this context means replacing the MFNs with
PFNs. Since the function that maps MFNs to PFNs is only partial,
this fails if any of the MFNs are outside of the domain's memory.
This is the reason that all foreign pages such as the grant table
pages and the shared info page needed to be unmapped before
suspending.

We are now in a position to write the guests memory to disk in
the suspend image format. If a device emulator (qemu) was running,
it would also have its state dumped at this point ready to be
resumed later.

#### Resume

When the VM is resumed, libxc loads the saved image back into memory.
It then locates the pagetables, and 'uncanonicalizes' them back from
PFNs to the new MFNs.
The next task is to 
rewrite the VCPU registers to pass back the suspend return code as
mentioned previously and then we are ready to unpause the new domain. At this point,
control is handed back to the mirage guest as if the hypercall has just
returned. At this point, the domain is close to the state of a cleanly
started guest, and so we have to [reinitialize](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/kernel/sched_stubs.c#L69) many of the same things
that are done on startup, including enabling event delivery, initialising
the timers and so on.

We then return to the ocaml code, and
[increment the generation count of the event channels](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/lib/sched.ml#L39), which is explained below.
Then, we
[resume the grant tables](https://github.com/xapi-project/ocaml-xen-lowlevel-libs/blob/ac112b963a3d91cd3ceb414bb5dc0b723b761b2b/lib/gnt.ml#L277),
which currently is a
[no-op](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/runtime/kernel/gnttab_stubs.c#L171)
as the table is
[mapped on first (re)use](https://github.com/xapi-project/ocaml-xen-lowlevel-libs/blob/ac112b963a3d91cd3ceb414bb5dc0b723b761b2b/lib/gnt.ml#L277).
The activations thread is then
[restored](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/lib/activations.ml#L95),
and we then
[restore Xenstore](https://github.com/mirage/mirage-platform/blob/a47758c696797498e3eb7f3aac90830e2993090d/xen/lib/xs.ml#L89). This
is done in this order to satisfy interdependencies - activations need
event channels working, xenstore needs grant tables and
activations. Once this is done we can move on to a more generic set of resume items: we iterate through a list of other post-resume
tasks, populated by other modules (such as [mirage-block-xen](https://github.com/mirage/mirage-block-xen) which are currently assumed to be dependency free.

An example of a resume hook can be seen in the block driver
package, which is added when the module initialises.
It registers a [callback](https://github.com/mirage/mirage-block-xen/blob/master/lib/blkfront.ml#L339) that
iterates through the list of connected devices and re-plugs them.
It then calls [shutdown](https://github.com/mirage/shared-memory-ring/blob/61fe10539b0783ab57f84fe20a25dde9b6018ade/lwt/lwt_ring.ml#L90)
which wakes up every thread waiting for a response with an
exception, and also any thread that is waiting for a free slot.
These exceptions are handled back in [mirage-block-xen](https://github.com/mirage/mirage-block-xen/blob/master/lib/blkfront.ml#L232),
which simply retries the whole operation, being careful to use the
refreshed information about the backend.

The only thread that might possibly be running is the
[service thread](https://github.com/mirage/mirage-block-xen/blob/master/lib/blkfront.ml#L78)
that takes responses from the ring and demultiplexes them, and this
thread will be killed when it attempts to wait on the
[event channel](/wiki/xen-events). Whenever an event channel is bound,
we pair up the integer event channel number with a 'generation count'
that is incremented on resume. Whenever the mirage guest attempts to
wait for a signal from an event channel, the generation count is
checked, and a stale generation results in a Lwt thread failure. The
generation count is _not_ checked when attempting to notify via an
event channel, as this is a benign failure - it is only if we try to
wait for a notification that the error occurs. Any threads that were
already waiting at the point the domain suspended will be killed on
resume by the
[activations](https://github.com/mirage/mirage-platform/blob/b5641b343c2bfbd1048d124ee0b77e2b051588dd/xen/lib/activations.ml#L96)
logic. In the case of the block device, this error mode is handled by
simply letting the thread die. A new one will have been set up during
the resume as part of the replug.

#### Migration

Live migration also uses this mechanism to move a running VM from one
host to another with very little downtime. In this case, when the
migration begins, the guest is switched to [log-dirty](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/tools/libxc/xc_domain_save.c#L955) mode, where the
hypervisor starts to track which of the guests pages have been written
to. The toolstack can then iteratively go through these pages and
send them to the destination using the same protocol as suspending to
disk, but this time unmarshalling them straight back into memory. When it [decides](https://github.com/mirage/xen/blob/8940a13d6de1295cfdc4a189e0a5610849a9ef59/tools/libxc/xc_domain_save.c#L1537) it has done enough iteratively, it then invokes the
suspend logic above and sends through only the last few dirty
pages, which will be much faster than the entire memory image. The
resume logic is then invoked and the domain starts running again.





