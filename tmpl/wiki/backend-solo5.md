# Solo5

Solo5 is an execution environment and associated tooling for running
unikernels, that provides access to a variety of secure sandboxing
technologies (e.g. hardware virtualization, seccomp) and advanced
facilities for efficient debugging. Mirage unikernels are one of Solo5's
well-supported targets, though Solo5 has a broader focus.

As an example, a developer may build a MirageOS unikernel using the Solo5
backend.  The mirage build process would use Solo5 building tools to create
a sandbox-agnostic binary. The developer would then choose a specific
sandbox to execute this binary in, for example the Solo5-KVM monitor.

# Current status


Building a unikernel, Mirage outputs an executable, a VM image
or a `ukvm` image. Both images can be directly executed on their respective
monitor. The `ukvm` image can be executed by the solo5-ukvm monitor.

MirageOS and IncludeOS can both build VM and ukvm images. Rumprun support is in
progress.

The only supported monitors are solo5-ukvm (ukvm-bin) and QEMU (virtio).

Solo5 doesn't currently support having a sandbox-agnostic unikernel binary. The
building process does not have an intermediate step which generates this
unikernel binary.