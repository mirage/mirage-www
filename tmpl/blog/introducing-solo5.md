I'm excited to announce the release of
[Solo5](https://github.com/djwillia/solo5/tree/mirage) via mirage.io!
Solo5 is essentially a kernel library that bootstraps the hardware and
forms a base (similar to Mini-OS) from which unikernels can be built.
It runs on fully virtualized x86 hardware (e.g., KVM/QEMU), using
`virtio` device interfaces.

Importantly, Solo5 is integrated (to some extent) with the Mirage
toolstack, so the Solo5 version of the Mirage toolstack can build
Mirage unikernels that run directly on KVM/QEMU instead of Xen.  As
such, Solo5 can be considered an alternative to Mini-OS in the Mirage
stack.  [Try it out
today!](https://github.com/djwillia/solo5/tree/mirage)

In the rest of this post, I'll give a bit of motivation about why I
think the lowest layer of the unikernel is interesting and important,
as well as a rough overview of the steps I took to create Solo5.
Thanks for reading!

### Why focus so far down the software stack?

When people think about Mirage unikernels, one of the first things
that comes to mind is the use of a high-level language (OCaml).
Indeed, the Mirage community has invested lots of time and effort
producing implementations of traditional system components (e.g., an
entire TCP stack) in OCaml.  The pervasive use of OCaml contributes to
security arguments for Mirage unikernels (strong type systems are
good) and is an interesting design choice well worth exploring.

But underneath all of that OCaml goodness is a little kernel layer
written in C.  This layer has a direct impact on:

* **What environments the unikernel can run on.** Mini-OS, for
  example, assumes a paravirtualized (Xen) machine, whereas Solo5
  targets full x86 hardware virtualization with `virtio` devices.

* **Boot time.** "Hardware" initialization (or lack of it in a
  paravirtualized case) is a major factor in achieving the 20 ms
  unikernel boot times that are changing the way people think about
  elasticity in the cloud.

* **Memory layout and protection.** Hardware "features" like
  page-level write protection must be exposed by the lowest layer for
  techniques like memory tracing to be performed.  Also,
  software-level strategies like address space layout randomization
  require cooperation of this lowest layer.

* **Low-level device interfacing.** As individual devices (e.g., NICs)
  gain virtualization capabilities, the lowest-software layer is an
  obvious place to interface directly with hardware.

* **Threads/events.** The low-level code must ensure that device I/O
  is asynchronous and/or fits with the higher-level synchronization
  primitives.

The most popular existing code providing this low-level kernel layer
for is called Mini-OS.  Mini-OS was (I believe) originally written as
a vehicle to demonstrate the paravirtualized interface offered by Xen
for people to have a reference to port their kernels to and as a base
for new kernel builders to build specialized Xen domains.  Mini-OS is
a popular base for MirageOS, ClickOS, and other unikernels.  Other
software that implements a unikernel base include rumprun and OSv.

I built Solo5 from scratch (rather than adapting Mini-OS, for example)
primarily as an educational (and fun!) exercise to explore and really
understand the role of the low-level kernel layer in a unikernel.  To
provide applications, Solo5 supports the Mirage stack.  It is my hope
that Solo5 can be a useful base for others; even if only at this point
to run some Mirage applications on KVM/QEMU!

### Solo5: Building a Unikernel Base From Scratch

At a high level, there are roughly 3 parts to building a unikernel
base that runs on KVM/QEMU and supports Mirage:

* **Typical kernel hardware initialization.** The kernel must know how
  to loading things into memory at the desired locations, and prepare
  the processor to operate in the correct mode (e.g., 64-bit).  Unlike
  typical kernels, most setup is one-time and simplified.  The kernel
  must set up a memory map, stack, interrupt vectors, and provide
  primitives for basic memory allocation.  At its simplest, a
  unikernel base kernel does not need to worry about user address
  spaces, threads, or many other things typical kernels need.

* **Interact with `virtio` devices.** `virtio` is a paravirtualized
  device standard supported by some hypervisors, including KVM/QEMU
  and Virtualbox.  As far as devices go, `virtio` devices are simple:
  I was able to write (very simple/unoptimized) `virtio` drivers for
  Solo5 drivers from scratch in C.  At some point it may be
  interesting to write them in OCaml like the Xen device drivers in
  Mirage, but for someone who doesn't know OCaml (like me) a simple C
  implementation seemed like a good first step.  I should note that
  even though the drivers themselves are written in C, to connect with
  Mirage Solo5 does include some OCaml code to call out to the
  drivers.

* **Appropriately link Mirage binaries/build system.** A piece of
  software called mirage-platform performs the binding between Mini-OS
  and the rest of the Mirage stack.  Building a new unikernel base
  means that this "cut point" will have lots of undefined dependencies
  which can either be implemented in the new unikernel base, stubbed
  out, or reused.  Other "cut points" involve device drivers: the
  console, network and block devices.  Finally, the `mirage` tool
  needs to output appropriate Makefiles for the new target and an
  overall Makefile needs to put everything together.

Each one of these steps carries complexity and gotchas and I have
certainly made many mistakes when performing all of them.  The
hardware initialization process is needlessly complex, and the overall
Makefile reflects my ignorance of OCaml and its building and packaging
systems.  It's a work in progress!

### Next Steps and Getting Involved

In addition to the aforementioned clean up, I'm currently exploring
the boot time in this environment.  So far I've found that generating
a bootable iso with GRUB as a bootloader and relying on QEMU to
emulate BIOS calls to load the kernel is... inefficient.

If you find the lowest layer of the unikernel interesting, please
don't hesitate to contact me or get involved.  I've packaged the build
and test environment for Solo5 into a Docker container to reduce the
dependency burden in playing around with it.  Check out [the
repo](https://github.com/djwillia/solo5/tree/mirage) for the full
instructions!
