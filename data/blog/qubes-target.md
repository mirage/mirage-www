---
updated: 2017-03-01
authors:
- name: Mindy Preston
  uri: https://github.com/yomimono
  email: mindy.preston@cl.cam.ac.uk
subject: Adding the Qubes target to Mirage
permalink: qubes-target
---

When I got a new laptop in early 2016, I decided to try out this [QubesOS](https://qubesos.org) all the cool kids were talking about.  QubesOS also runs a hypervisor, but it nicely supports running multiple virtual machines for typical user tasks, like looking at cat photos with a web browser, viewing a PDF, listening to music, or patching MirageOS.  QubesOS also uses Xen, which means we should be able to even *run* our MirageOS unikernels on it... right?

The answer is [yes, after a fashion](http://roscidus.com/blog/blog/2016/01/01/a-unikernel-firewall-for-qubesos/).  Thomas Leonard did the hard work of writing [mirage-qubes](https://github.com/mirage/mirage-qubes), a library that interfaces nicely with the QubesOS management layer and allows MirageOS unikernels to boot, configure themselves, and run as managed by the Qubes management system.  That solution is nice for generating, once, a unikernel that you're going to run all the time under QubesOS, but building a unikernel that will boot and run on QubesOS requires QubesOS-specific code in the unikernel itself.  It's very unfriendly for testing generic unikernels, and as the release manager for Mirage 3, I wanted to do that pretty much all the time.

The command-line `mirage` utility was made to automatically build programs against libraries that are specific to a target only when the user has asked to build for that target, which is the exact problem we have!  So let's try to get to `mirage configure -t qubes`.

## teach a robot to do human tricks

In order for Qubes to successfully boot our unikernel, it needs to do at least two (but usually three) things:

* start a qrexec listener, and respond to requests from dom0
* start a qubes-gui listener, and respond to requests from dom0
* if we're going to do networking (usually we are), get the network configuration from qubesdb

There's code for doing all of these available in the [mirage-qubes](https://github.com/mirage/mirage-qubes) library, and a nice example available at [qubes-mirage-skeleton](https://github.com/talex5/qubes-mirage-skeleton).  The example at qubes-mirage-skeleton shows us what we have to plumb into a MirageOS unikernel in order to boot in Qubes.  All of the important stuff is in `unikernel.ml`.  We need to pull the code that connects to RExec and GUI:

```ocaml
(* Start qrexec agent, GUI agent and QubesDB agent in parallel *)
   let qrexec = RExec.connect ~domid:0 () in
   let gui = GUI.connect ~domid:0 () in
```

`qrexec` and `gui` are Lwt threads that will resolve in the records we need to pass to the respective `listen` functions from the `RExec` and `GUI` modules.  We'll state the rest of the program in terms of what to do once they're connected with a couple of monadic binds:

```ocaml
    (* Wait for clients to connect *)
    qrexec >>= fun qrexec ->
    let agent_listener = RExec.listen qrexec Command.handler in
```

`agent_listener` is called much later in the program.  It's not something we'll use generally in an adaptation of this code for a generic unikernel running on QubesOS -- instead, we'll invoke `RExec.listen` with a function that disregards input.

```ocaml
    gui >>= fun gui ->
    Lwt.async (fun () -> GUI.listen gui);
```

We use `gui` right away, though.  `Lwt.async` lets us start an Lwt thread that the rest of our program logic isn't impacted by, but needs to be hooked into the event loop.  The function we define in this call asks `GUI.listen` to handle incoming events for the `gui` record we got from `GUI.connect`.

`qubes-mirage-skeleton` does an additional bit of setup:

```ocaml
    Lwt.async (fun () ->
      OS.Lifecycle.await_shutdown_request () >>= fun (`Poweroff | `Reboot) ->
      RExec.disconnect qrexec
    );
```

This hooks another function into the event loop: a listener which hears shutdown requests from [OS.Lifecycle](https://github.com/mirage/mirage-platform/blob/2d044a499824c98ee2f067b71110883e9226d8cf/xen/lib/lifecycle.ml#L21) and disconnects `RExec` when they're heard.  The `disconnect` has the side effect of terminating the `agent_listener` if it's running, as documented in [mirage-qubes](https://github.com/talex5/mirage-qubes/master/lib/qubes.mli#L130").

`qubes-mirage-skeleton` then configures its networking (we'll talk about this later) and runs a test to make sure it can reach the outside world.  Once that's finished, it calls the `agent_listener` defined above, which listens for commands via `RExec.listen`.

## making mirageos unikernels

Building MirageOS unikernels is a three-phase process:

* mirage configure: generate main.ml unifying your code with the devices it needs
* make depend: make sure you have the libraries required to build the final artifact
* make: build your application against the specified configuration

In order to get an artifact that automatically includes the code above, we need to plumb the tasks above into `main.ml`, and the libraries they depend on into `make depend`, via `mirage configure`.

## let's quickly revisit what impl passing usually looks like

Applications built to run as MirageOS unikernels are written as OCaml functors.  They're parameterized over OCaml modules providing implementations of some functionality, which is stated as a module type.  For example, here's a MirageOS networked "hello world":

```ocaml
module Main (N: Mirage_net_lwt.S) = struct

  let start (n : N.t)  =
    N.write n @@ Cstruct.of_string "omg hi network" >>= function
    | Error e -> Log.warn (fun f -> f "failed to send message"); Lwt.return_unit
    | Ok () -> Log.info (fun f -> f "said hello!"); Lwt.return_unit

end
```

Our program is in a module that's parameterized over the module `N`, which can be any module that matches the module type `Mirage_net_lwt.S`.  The entry point for execution is the `start` function, which takes one argument of type `N.t`.  This is the usual pattern for Mirage unikernels, powered by Functoria's [invocation of otherworldly functors](/blog/introducing-functoria).

But there are other modules which aren't explicitly passed.  Since MirageOS version 2.9.0, for example, a `Logs` module has been available to MirageOS unikernels.  It isn't explicitly passed as a module argument to `Main`, because it's assumed that all unikernels will want to use it, and so it's always made available.  The `OS` module is also always available, although the implementation will be specific to the target for which the unikernel was configured, and there is no module type to which the module is forced to conform.

## providing additional modules

Let's look first at fulfilling the `qrexec` and `gui` requirements, which we'll have to do for any unikernel that's configured with `mirage configure -t qubes`.

When we want a module passed to the generated unikernel, we start by making a `job`.  Let's add one for `qrexec` to `lib/mirage.ml`:

```ocaml
let qrexec = job
```

and we'll want to define some code for what `mirage` should do if it's determined from the command-line arguments to `mirage configure` that a `qrexec` is required:

```ocaml
let qrexec_qubes = impl @@ object
  inherit base_configurable
  method ty = qrexec
  val name = Name.ocamlify @@ "qrexec_"
  method name = name
  method module_name = "Qubes.RExec"
  method packages = Key.pure [ package "mirage-qubes" ]
  method configure i =
    match get_target i with
    | `Qubes -> R.ok ()
    | _ -> R.error_msg "Qubes remote-exec invoked for non-Qubes target."
  method connect _ modname _args =
    Fmt.strf
      "@[<v 2>\
       %s.connect ~domid:0 () >>= fun qrexec ->@ \
       Lwt.async (fun () ->@ \
       OS.Lifecycle.await_shutdown_request () >>= fun _ ->@ \
       %s.disconnect qrexec);@ \
       Lwt.return (`Ok qrexec)@]"
      modname modname
end
```

This defines a `configurable` object, which inherits from the `base_configurable` class defined in Mirage.  The interesting bits for this `configurable` are the methods `packages`, `configure`, and `connect`. `packages` is where the dependency on `mirage-qubes` is declared.  `configure` will terminate if `qrexec_qubes` has been pulled into the dependency graph but the user invoked another target (for example, `mirage configure -t unix`).  `connect` gives the instructions for generating the code for `qrexec` in `main.ml`.

You may notice that `connect`'s `strf` call doesn't refer to `Qrexec` directly, but rather takes a `modname` parameter.  Most of the modules referred to will be the result of some functor application, and the previous code generation will automatically name them; the only way to access this name is via the `modname` parameter.

We do something similar for `gui`:

```ocaml
let gui = job

let gui_qubes = impl @@ object
  inherit base_configurable
  method ty = gui
  val name = Name.ocamlify @@ "gui"
  method name = name
  method module_name = "Qubes.GUI"
  method packages = Key.pure [ package "mirage-qubes" ]
  method configure i =
    match get_target i with
    | `Qubes -> R.ok ()
    | _ -> R.error_msg "Qubes GUI invoked for non-Qubes target."
  method connect _ modname _args =
    Fmt.strf
      "@[<v 2>\
       %s.connect ~domid:0 () >>= fun gui ->@ \
       Lwt.async (fun () -> %s.listen gui);@ \
       Lwt.return (`Ok gui)@]"
      modname modname
end
```

For details on what both `gui_qubes` and `qrexec_qubes` are actually doing in their `connect` blocks and why, [talex5's post on building the QubesOS unikernel firewall](http://roscidus.com/blog/blog/2016/01/01/a-unikernel-firewall-for-qubesos/).

### QRExec for nothing, GUI for free

We'll need the `connect` function for both of these configurables to be run before the `start` function of our unikernel.  But we also don't want a corresponding `QRExec.t` or `GUI.t` to be passed to our unikernel, nor do we want to parameterize it over the module type corresponding to either module, since either of these would be nonsensical for a non-Qubes target.

Instead, we need to have `main.ml` take care of this transparently, and we don't want any of the results passed to us.  In order to accomplish this, we'll need to change the final invocation of Functoria's `register` function from `Mirage.register`:

```ocaml
let qrexec_init = match_impl Key.(value target) [
  `Qubes, qrexec_qubes;
] ~default:Functoria_app.noop

let gui_init = match_impl Key.(value target) [
  `Qubes, gui_qubes;
] ~default:Functoria_app.noop

let register
    ?(argv=default_argv) ?tracing ?(reporter=default_reporter ())
    ?keys ?packages
    name jobs =
  let argv = Some (Functoria_app.keys argv) in
  let reporter = if reporter == no_reporter then None else Some reporter in
  let qubes_init = Some [qrexec_init; gui_init] in
  let init = qubes_init ++ argv ++ reporter ++ tracing in
  register ?keys ?packages ?init name jobs
```

`qrexec_init` and `gui_init` will only take action if the target is `qubes`; otherwise, the dummy implementation `Functoria_app.noop` will be used.  The `qrexec_init` and `gui_init` values are added to the `init` list passed to `register` regardless of whether they are the Qubes `impl`s or `Functoria_app.noop`.

With those additions, `mirage configure -t qubes` will result in a bootable unikernel!  ...but we're not done yet.

## how do I networks

MirageOS previously had two methods of IP configuration: automatically at boot via [DHCP](https://github.com/mirage/charrua-core), and statically at code, configure, or boot.  Neither of these are appropriate IPv4 interfaces on Qubes VMs: QubesOS doesn't run a DHCP daemon.  Instead, it expects VMs to consult the Qubes database for their IP information after booting.  Since the IP information isn't known before boot, we can't even supply it at boot time.

Instead, we'll add a new `impl` for fetching information from QubesDB, and plumb the IP configuration into the `generic_stackv4` function.  `generic_stackv4` already makes an educated guess about the best IPv4 configuration retrieval method based in part on the target, so this is a natural fit.

Since we want to use QubesDB as an input to the function that configures the IPv4 stack, we'll have to do a bit more work to make it fit nicely into the functor application architecture -- namely, we have to make a `Type` for it:

```ocaml
type qubesdb = QUBES_DB
let qubesdb = Type QUBES_DB

let qubesdb_conf = object
  inherit base_configurable
  method ty = qubesdb
  method name = "qubesdb"
  method module_name = "Qubes.DB"
  method packages = Key.pure [ package "mirage-qubes" ]
  method configure i =
    match get_target i with
    | `Qubes -> R.ok ()
    | _ -> R.error_msg "Qubes DB invoked for non-Qubes target."
  method connect _ modname _args = Fmt.strf "%s.connect ~domid:0 ()" modname
end

let default_qubesdb = impl qubesdb_conf
```

Other than the `type qubesdb = QUBES_DB` and `let qubesdb = Type QUBES_DB`, this isn't very different from the previous `gui` and `qrexec` examples.  Next, we'll need something that can take a `qubesdb`, look up the configuration, and set up an `ipv4` from the lower layers:

```ocaml
let ipv4_qubes_conf = impl @@ object
    inherit base_configurable
    method ty = qubesdb @-> ethernet @-> arpv4 @-> ipv4
    method name = Name.create "qubes_ipv4" ~prefix:"qubes_ipv4"
    method module_name = "Qubesdb_ipv4.Make"
    method packages = Key.pure [ package ~sublibs:["ipv4"] "mirage-qubes" ]
    method connect _ modname = function
      | [ db ; etif; arp ] -> Fmt.strf "%s.connect %s %s %s" modname db etif arp
      | _ -> failwith (connect_err "qubes ipv4" 3)
  end

let ipv4_qubes db ethernet arp = ipv4_qubes_conf $ db $ ethernet $ arp
```

Notably, the `connect` function here is a bit more complicated -- we care about the arguments presented to the function (namely the initialized database, an ethernet module, and an arp module), and we'll pass them to the initialization function, which comes from `mirage-qubes.ipv4`.

To tell `mirage configure` that when `-t qubes` is specified, we should use `ipv4_qubes_conf`, we'll add a bit to `generic_stackv4`:

```ocaml
let generic_stackv4
    ?group ?config
    ?(dhcp_key = Key.value @@ Key.dhcp ?group ())
    ?(net_key = Key.value @@ Key.net ?group ())
    (tap : network impl) : stackv4 impl =
  let eq a b = Key.(pure ((=) a) $ b) in
  let choose qubes socket dhcp =
    if qubes then `Qubes
    else if socket then `Socket
    else if dhcp then `Dhcp
    else `Static
  in
  let p = Functoria_key.((pure choose)
          $ eq `Qubes Key.(value target)
          $ eq `Socket net_key
          $ eq true dhcp_key) in
  match_impl p [
    `Dhcp, dhcp_ipv4_stack ?group tap;
    `Socket, socket_stackv4 ?group [Ipaddr.V4.any];
    `Qubes, qubes_ipv4_stack ?group tap;
  ] ~default:(static_ipv4_stack ?config ?group tap)
```

Now, `mirage configure -t qubes` with any unikernel that usees `generic_stackv4` will automatically work!

# So What?

This means I can configure this website for the Qubes target in my development VM:

```bash
4.04.0🐫  (qubes-target) mirageos:~/mirage-www/src$ mirage configure -t qubes
```

and get some nice invocations of the QRExec and GUI start code, along with the IPv4 configuration from QubesDB:

```ocaml
4.04.0🐫  (qubes-target) mirageos:~/mirage-www/src$ cat main.ml
(* Generated by mirage configure -t qubes (Tue, 28 Feb 2017 18:15:49 GMT). *)

open Lwt.Infix
let return = Lwt.return
let run =
OS.Main.run

let _ = Printexc.record_backtrace true

module Ethif1 = Ethif.Make(Netif)

module Arpv41 = Arpv4.Make(Ethif1)(Mclock)(OS.Time)

module Qubesdb_ipv41 = Qubesdb_ipv4.Make(Qubes.DB)(Ethif1)(Arpv41)

module Icmpv41 = Icmpv4.Make(Qubesdb_ipv41)

module Udp1 = Udp.Make(Qubesdb_ipv41)(Stdlibrandom)

module Tcp1 = Tcp.Flow.Make(Qubesdb_ipv41)(OS.Time)(Mclock)(Stdlibrandom)

module Tcpip_stack_direct1 = Tcpip_stack_direct.Make(OS.Time)(Stdlibrandom)
  (Netif)(Ethif1)(Arpv41)(Qubesdb_ipv41)(Icmpv41)(Udp1)(Tcp1)

module Conduit_mirage1 = Conduit_mirage.With_tcp(Tcpip_stack_direct1)

module Dispatch1 = Dispatch.Make(Cohttp_mirage.Server_with_conduit)(Static1)
  (Static2)(Pclock)

module Mirage_logs1 = Mirage_logs.Make(Pclock)

let net11 = lazy (
  Netif.connect (Key_gen.interface ())
  )

let time1 = lazy (
  return ()
  )

let mclock1 = lazy (
  Mclock.connect ()
  )

let ethif1 = lazy (
  let __net11 = Lazy.force net11 in
  __net11 >>= fun _net11 ->
  Ethif1.connect _net11
  )

let qubesdb1 = lazy (
  Qubes.DB.connect ~domid:0 ()
  )

let arpv41 = lazy (
  let __ethif1 = Lazy.force ethif1 in
  let __mclock1 = Lazy.force mclock1 in
  let __time1 = Lazy.force time1 in
  __ethif1 >>= fun _ethif1 ->
  __mclock1 >>= fun _mclock1 ->
  __time1 >>= fun _time1 ->
  Arpv41.connect _ethif1 _mclock1
  )

let qubes_ipv411 = lazy (
  let __qubesdb1 = Lazy.force qubesdb1 in
  let __ethif1 = Lazy.force ethif1 in
  let __arpv41 = Lazy.force arpv41 in
  __qubesdb1 >>= fun _qubesdb1 ->
  __ethif1 >>= fun _ethif1 ->
  __arpv41 >>= fun _arpv41 ->
  Qubesdb_ipv41.connect _qubesdb1 _ethif1 _arpv41
  )

let random1 = lazy (
  Lwt.return (Stdlibrandom.initialize ())
  )

let icmpv41 = lazy (
  let __qubes_ipv411 = Lazy.force qubes_ipv411 in
  __qubes_ipv411 >>= fun _qubes_ipv411 ->
  Icmpv41.connect _qubes_ipv411
  )

let udp1 = lazy (
  let __qubes_ipv411 = Lazy.force qubes_ipv411 in
  let __random1 = Lazy.force random1 in
  __qubes_ipv411 >>= fun _qubes_ipv411 ->
  __random1 >>= fun _random1 ->
  Udp1.connect _qubes_ipv411
  )

let tcp1 = lazy (
  let __qubes_ipv411 = Lazy.force qubes_ipv411 in
  let __time1 = Lazy.force time1 in
  let __mclock1 = Lazy.force mclock1 in
  let __random1 = Lazy.force random1 in
  __qubes_ipv411 >>= fun _qubes_ipv411 ->
  __time1 >>= fun _time1 ->
  __mclock1 >>= fun _mclock1 ->
  __random1 >>= fun _random1 ->
  Tcp1.connect _qubes_ipv411 _mclock1
  )

let stackv4_1 = lazy (
  let __time1 = Lazy.force time1 in
  let __random1 = Lazy.force random1 in
  let __net11 = Lazy.force net11 in
  let __ethif1 = Lazy.force ethif1 in
  let __arpv41 = Lazy.force arpv41 in
  let __qubes_ipv411 = Lazy.force qubes_ipv411 in
  let __icmpv41 = Lazy.force icmpv41 in
  let __udp1 = Lazy.force udp1 in
  let __tcp1 = Lazy.force tcp1 in
  __time1 >>= fun _time1 ->
  __random1 >>= fun _random1 ->
  __net11 >>= fun _net11 ->
  __ethif1 >>= fun _ethif1 ->
  __arpv41 >>= fun _arpv41 ->
  __qubes_ipv411 >>= fun _qubes_ipv411 ->
  __icmpv41 >>= fun _icmpv41 ->
  __udp1 >>= fun _udp1 ->
  __tcp1 >>= fun _tcp1 ->
  let config = {Mirage_stack_lwt. name = "stackv4_"; interface = _net11;} in
Tcpip_stack_direct1.connect config
_ethif1 _arpv41 _qubes_ipv411 _icmpv41 _udp1 _tcp1
  )

let nocrypto1 = lazy (
  Nocrypto_entropy_mirage.initialize ()
  )

let tcp_conduit_connector1 = lazy (
  let __stackv4_1 = Lazy.force stackv4_1 in
  __stackv4_1 >>= fun _stackv4_1 ->
  Lwt.return (Conduit_mirage1.connect _stackv4_1)

  )

let conduit11 = lazy (
  let __nocrypto1 = Lazy.force nocrypto1 in
  let __tcp_conduit_connector1 = Lazy.force tcp_conduit_connector1 in
  __nocrypto1 >>= fun _nocrypto1 ->
  __tcp_conduit_connector1 >>= fun _tcp_conduit_connector1 ->
  Lwt.return Conduit_mirage.empty >>= _tcp_conduit_connector1 >>=
fun t -> Lwt.return t
  )

let argv_qubes1 = lazy (
  let filter (key, _) = List.mem key (List.map snd Key_gen.runtime_keys) in
Bootvar.argv ~filter ()
  )

let http1 = lazy (
  let __conduit11 = Lazy.force conduit11 in
  __conduit11 >>= fun _conduit11 ->
  Cohttp_mirage.Server_with_conduit.connect _conduit11
  )

let static11 = lazy (
  Static1.connect ()
  )

let static21 = lazy (
  Static2.connect ()
  )

let pclock1 = lazy (
  Pclock.connect ()
  )

let key1 = lazy (
  let __argv_qubes1 = Lazy.force argv_qubes1 in
  __argv_qubes1 >>= fun _argv_qubes1 ->
  return (Functoria_runtime.with_argv (List.map fst Key_gen.runtime_keys) "www" _argv_qubes1)
  )

let gui1 = lazy (
  Qubes.GUI.connect ~domid:0 () >>= fun gui ->
  Lwt.async (fun () -> Qubes.GUI.listen gui);
  Lwt.return (`Ok gui)
  )

let qrexec_1 = lazy (
  Qubes.RExec.connect ~domid:0 () >>= fun qrexec ->
  Lwt.async (fun () ->
  OS.Lifecycle.await_shutdown_request () >>= fun _ ->
  Qubes.RExec.disconnect qrexec);
  Lwt.return (`Ok qrexec)
  )

let f11 = lazy (
  let __http1 = Lazy.force http1 in
  let __static11 = Lazy.force static11 in
  let __static21 = Lazy.force static21 in
  let __pclock1 = Lazy.force pclock1 in
  __http1 >>= fun _http1 ->
  __static11 >>= fun _static11 ->
  __static21 >>= fun _static21 ->
  __pclock1 >>= fun _pclock1 ->
  Dispatch1.start _http1 _static11 _static21 _pclock1
  )

let mirage_logs1 = lazy (
  let __pclock1 = Lazy.force pclock1 in
  __pclock1 >>= fun _pclock1 ->
  let ring_size = None in
  let reporter = Mirage_logs1.create ?ring_size _pclock1 in
  Mirage_runtime.set_level ~default:Logs.Info (Key_gen.logs ());
  Mirage_logs1.set_reporter reporter;
  Lwt.return reporter
  )

let mirage1 = lazy (
  let __qrexec_1 = Lazy.force qrexec_1 in
  let __gui1 = Lazy.force gui1 in
  let __key1 = Lazy.force key1 in
  let __mirage_logs1 = Lazy.force mirage_logs1 in
  let __f11 = Lazy.force f11 in
  __qrexec_1 >>= fun _qrexec_1 ->
  __gui1 >>= fun _gui1 ->
  __key1 >>= fun _key1 ->
  __mirage_logs1 >>= fun _mirage_logs1 ->
  __f11 >>= fun _f11 ->
  Lwt.return_unit
  )

let () =
  let t =
  Lazy.force qrexec_1 >>= fun _ ->
    Lazy.force gui1 >>= fun _ ->
    Lazy.force key1 >>= fun _ ->
    Lazy.force mirage_logs1 >>= fun _ ->
    Lazy.force mirage1
  in run t
```

and we can build this unikernel, then [send it to dom0 to be booted](https://github.com/talex5/qubes-test-mirage):

```bash
4.04.0🐫  (qubes-target) mirageos:~/mirage-www/src$ make depend
4.04.0🐫  (qubes-target) mirageos:~/mirage-www/src$ make
4.04.0🐫  (qubes-target) mirageos:~/mirage-www/src$ ~/test-mirage www.xen mirage-test
```

and if we check the guest VM logs for the test VM (which on my machine is named `mirage-test`, as above), we'll see that it's up and running:

```bash
.[32;1mMirageOS booting....[0m
Initialising timer interface
Initialising console ... done.
Note: cannot write Xen 'control' directory
Attempt to open(/dev/urandom)!
Unsupported function getpid called in Mini-OS kernel
Unsupported function getppid called in Mini-OS kernel
2017-02-28 18:29:54 -00:00: INF [net-xen:frontend] connect 0
2017-02-28 18:29:54 -00:00: INF [qubes.db] connecting to server...
gnttab_stubs.c: initialised mini-os gntmap
2017-02-28 18:29:54 -00:00: INF [qubes.db] connected
2017-02-28 18:29:54 -00:00: INF [net-xen:frontend] create: id=0 domid=2
2017-02-28 18:29:54 -00:00: INF [net-xen:frontend]  sg:true gso_tcpv4:true rx_copy:true rx_flip:false smart_poll:false
2017-02-28 18:29:54 -00:00: INF [net-xen:frontend] MAC: 00:16:3e:5e:6c:0e
2017-02-28 18:29:54 -00:00: INF [ethif] Connected Ethernet interface 00:16:3e:5e:6c:0e
2017-02-28 18:29:54 -00:00: INF [arpv4] Connected arpv4 device on 00:16:3e:5e:6c:0e
2017-02-28 18:29:54 -00:00: INF [udp] UDP interface connected on 10.137.3.16
2017-02-28 18:29:54 -00:00: INF [tcpip-stack-direct] stack assembled: mac=00:16:3e:5e:6c:0e,ip=10.137.3.16
2017-02-28 18:29:56 -00:00: INF [dispatch] Listening on http://localhost/
```

And if we do a bit of firewall tweaking in `sys-firewall` to grant access from other VMs:

```bash
[user@sys-firewall ~]$ sudo iptables -I FORWARD -d 10.137.3.16 -i vif+ -j ACCEPT
```

we can verify that things are as we expect from any VM that has the appropriate software -- for example:

```bash
4.04.0🐫  (qubes-target) mirageos:~/mirage-www/src$ wget -q -O - ht.137.3.16|head -1
<!DOCTYPE html>
```

# What's Next?

The implementation work above leaves a lot to be desired, noted in the [comments to the original pull request](https://github.com/mirage/mirage/pull/553#issuecomment-231529011).  We welcome further contributions in this area, particularly from QubesOS users and developers!  If you have questions or comments, please get in touch on the [mirageos-devel mailing list](https://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel) or on our IRC channel at #mirage on irc.freenode.net !

