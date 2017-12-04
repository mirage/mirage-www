# Solo5

Solo5 is an execution environment and associated tooling for running
unikernels, that provides:

* Access to a variety of secure sandboxing technologies (e.g. hardware
  virtualization, seccomp).
* Portability to a variety of host systems and processor
  architectures.
* Fast boot times, suitable for "function as a service" use-cases.
* Efficient record/replay for deterministic execution and debugging of
  applications.
* An API designed for ease of porting existing and future
  unikernel-native applications.

It includes the following components:

1. Monitors used to implement the Solo5 sandbox abstraction. All
   monitors do the following: launch the unikernel (with the
   appropriate bindings, as described below), and arbitrate access to the
   host system
   resources needed by the unikernel.

2. Toolchain used to create a single unikernel binary that can run on
   any of the Solo5 sandboxes. The toolchain is intended to be
   integrated into the build process of the respective library OS
   (i.e., MirageOS, IncludeOS).

3. Sandbox-specific bindings which implement the "glue" between the
   unikernel binary and the Solo5 sandbox.

4. Compatibility layers to run on systems that provide abstractions
   that differ from the Solo5 sandbox abstraction (e.g., virtio,
   muen).

As an example, a developer builds a MirageOS unikernel using the Solo5
backend.  The mirage build process uses Solo5 building tools to create
a sandbox-agnostic binary. The developer then chooses a specific
sandbox to execute this binary in, for example the Solo5-KVM monitor.
Alternatively, the developer could run the unikernel binary as a
standard VM by targeting the virtio compatibility layer

# Current status


Solo5 doesn't currently support having a sandbox-agnostic unikernel binary. The
building process does not have an intermediate step which generates this
unikernel binary. For example, building a unikernel Mirage outputs a VM image
or a ukvm image. And both images can be directly executed on their respective
monitor. The ukvm image can be executed by the solo5-ukvm monitor without
having to load bindings (they are already linked into the image).

MirageOS and IncludeOS can both build VM and ukvm images. Rumprun support is in
progress.

The only supported monitors are solo5-ukvm (ukvm-bin) and QEMU (virtio).

