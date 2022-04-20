---
updated: 2017-02-23
author:
  name: Mindy Preston
  uri: https://github.com/yomimono
  email: mindy.preston@cl.cam.ac.uk
subject: Porting Mirage 2.x Projects to Mirage 3.x
permalink: mirage2-to-mirage3
---

# Incompatibilities

For a short summary of breaking changes, see [the Mirage 3.0.0 release notes](https://github.com/mirage/mirage/releases/tag/v3.0.0).  This document is a guide to porting your existing unikernel from the Mirage 2.x interface to Mirage 3.x.  If your unikernel was based on one of the examples in [the mirage-skeleton repository](https://github.com/mirage/mirage-skeleton), you may find [hannesm's collection of diffs from v2.9.1 to v3.0.0](http://www.cl.cam.ac.uk/~hm519/mirage-2.9.1-3.0.0-diffs/) for popular unikernels to be a useful reference.

## config.ml and generic/default functions

A number of refinements to the configuration language for Mirage were made in the Mirage 2.7.0 release, which incorporated the [functoria](https://github.com/mirage/functoria) DSL.  It was still possible to use the previous calls, however, until Mirage 3.0.0 where support for them was dropped.  Many users whose unikernels predate Mirage 2.7.0 will first notice the functoria improvements in the 3.0.0 release, as they'll finally be forced to use them.

The idiom for deciding which `impl` to use based on the backend is the most noticeable change.  Numerous older `config.ml` files include code like the following, from [mirage-skeleton's `kv_ro` example in commit `21adfc85b124e886d871079f28bd0a868ba3c5fb`](https://github.com/mirage/mirage-skeleton/tree/21adfc85b124e886d871079f28bd0a868ba3c5fb/kv_ro), which attempts to detect which `kv_ro` device to use based on the target chosen with `mirage configure -t` and environment variables:

```ocaml
let mode =
  let x = try Unix.getenv "FS" with Not_found -> "crunch" in
  match x with
  | "fat" -> `Fat
  | "crunch" -> `Crunch
  | x -> failwith ("Unknown FS mode: " ^ x )

let fat_ro dir =
  kv_ro_of_fs (fat_of_files ~dir ())

let disk =
  match mode, get_mode () with
  | `Fat   , _     -> fat_ro "t"
  | `Crunch, `Xen  -> crunch "t"
  | `Crunch, (`Unix | `MacOSX) -> direct_kv_ro "t"
```

Functoria improved the situation considerably by including convenience functions which not only have logic for autodetecting which implementations are suitable based on the backend selected, but also other arguments given to `mirage configure`.  The code above can be replaced with:

```ocaml
let disk = generic_kv_ro "t"
```

`generic_kv_ro` knows about not only the Xen, Unix, and MacOSX targets handled by the previous config.ml code, but also will do the right thing for new targets Ukvm, Virtio, and Qubes.  The command-line argument `--kv_ro` will be understood when `mirage configure` is run from a directory with a `config.ml` including `generic_kv_ro`.

Several useful `default_` and `generic_` functions are provided by [the Mirage module](http://docs.mirage.io/mirage/Mirage) for use in `config.ml`:

```
~/mirage$ grep -E 'val (generic_|default_)'  lib/mirage.mli
val default_qubesdb: qubesdb impl
val default_time: time impl
val default_posix_clock: pclock impl
val default_monotonic_clock: mclock impl
val default_reporter:
val default_random: random impl
val default_console: console impl
val default_io_page: io_page impl
val generic_kv_ro:
val default_network: network impl
val generic_stackv4:
val default_argv: Functoria_app.argv impl
```

Many existing unikernels will find it useful to replace their existing network stack detecting code with `generic_stackv4` in particular -- let's see an example.

## Porting the stackv4 example to Mirage 3

A good example of replacing old configurator code can be seen between [the pre-functoria `network` example](https://github.com/mirage/mirage-skeleton/tree/21adfc85b124e886d871079f28bd0a868ba3c5fb/stackv4), and [the `device-usage/network` example from the Mirage-3.0.0-compatible branch of `mirage-skeleton`](https://github.com/mirage/mirage-skeleton/tree/e9360fa1ce02d26a8931238a16000fa12df40ebf/device-usage/network).  We can replace this old code from `config.ml`:

```ocaml
let net =
  try match Sys.getenv "NET" with
    | "direct" -> `Direct
    | "socket" -> `Socket
    | _        -> `Direct
  with Not_found -> `Direct

let dhcp =
  try match Sys.getenv "ADDR" with
    | "dhcp"   -> `Dhcp
    | "static" -> `Static
  with Not_found -> `Dhcp

let stack console =
  match net, dhcp with
  | `Direct, `Dhcp   -> direct_stackv4_with_dhcp console tap0
  | `Direct, `Static -> direct_stackv4_with_default_ipv4 console tap0
  | `Socket, _       -> socket_stackv4 console [Ipaddr.V4.any]

```

with this:

```ocaml
let stack = generic_stackv4 default_network
```

You may notice that `generic_stackv4` doesn't take a `console` argument, where the previous `direct_stackv4*` and `socket_stackv4` functions did.  This leads us to another big change that predates MirageOS 3, but is more widely used and better supported in this release: logging.

The `mirage_logs` library and its incorporation into the configuration language dates back to version 2.9.0, but a number of libraries still required a `console impl` argument and expected to log to the console.  In Mirage 3.0.0, we've tried to replace the calls to `Console.log` with calls to `Logs.debug`, `Logs.info`, or `Logs.warn` as appropriate.  Consequently, many of the functions which previously needed to be passed a console no longer require it.  For example, we can take [the `stackv4` example from `mirage-skeleton` commit f36d2958f616fb882df37f08d3440797471ca0cc](https://github.com/mirage/mirage-skeleton/tree/f36d2958f616fb882df37f08d3440797471ca0cc/stackv4), which fails with Mirage 3:

```ocaml
mirage-skeleton/stackv4$ cat config.ml
open Mirage

let handler = foreign "Unikernel.Main" (console @-> stackv4 @-> job)

let stack = generic_stackv4 default_console tap0

let () =
  register "stackv4" [handler $ default_console $ stack]
mirage-skeleton/stackv4$ 
mirage-skeleton/stackv4$ mirage configure -t unix
mirage: unknown option `-t'.
Usage: mirage configure [OPTION]... 
Try `mirage configure --help' or `mirage --help' for more information.
error while executing ocamlbuild -use-ocamlfind -classic-display -tags
                        bin_annot -quiet -X _build-ukvm -pkg mirage
                        config.cmxs
+ ocamlfind ocamlc -c -bin-annot -package mirage -o config.cmo config.ml
File "config.ml", line 5, characters 44-48:
Error: The function applied to this argument has type
         ?group:string ->
         ?config:Mirage.ipv4_config ->
         ?dhcp_key:bool Mirage.value ->
         ?net_key:[ `Direct | `Socket ] Mirage.value ->
         Mirage.stackv4 Functoria.impl
This argument cannot be applied without label
Command exited with code 2.
Hint: Recursive traversal of subdirectories was not enabled for this build,
  as the working directory does not look like an ocamlbuild project (no
  '_tags' or 'myocamlbuild.ml' file). If you have modules in subdirectories,
  you should add the option "-r" or create an empty '_tags' file.
  
  To enable recursive traversal for some subdirectories only, you can use the
  following '_tags' file:
  
      true: -traverse
      <dir1> or <dir2>: traverse
```

Note that in the output above, we get an initial error message suggesting that `-t unix` is not understood by `mirage configure`.  The failure to understand any option, including `-t`, is a side effect of `config.ml` itself not being understood by `mirage`  The error message from `ocamlbuild` that follows the `mirage` output about `-t unix` is the right place to start fixing this problem.

Let's remove the `default_console` argument to `stackv4`, to give the following `config.ml`:

```ocaml
open Mirage

let handler = foreign "Unikernel.Main" (console @-> stackv4 @-> job)

let stack = generic_stackv4 tap0

let () =
  register "stackv4" [handler $ default_console $ stack]
mirage-skeleton/stackv4$ mirage configure -t unix
mirage: unknown option `-t'.
Usage: mirage configure [OPTION]... 
Try `mirage configure --help' or `mirage --help' for more information.
error while executing ocamlbuild -use-ocamlfind -classic-display -tags
                        bin_annot -quiet -X _build-ukvm -pkg mirage
                        config.cmxs
+ ocamlfind ocamlc -c -bin-annot -package mirage -o config.cmo config.ml
File "config.ml", line 5, characters 28-32:
Error: Unbound value tap0
Command exited with code 2.
```

We can see from the last bit of output that `tap0` is no longer known to Mirage.  The `tap0` function has been renamed to the more idiomatic `default_network` in MirageOS 3, so let's change that to get the following `config.ml`:

```ocaml
open Mirage

let handler = foreign "Unikernel.Main" (console @-> stackv4 @-> job)

let stack = generic_stackv4 default_network

let () =
  register "stackv4" [handler $ default_console $ stack]
```

and then try `mirage configure` to see some success:

```
mirage-skeleton/stackv4$ mirage configure -t unix
```

### A new step: make depend

In Mirage 2.x, `mirage configure` would automatically invoke `opam` to install the latest version of any packages it detected were needed.  The automatic alteration of the build environment was surprising to a lot of people, and additionally the invocation of `opam install` was slow enough that many heavy Mirage users usually called `mirage configure` with the `--no-opam` option to disable it.  In Mirage 3, `mirage configure` no longer automatically installs packages, but a convenient shorthand for installing everything necessary is still available with `make depend`.  `make depend` relies on information discovered during `mirage configure`, and is only available after that step.  You should run it when you change `config.ml` or you invoke `mirage configure` with different arguments.  We've just done the former, so we'll need to `make depend` before `make`ing:

```
mirage-skeleton/stackv4$ make depend && make

pam pin add --no-action --yes mirage-unikernel-stackv4-unix .
Package mirage-unikernel-stackv4-unix does not exist, create as a NEW package ? [Y/n] y
mirage-unikernel-stackv4-unix is now path-pinned to /home/user/mirage-skeleton/stackv4

[mirage-unikernel-stackv4-unix] /home/user/mirage-skeleton/stackv4/ synchronized
[mirage-unikernel-stackv4-unix] Installing new package description from
/home/user/mirage-skeleton/stackv4

opam depext --yes mirage-unikernel-stackv4-unix
# Detecting depexts using flags: x86_64 linux debian
# The following system packages are needed:
#  - debianutils
#  - m4
#  - ncurses-dev
#  - pkg-config
#  - time
# All required OS packages found.
opam install --yes --deps-only mirage-unikernel-stackv4-unix

=-=- Synchronising pinned packages =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[mirage-unikernel-stackv4-unix] /home/user/mirage-skeleton/stackv4/ already up-to-date
The following actions will be performed:
  ∗  install mirage-console-unix dev~mirage

=-=- Gathering sources =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[mirage-console-unix] https://github.com/mirage/mirage-console.git updated

=-=- Processing actions -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
∗  installed mirage-console-unix.dev~mirage
Done.
opam pin remove --no-action mirage-unikernel-stackv4-unix
mirage-unikernel-stackv4-unix is now unpinned from path /home/user/mirage-skeleton/stackv4
mirage build
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules main.ml > main.ml.depends
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules key_gen.ml > key_gen.ml.depends
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o key_gen.cmo key_gen.ml
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 2, characters 5-11:
Error: Unbound module V1_LWT
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-console-unix,mirage-logs,mirage-net-unix,mirage-random,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.icmpv4,tcpip.ipv4,tcpip.stack-direct,tcpip.tcp,tcpip.udp'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### Where to find module type definitions

We got a bit further that time, but we're still not quite there.  The module previously known as `V1_LWT`, which contained definitions for all of the module types (e.g. `CONSOLE`, `BLOCK`, `STACKV4`) used to define bits of operating system functionality has renamed.  `V1` is now `Mirage_types`, and `V1_LWT` is now `Mirage_types_lwt`.  Both `Mirage_types` and `Mirage_types_lwt` just refer to definitions in respective packages now, rather than containing the module types directly, and it would be better to directly reference the ones we need rather than opening up all of `Mirage_types_lwt`.  (You may find [the map of module type names from Mirage_types to their true names](https://github.com/mirage/mirage/blob/master/types/mirage_types.mli) useful to keep handy.) Let's edit `unikernel.ml` to refer to `Mirage_console_lwt.S` and `Mirage_stack_lwt.V4` accordingly:

```ocaml
open Lwt.Infix
open Printf

let red fmt    = sprintf ("\027[31m"^^fmt^^"\027[m")
let green fmt  = sprintf ("\027[32m"^^fmt^^"\027[m")
let yellow fmt = sprintf ("\027[33m"^^fmt^^"\027[m")
let blue fmt   = sprintf ("\027[36m"^^fmt^^"\027[m")

module Main (C:Mirage_console_lwt.S) (S:Mirage_stack_lwt.V4) = struct

  module T  = S.TCPV4

  let start console s =

    let ips = List.map Ipaddr.V4.to_string (S.IPV4.get_ip (S.ipv4 s)) in
    C.log_s console (sprintf "IP address: %s\n" (String.concat ", " ips))

    >>= fun () ->
    let local_port = 53 in
    S.listen_udpv4 s ~port:local_port (
      fun ~src ~dst ~src_port buf ->
        C.log_s console
          (red "UDP %s:%d > %s:%d: \"%s\""
             (Ipaddr.V4.to_string src) src_port
             (Ipaddr.V4.to_string dst) local_port
             (Cstruct.to_string buf))
    );

    let local_port = 8080 in
    S.listen_tcpv4 s ~port:local_port (
      fun flow ->
        let remote, remote_port = T.get_dest flow in
        C.log_s console
          (green "TCP %s:%d > _:%d"
             (Ipaddr.V4.to_string remote) remote_port local_port)

        >>= fun () ->
        T.read flow

        >>= function
        | `Ok b ->
          C.log_s console
            (yellow "read: %d \"%s\"" (Cstruct.len b) (Cstruct.to_string b))

          >>= fun () ->
          T.close flow

        | `Eof -> C.log_s console (red "read: eof")
        | `Error _e -> C.log_s console (red "read: error")
    );

    S.listen s
end
```

We get a bit closer, but we're still not to successful compilation yet:

```
~/mirage-skeleton/stackv4$ make
mirage build
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 17, characters 4-11:
Error: Unbound value C.log_s
Hint: Did you mean log?
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-console-unix,mirage-logs,mirage-net-unix,mirage-random,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.icmpv4,tcpip.ipv4,tcpip.stack-direct,tcpip.tcp,tcpip.udp'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### Name changes: C.log_s -> C.log, T.get_dest -> T.dst

`C` is a module of type `Mirage_console_lwt.S`.  This module type was refactored in Mirage 3 to remove `log`, and rename the more commonly used `log_s` to `log`.  If we really want to be sure that our messages go to the *console*, rather than to another available logging destination, we can change `unikernel.ml` to use `C.log` instead of `C.log_s`:

```

open Lwt.Infix
open Printf

let red fmt    = sprintf ("\027[31m"^^fmt^^"\027[m")
let green fmt  = sprintf ("\027[32m"^^fmt^^"\027[m")
let yellow fmt = sprintf ("\027[33m"^^fmt^^"\027[m")
let blue fmt   = sprintf ("\027[36m"^^fmt^^"\027[m")

module Main (C:Mirage_console_lwt.S) (S:Mirage_stack_lwt.V4) = struct

  module T  = S.TCPV4

  let start console s =

    let ips = List.map Ipaddr.V4.to_string (S.IPV4.get_ip (S.ipv4 s)) in
    C.log console (sprintf "IP address: %s\n" (String.concat ", " ips))

    >>= fun () ->
    let local_port = 53 in
    S.listen_udpv4 s ~port:local_port (
      fun ~src ~dst ~src_port buf ->
        C.log console
          (red "UDP %s:%d > %s:%d: \"%s\""
             (Ipaddr.V4.to_string src) src_port
             (Ipaddr.V4.to_string dst) local_port
             (Cstruct.to_string buf))
    );

    let local_port = 8080 in
    S.listen_tcpv4 s ~port:local_port (
      fun flow ->
        let remote, remote_port = T.get_dest flow in
        C.log console
          (green "TCP %s:%d > _:%d"
             (Ipaddr.V4.to_string remote) remote_port local_port)

        >>= fun () ->
        T.read flow

        >>= function
        | `Ok b ->
          C.log console
            (yellow "read: %d \"%s\"" (Cstruct.len b) (Cstruct.to_string b))

          >>= fun () ->
          T.close flow

        | `Eof -> C.log console (red "read: eof")
        | `Error _e -> C.log console (red "read: error")
    );

    S.listen s
end
```

This lets us find our next problem:

```
~/mirage-skeleton/stackv4$ make
mirage build
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 33, characters 34-44:
Error: Unbound value T.get_dest
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-console-unix,mirage-logs,mirage-net-unix,mirage-random,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.icmpv4,tcpip.ipv4,tcpip.stack-direct,tcpip.tcp,tcpip.udp'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
~/mirage-skeleton/stackv4$ make
mirage build
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 33, characters 34-44:
Error: Unbound value T.get_dest
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-console-unix,mirage-logs,mirage-net-unix,mirage-random,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.icmpv4,tcpip.ipv4,tcpip.stack-direct,tcpip.tcp,tcpip.udp'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

The module `T` is the TCP module from the stack passed by `Mirage_stack_lwt.V4`.  The module type definition for `TCP` lives in [mirage-protocols](http://docs.mirage.io/mirage-protocols/Mirage_protocols/module-type-TCP/index.html), where we can find a [function named `dst`](http://docs.mirage.io/mirage-protocols/Mirage_protocols/module-type-TCP/index.html#val-dst) with which to replace the call to `get_dst`.  (This change is also noted in the [mirage-tcpip version 3.0.0 release notes](https://github.com/mirage/mirage-tcpip/releases/tag/v3.0.0).)  Replacing `get_dest` with `dst` gives us the following `unikernel.ml`:

```ocaml
open Lwt.Infix
open Printf

let red fmt    = sprintf ("\027[31m"^^fmt^^"\027[m")
let green fmt  = sprintf ("\027[32m"^^fmt^^"\027[m")
let yellow fmt = sprintf ("\027[33m"^^fmt^^"\027[m")
let blue fmt   = sprintf ("\027[36m"^^fmt^^"\027[m")

module Main (C:Mirage_console_lwt.S) (S:Mirage_stack_lwt.V4) = struct

  module T  = S.TCPV4

  let start console s =

    let ips = List.map Ipaddr.V4.to_string (S.IPV4.get_ip (S.ipv4 s)) in
    C.log console (sprintf "IP address: %s\n" (String.concat ", " ips))

    >>= fun () ->
    let local_port = 53 in
    S.listen_udpv4 s ~port:local_port (
      fun ~src ~dst ~src_port buf ->
        C.log console
          (red "UDP %s:%d > %s:%d: \"%s\""
             (Ipaddr.V4.to_string src) src_port
             (Ipaddr.V4.to_string dst) local_port
             (Cstruct.to_string buf))
    );

    let local_port = 8080 in
    S.listen_tcpv4 s ~port:local_port (
      fun flow ->
        let remote, remote_port = T.dst flow in
        C.log console
          (green "TCP %s:%d > _:%d"
             (Ipaddr.V4.to_string remote) remote_port local_port)

        >>= fun () ->
        T.read flow

        >>= function
        | `Ok b ->
          C.log console
            (yellow "read: %d \"%s\"" (Cstruct.len b) (Cstruct.to_string b))

          >>= fun () ->
          T.close flow

        | `Eof -> C.log console (red "read: eof")
        | `Error _e -> C.log console (red "read: error")
    );

    S.listen s
end
```

which generates a new error:

```
$ make
mirage build
ocamlfind ocamldep -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.udp -package tcpip.tcp -package tcpip.stack-direct -package tcpip.ipv4 -package tcpip.icmpv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-random -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 41, characters 10-15:
Error: This pattern matches values of type
         [< `Eof | `Error of 'a | `Ok of 'b ]
       but a pattern was expected which matches values of type
         (T.buffer Mirage_flow.or_eof, T.error) Result.result =
           (T.buffer Mirage_flow.or_eof, T.error) result
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-console-unix,mirage-logs,mirage-net-unix,mirage-random,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.icmpv4,tcpip.ipv4,tcpip.stack-direct,tcpip.tcp,tcpip.udp'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### Mirage3 errors

We get this build failure because the code expects `T.read` to return a value of type 

```ocaml
[< `Eof | `Error of 'a | `Ok of 'b ]
```

but errors have been [reworked in Mirage 3](https://mirage.io/blog/mirage-3.0-errors).  `T.read`, and other functions like it, now return a value of type

```ocaml
(T.buffer Mirage_flow.or_eof, T.error) result
```

We know that `T.buffer` is `Cstruct.t` from [`Mirage_protocols_lwt.TCP`](http://docs.mirage.io/mirage-protocols-lwt/Mirage_protocols_lwt/index.html#module-type-TCP).  [`Mirage_flow.or_eof`](http://docs.mirage.io/mirage-flow/Mirage_flow/index.html#type-or_eof) is parameterized over that type, and [T.error](http://docs.mirage.io/mirage-protocols/Mirage_protocols/module-type-TCP/index.html#type-error) is some superset of [Tcp.error](http://docs.mirage.io/mirage-protocols/Mirage_protocols/module-type-TCP/index.html#type-error) so we can expect the type of `T.read`'s returned value to be

```ocaml
Ok of (`Data of Cstruct.t)
Ok of `Eof
Error of `Timeout
Error of `Refused
Error of ???
```

where ??? is something that can be printed by `T.pp_error`, but the details of which we don't know.  We can change the `function` which is on the right of the `>>=` produced by `T.read` to comply with this error scheme:

```ocaml
open Lwt.Infix
open Printf

let red fmt    = sprintf ("\027[31m"^^fmt^^"\027[m")
let green fmt  = sprintf ("\027[32m"^^fmt^^"\027[m")
let yellow fmt = sprintf ("\027[33m"^^fmt^^"\027[m")
let blue fmt   = sprintf ("\027[36m"^^fmt^^"\027[m")

module Main (C:Mirage_console_lwt.S) (S:Mirage_stack_lwt.V4) = struct

  module T  = S.TCPV4

  let start console s =

    let ips = List.map Ipaddr.V4.to_string (S.IPV4.get_ip (S.ipv4 s)) in
    C.log console (sprintf "IP address: %s\n" (String.concat ", " ips))

    >>= fun () ->
    let local_port = 53 in
    S.listen_udpv4 s ~port:local_port (
      fun ~src ~dst ~src_port buf ->
        C.log console
          (red "UDP %s:%d > %s:%d: \"%s\""
             (Ipaddr.V4.to_string src) src_port
             (Ipaddr.V4.to_string dst) local_port
             (Cstruct.to_string buf))
    );

    let local_port = 8080 in
    S.listen_tcpv4 s ~port:local_port (
      fun flow ->
        let remote, remote_port = T.dst flow in
        C.log console
          (green "TCP %s:%d > _:%d"
             (Ipaddr.V4.to_string remote) remote_port local_port)

        >>= fun () ->
        T.read flow

        >>= function
        | Ok (`Data b) ->
          C.log console
            (yellow "read: %d \"%s\"" (Cstruct.len b) (Cstruct.to_string b))

          >>= fun () ->
          T.close flow

        | Ok `Eof -> C.log console (red "read: eof")
        | Error _ -> (* XXX: see next section for proper fix *)
    	  C.log console (red "read: error")
    );

    S.listen s
end
```

and now, finally, `make` should produce a runnable binary.

### Using Logs and pp_error

The error handling above is very unsatisfying, though, and so is the output -- for a toy application it's okay to output to the console, but for a unikernel which might be deployed to an arbitrary cloud service, console access isn't always a given.  Let's refactor this code to remove the `console` argument to the unikernel, and replace the calls to `C.log` with `Logs` calls of the appropriate level.

Our `config.ml` will look like this:

```ocaml
open Mirage

let handler = foreign "Unikernel.Main" (stackv4 @-> job)

let stack = generic_stackv4 default_network

let () =
  register "stackv4" [handler $ stack]
```

and then we'll need to change our `unikernel.ml` like so:

```ocaml
open Lwt.Infix

module Main (S:Mirage_stack_lwt.V4) = struct

  module T  = S.TCPV4

  let start s =

    let ips = List.map Ipaddr.V4.to_string (S.IPV4.get_ip (S.ipv4 s)) in
    Logs.debug (fun f -> f "IP address: %s\n" (String.concat ", " ips));
    let local_port = 53 in
    S.listen_udpv4 s ~port:local_port (
      fun ~src ~dst ~src_port buf ->
        Logs.info (fun f -> f "UDP traffic: %s:%d > %s:%d"
             (Ipaddr.V4.to_string src) src_port
             (Ipaddr.V4.to_string dst) local_port);
        Logs.debug (fun f -> f
          "UDP content: %S"
             (Cstruct.to_string buf));
        Lwt.return_unit
    );

    let local_port = 8080 in
    S.listen_tcpv4 s ~port:local_port (
      fun flow ->
        let remote, remote_port = T.dst flow in
        Logs.info (fun f -> f "new TCP connection: %s:%d > _:%d"
             (Ipaddr.V4.to_string remote) remote_port local_port);
        T.read flow

        >>= function
        | Ok (`Data b) ->
          Logs.debug (fun f -> f "TCP content: %S" (Cstruct.to_string b));
          Logs.info (fun f -> f "Closing connection to %s:%d"
             (Ipaddr.V4.to_string remote) remote_port);
          T.close flow
        | Ok `Eof ->
          Logs.info (fun f -> f "Remote side closed the connection to %s:%d."
             (Ipaddr.V4.to_string remote) remote_port);
          Lwt.return_unit
        | Error e -> Logs.warn (fun f -> f
            "Error reading TCP connection with %s:%d: %a"
            (Ipaddr.V4.to_string remote) remote_port
            T.pp_error e);
          Lwt.return_unit
    );

    S.listen s
end
```

We can remove the `open Printf` since we're no longer constructing any strings with `sprintf`, and now we can set the log level for this application at configure time or run time -- if we only want to see errors, we can choose to do so by asking for `-l *:warning`, and we can see a lot of debug output (from all layers, including the TCP/IP stack") by asking for `-l *:debug`.  We've also replaced the catchall error message with a call to `T.pp_error`, which will invoke the TCP module's error-printing function to give a string explaining any problems -- much nicer than the `read: error` output we would have gotten previously.

## Porting the ping example to Mirage 3

To illustrate how to solve some more common problems, let's look at the `ping` example, which has the following `config.ml`:

```ocaml
open Mirage

let main =
  let packages = [ "tcpip" ] in
  let libraries = [ "tcpip.arpv4"; "tcpip.ethif"; "tcpip.ipv4" ] in
  foreign
    ~libraries ~packages
    "Unikernel.Main" (console @-> network @-> clock @-> time @-> job)

let () =
  register "ping" [ main $ default_console $ tap0 $ default_clock $ default_time ]
```

Trying to `mirage configure` this fails:

```
mirage-skeleton/ping$ mirage configure -t unix
mirage: unknown option `-t'.
Usage: mirage configure [OPTION]... 
Try `mirage configure --help' or `mirage --help' for more information.
error while executing ocamlbuild -use-ocamlfind -classic-display -tags
                        bin_annot -quiet -X _build-ukvm -pkg mirage
                        config.cmxs
+ ocamlfind ocamlc -c -bin-annot -package mirage -o config.cmo config.ml
File "config.ml", line 7, characters 5-14:
Error: The function applied to this argument has type
         ?keys:Mirage.key list ->
         ?deps:Mirage.abstract_impl list -> 'a Functoria.impl
This argument cannot be applied with label ~libraries
Command exited with code 2.
Hint: Recursive traversal of subdirectories was not enabled for this build,
  as the working directory does not look like an ocamlbuild project (no
  '_tags' or 'myocamlbuild.ml' file). If you have modules in subdirectories,
  you should add the option "-r" or create an empty '_tags' file.
  
  To enable recursive traversal for some subdirectories only, you can use the
  following '_tags' file:
  
      true: -traverse
      <dir1> or <dir2>: traverse
```

because the function `foreign` no longer takes a `libraries` argument.

### Libraries and packages

`libraries` and `packages` were two optional string list arguments in Mirageversions >= 2.7.x but < 3.x.  `libraries` was for `ocamlfind` libraries, and `packages` for OPAM packages; both string lists were simply fed `ocamlfind` and `opam` commands respectively.

The [documentation for `foreign`](http://docs.mirage.io/mirage/Mirage/index.html#val-foreign) will be a useful reference for us.  In Mirage 3, `packages` is now a variable of type `package list`.  One can get a `package` by calling [Mirage.package](http://docs.mirage.io/functoria/Functoria/index.html#pkg), which has the following signature:

```ocaml
val package : ?build:bool -> ?sublibs:string list -> ?ocamlfind:string list -> ?min:string -> ?max:string -> string -> package
```

`ping` needs `tcpip` and the sublibraries `arpv4`, `ethif`, and `ipv4`, so we'll try the following `config.ml`:

```ocaml
open Mirage

let main =
  let packages = [package ~sublibs:["arpv4";"ethif";"ipv4"] "tcpip" ] in
  foreign
    ~packages
    "Unikernel.Main" (console @-> network @-> clock @-> time @-> job)

let () =
  register "ping" [ main $ default_console $ tap0 $ default_clock $ default_time ]
```

and with that, we can get to our next problem:

```
mirage-skeleton/ping$ mirage configure -t unix
mirage: unknown option `-t'.
Usage: mirage configure [OPTION]... 
Try `mirage configure --help' or `mirage --help' for more information.
error while executing ocamlbuild -use-ocamlfind -classic-display -tags
                        bin_annot -quiet -X _build-ukvm -pkg mirage
                        config.cmxs
+ ocamlfind ocamlc -c -bin-annot -package mirage -o config.cmo config.ml
File "config.ml", line 7, characters 46-51:
Error: Unbound value clock
Hint: Did you mean pclock, mclock or block?
Command exited with code 2.
Hint: Recursive traversal of subdirectories was not enabled for this build,
  as the working directory does not look like an ocamlbuild project (no
  '_tags' or 'myocamlbuild.ml' file). If you have modules in subdirectories,
  you should add the option "-r" or create an empty '_tags' file.
  
  To enable recursive traversal for some subdirectories only, you can use the
  following '_tags' file:
  
      true: -traverse
      <dir1> or <dir2>: traverse
```

### CLOCKs, PCLOCKs, and MCLOCKs

In Mirage3, the catchall `CLOCK` module type was replaced with two distinct types of clock modules: `PCLOCK`, a POSIX-compatible wall clock, and `MCLOCK`, a monotonically increasing counter.  In our experience porting MirageOS libraries, nearly all users of `CLOCK` wanted something like `MCLOCK` rather than something like `PCLOCK`.

In the case of `ping`, we only want to pass the module to `Arpv4.Make`.  The [signature for Arpv4.Make](http://docs.mirage.io/tcpip/Arpv4/Make/index.html) in version 3.0 asks for an `MCLOCK`, so we'll include an `mclock` in the arguments to `foreign`.  In `register`, we'll use [`default_monotonic_clock`](http://docs.mirage.io/mirage/Mirage/index.html#val-default_monotonic_clock).  Our `config.ml` will look like:

```ocaml
$ cat config.ml
open Mirage

let main =
  let packages = [package ~sublibs:["arpv4";"ethif";"ipv4"] "tcpip" ] in
  foreign
    ~packages
    "Unikernel.Main" (console @-> network @-> clock @-> time @-> job)

let () =
  register "ping" [ main $ default_console $ tap0 $ default_clock $ default_time ]
```

Trying to `mirage configure` this gives us an error message because we're still trying to call `tap0`, which we learned in the last example has been replaced with `default_network`.  Let's fix that up, to get the following `config.ml`:

```ocaml
open Mirage

let main =
  let packages = [package ~sublibs:["arpv4";"ethif";"ipv4"] "tcpip" ] in
  foreign
    ~packages
    "Unikernel.Main" (console @-> network @-> mclock @-> time @-> job)

let () =
  register "ping" [ main $ default_console $ default_network $ default_monotonic_clock $ default_time ]
```

and now we can run `mirage configure` successfully.  In order to build the unikernel, we'll need to make a few additional changes, as noticed by `make depend && make`:

```
mirage-skeleton/ping$ make depend && make
opam pin add --no-action --yes mirage-unikernel-ping-unix .
Package mirage-unikernel-ping-unix does not exist, create as a NEW package ? [Y/n] y
mirage-unikernel-ping-unix is now path-pinned to /home/user/mirage-skeleton/ping

[mirage-unikernel-ping-unix] /home/user/mirage-skeleton/ping/ synchronized
[mirage-unikernel-ping-unix] Installing new package description from
/home/user/mirage-skeleton/ping

opam depext --yes mirage-unikernel-ping-unix
# Detecting depexts using flags: x86_64 linux debian
# The following system packages are needed:
#  - debianutils
#  - m4
#  - ncurses-dev
#  - pkg-config
#  - time
# All required OS packages found.
opam install --yes --deps-only mirage-unikernel-ping-unix

=-=- Synchronising pinned packages =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[mirage-unikernel-ping-unix] /home/user/mirage-skeleton/ping/ already up-to-date
4opam pin remove --no-action mirage-unikernel-ping-unix
mirage-unikernel-ping-unix is now unpinned from path /home/user/mirage-skeleton/ping
mirage build
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules main.ml > main.ml.depends
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules key_gen.ml > key_gen.ml.depends
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o key_gen.cmo key_gen.ml
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 12, characters 15-22:
Error: Unbound module type CONSOLE
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-console-unix,mirage-logs,mirage-net-unix,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.ipv4'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

We need to make many of the changes mentioned in the example above, so let's get started:

### V1_LWT -> relevant disaggregated modules

We'll use `Mirage_console_lwt.S` instead of `V1_LWT.CONSOLE`, replace `V1_LWT.NETWORK` with `Mirage_net_lwt.S`, choose `Mirage_clock_lwt.MCLOCK` as the module type we want to replace `V1_LWT.CLOCK`, and use `Mirage_time_lwt.S` in place of `V1_LWT.TIME` to get the following `unikernel.ml`:

```ocaml
open Lwt.Infix

let red fmt    = Printf.sprintf ("\027[31m"^^fmt^^"\027[m")
let green fmt  = Printf.sprintf ("\027[32m"^^fmt^^"\027[m")
let yellow fmt = Printf.sprintf ("\027[33m"^^fmt^^"\027[m")
let blue fmt   = Printf.sprintf ("\027[36m"^^fmt^^"\027[m")

let ipaddr   = "10.0.0.2"
let netmask  = "255.255.255.0"
let gateways = ["10.0.0.1"]

module Main (C:Mirage_console_lwt.S)
            (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Ipv4.Make(E)(A)

  let or_error _c name fn t =
    fn t
    >>= function
    | `Error _e -> Lwt.fail (Failure ("Error starting " ^ name))
    | `Ok t     -> Lwt.return t

  let start c n _clock _time =
    C.log c (green "starting...");
    or_error c "Ethif" E.connect n >>= fun e ->
    or_error c "Arpv4" A.connect e >>= fun a ->
    or_error c "Ipv4" (I.connect e) a >>= fun i ->

    I.set_ip i (Ipaddr.V4.of_string_exn ipaddr) >>= fun () ->
    I.set_ip_netmask i (Ipaddr.V4.of_string_exn netmask) >>= fun () ->
    I.set_ip_gateways i (List.map Ipaddr.V4.of_string_exn gateways)
    >>= fun () ->

    let handler s = fun ~src ~dst _data ->
      C.log_s c (yellow "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      C.log_s c (red "%d DEFAULT" proto))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (C.log c (red "IP6")))
         e)
    >>= fun () ->
    C.log c (green "done!");
    Lwt.return ()

end
```

to get our next problem:

```
mirage-skeleton/ping$ make
mirage build
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules main.ml > main.ml.depends
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules key_gen.ml > key_gen.ml.depends
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o key_gen.cmo key_gen.ml
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-console-unix -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 19, characters 13-22:
Error: Unbound module Ipv4
```

#### Ipv4 -> Static_ipv4

`mirage-tcpip` renamed the `Ipv4` module to `Static_ipv4`, as part of a larger reorganization of how IP configuration works.  (You can read more in the [release notes for mirage-tcpip version 3.0.0](https://github.com/mirage/mirage-tcpip/releases/tag/v3.0.0).)  Since our unikernel isn't using the `generic_stackv4` function but rather calling the functors that make a stack directly, it has to know about this name change.  We'll tell it, to make the following `unikernel.ml`:

```ocaml

pen Lwt.Infix

let red fmt    = Printf.sprintf ("\027[31m"^^fmt^^"\027[m")
let green fmt  = Printf.sprintf ("\027[32m"^^fmt^^"\027[m")
let yellow fmt = Printf.sprintf ("\027[33m"^^fmt^^"\027[m")
let blue fmt   = Printf.sprintf ("\027[36m"^^fmt^^"\027[m")

let ipaddr   = "10.0.0.2"
let netmask  = "255.255.255.0"
let gateways = ["10.0.0.1"]

module Main (C:Mirage_console_lwt.S)
            (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Static_ipv4.Make(E)(A)

  let or_error _c name fn t =
    fn t
    >>= function
    | `Error _e -> Lwt.fail (Failure ("Error starting " ^ name))
    | `Ok t     -> Lwt.return t

  let start c n _clock _time =
    C.log c (green "starting...");
    or_error c "Ethif" E.connect n >>= fun e ->
    or_error c "Arpv4" A.connect e >>= fun a ->
    or_error c "Ipv4" (I.connect e) a >>= fun i ->

    I.set_ip i (Ipaddr.V4.of_string_exn ipaddr) >>= fun () ->
    I.set_ip_netmask i (Ipaddr.V4.of_string_exn netmask) >>= fun () ->
    I.set_ip_gateways i (List.map Ipaddr.V4.of_string_exn gateways)
    >>= fun () ->

    let handler s = fun ~src ~dst _data ->
      C.log_s c (yellow "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      C.log_s c (red "%d DEFAULT" proto))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (C.log c (red "IP6")))
         e)
    >>= fun () ->
    C.log c (green "done!");
    Lwt.return ()

end
```

### Old ground: CONSOLE -> logs

When we try to `make` this unikernel, we get a familiar error message about `C.log_s`.  Let's replace the calls to `C.log_s` with calls to the appropriate `Logs` functions, like we did in the previous example, to get the following `config.ml` that no longer passes a console:

```ocaml
open Mirage

let main =
  let packages = [package ~sublibs:["arpv4";"ethif";"ipv4"] "tcpip" ] in
  foreign
    ~packages
    "Unikernel.Main" (network @-> mclock @-> time @-> job)

let () =
  register "ping" [ main $ default_network $ default_monotonic_clock $ default_time ]
```

And a matching `unikernel.ml`, from which we've removed the color functions `red`, `green`, `yellow`, and `blue`, removed the unused `_c` argument from `or_error`, replaced `C.log` and `C.log_s` with `Logs` calls, removed the `C:Mirage_console_lwt.S` module argument to `Main`, and removed the `c` argument from `start`:

```ocaml
open Lwt.Infix

let ipaddr   = "10.0.0.2"
let netmask  = "255.255.255.0"
let gateways = ["10.0.0.1"]

module Main (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Static_ipv4.Make(E)(A)

  let or_error name fn t =
    fn t
    >>= function
    | `Error _e -> Lwt.fail (Failure ("Error starting " ^ name))
    | `Ok t     -> Lwt.return t

  let start n _clock _time =
    Logs.debug (fun f -> f "starting...");
    or_error "Ethif" E.connect n >>= fun e ->
    or_error "Arpv4" A.connect e >>= fun a ->
    or_error "Ipv4" (I.connect e) a >>= fun i ->

    I.set_ip i (Ipaddr.V4.of_string_exn ipaddr) >>= fun () ->
    I.set_ip_netmask i (Ipaddr.V4.of_string_exn netmask) >>= fun () ->
    I.set_ip_gateways i (List.map Ipaddr.V4.of_string_exn gateways)
    >>= fun () ->

    let handler s = fun ~src ~dst _data ->
      Logs.info (fun f -> f "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      Lwt.return (Logs.warn (fun f -> f "%d DEFAULT" proto)))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (Logs.warn (fun f -> f "%s" "IP6")))
         e)
    >>= fun () ->
    Logs.info (fun f -> f "done!");
    Lwt.return ()

end
```

Let's see what happens next:

```
mirage-skeleton/ping$ make depend && make
opam pin add --no-action --yes mirage-unikernel-ping-unix .
Package mirage-unikernel-ping-unix does not exist, create as a NEW
package ? [Y/n] y
mirage-unikernel-ping-unix is now path-pinned to /home/user/mirage-skeleton/ping

[mirage-unikernel-ping-unix] /home/user/mirage-skeleton/ping/ synchronized
[mirage-unikernel-ping-unix] Installing new package description from
/home/user/mirage-skeleton/ping

opam depext --yes mirage-unikernel-ping-unix
# Detecting depexts using flags: x86_64 linux debian
# The following system packages are needed:
#  - debianutils
#  - m4
#  - ncurses-dev
#  - pkg-config
#  - time
# All required OS packages found.
opam install --yes --deps-only mirage-unikernel-ping-unix

=-=- Synchronising pinned packages =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[mirage-unikernel-ping-unix] /home/user/mirage-skeleton/ping/ already up-to-date
opam pin remove --no-action mirage-unikernel-ping-unix
mirage-unikernel-ping-unix is now unpinned from path /home/user/mirage-skeleton/ping
mirage build
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 23, characters 21-30:
Error: This expression has type E.netif -> E.t Lwt.t
       but an expression was expected of type
         E.netif -> ([< `Error of 'b | `Ok of 'c ] as 'a) Lwt.t
       Type E.t = Ethif.Make(N).t is not compatible with type
         [< `Error of 'b | `Ok of 'c ] as 'a 
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-logs,mirage-net-unix,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.ipv4'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### `connect` connects directly

The `connect` functions that we're directly invoking no longer return a polymorphic variant, but rather will raise an exception if a problem occurred.  Therefore, we no longer need to wrap them in `or_error`, so we can remove that function from `unikernel.ml`:

```ocaml
open Lwt.Infix

let ipaddr   = "10.0.0.2"
let netmask  = "255.255.255.0"
let gateways = ["10.0.0.1"]

module Main (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Static_ipv4.Make(E)(A)

  let start n _clock _time =
    Logs.debug (fun f -> f "starting...");
    E.connect n >>= fun e ->
    A.connect e >>= fun a ->
    I.connect e a >>= fun i ->

    I.set_ip i (Ipaddr.V4.of_string_exn ipaddr) >>= fun () ->
    I.set_ip_netmask i (Ipaddr.V4.of_string_exn netmask) >>= fun () ->
    I.set_ip_gateways i (List.map Ipaddr.V4.of_string_exn gateways)
    >>= fun () ->

    let handler s = fun ~src ~dst _data ->
      Logs.info (fun f -> f "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      Lwt.return (Logs.warn (fun f -> f "%d DEFAULT" proto)))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (Logs.warn (fun f -> f "%s" "IP6")))
         e)
    >>= fun () ->
    Logs.info (fun f -> f "done!");
    Lwt.return ()

end
```

For our next trick, we'll solve a new problem:

```
mirage-skeleton/ping$ make
mirage build
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 18, characters 4-15:
Error: This expression has type Clock.t -> A.t Lwt.t
       but an expression was expected of type 'a Lwt.t
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-logs,mirage-net-unix,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.ipv4'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### Another tcpip function change

Line 18 is the call to `A.connect`.  The documentation for [the Arpv4 module in mirage-tcpip](http://docs.mirage.io/tcpip/Arpv4/Make/index.html), which we're invoking directly, has a [connect function](http://docs.mirage.io/tcpip/Arpv4/Make/index.html#val-connect) that expects a `Clock.t`, where `Clock` is the second module which was passed to `Arpv4.Make`.  The unikernel receives such a `Clock.t` as an argument to `start`, but it's currently ignoring it.  Let's edit `unikernel.ml` to stop ignoring `_clock`, and pass it as an argument to `A.connect`:

```ocaml
open Lwt.Infix

let ipaddr   = "10.0.0.2"
let netmask  = "255.255.255.0"
let gateways = ["10.0.0.1"]

module Main (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Static_ipv4.Make(E)(A)

  let start n clock _time =
    Logs.debug (fun f -> f "starting...");
    E.connect n >>= fun e ->
    A.connect e clock >>= fun a ->
    I.connect e a >>= fun i ->

    I.set_ip i (Ipaddr.V4.of_string_exn ipaddr) >>= fun () ->
    I.set_ip_netmask i (Ipaddr.V4.of_string_exn netmask) >>= fun () ->
    I.set_ip_gateways i (List.map Ipaddr.V4.of_string_exn gateways)
    >>= fun () ->

    let handler s = fun ~src ~dst _data ->
      Logs.info (fun f -> f "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      Lwt.return (Logs.warn (fun f -> f "%d DEFAULT" proto)))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (Logs.warn (fun f -> f "%s" "IP6")))
         e)
    >>= fun () ->
    Logs.info (fun f -> f "done!");
    Lwt.return ()

end
```

Next, we'll find some difficulties with the functions we're trying to call from `I`:

```
~/mirage-skeleton/ping$ make
mirage build
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 22, characters 4-20:
Error: Unbound value I.set_ip_netmask
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-logs,mirage-net-unix,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.ipv4'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### Ipv4 configuration

The `IP` module type no longer allows for mutable IP configuration settings.  [The type signature for `I.connect`](http://docs.mirage.io/tcpip/Static_ipv4/Make/index.html#val-connect) shows that, with some help from [Ipaddr.V4](http://docs.mirage.io/ipaddr/Ipaddr/V4/index.html) and a bit of adjustment `gateway` being `Ipaddr.V4.t option` rather than `Ipaddr.V4.t list` as `I.set_ip_gateways` previously expected, we can set the values directly when invoking `I.connect` from `unikernel.ml`:


```ocaml

open Lwt.Infix

let ipaddr   = "10.0.0.2/24"
let gateway  = "10.0.0.1"

module Main (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Static_ipv4.Make(E)(A)

  let start n clock _time =
    Logs.debug (fun f -> f "starting...");
    E.connect n >>= fun e ->
    A.connect e clock >>= fun a ->
    I.connect ~ip:(snd @@ Ipaddr.V4.Prefix.of_address_string_exn ipaddr)
              ~network:(fst @@ Ipaddr.V4.Prefix.of_address_string_exn ipaddr)
              ~gateway:(Some (Ipaddr.V4.of_string_exn gateway))
    e a >>= fun i ->

    let handler s = fun ~src ~dst _data ->
      Logs.info (fun f -> f "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      Lwt.return (Logs.warn (fun f -> f "%d DEFAULT" proto)))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (Logs.warn (fun f -> f "%s" "IP6")))
         e)
    >>= fun () ->
    Logs.info (fun f -> f "done!");
    Lwt.return ()

end
```

Let's see how we do:

```
mirage-skeleton/ping$ make
mirage build
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
+ ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
File "unikernel.ml", line 40, characters 12-14:
Error: This pattern matches values of type unit
       but a pattern was expected which matches values of type
         (unit, N.error) Result.result = (unit, N.error) result
Command exited with code 2.
run ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-tags'
     'predicate(mirage_unix),warn(A-4-41-42-44),color(always),debug,bin_annot,strict_sequence,principal,safe_string'
     '-pkgs'
     'functoria-runtime,lwt,mirage-clock-unix,mirage-logs,mirage-net-unix,mirage-runtime,mirage-types,mirage-types-lwt,mirage-unix,tcpip,tcpip.arpv4,tcpip.ethif,tcpip.ipv4'
     '-cflags' '-g' '-lflags' '-g' '-tag-line' '<static*.*>: warn(-32-34)'
     '-X' '_build-ukvm' 'main.native']: exited with 10
Makefile:18: recipe for target 'build' failed
make: *** [build] Error 1
```

### N.listen is error-aware

Our error message tells us that `N.listen` can now return an error, so our function that expects it to return `unit` is no longer valid.  We can fix this problem by changing the function on the right-hand side of the `>>=` following the call to `listen` to be a function that matches on the possible values, as we did for `T.read` in the previous example:

```ocaml
open Lwt.Infix

let ipaddr   = "10.0.0.2/24"
let gateway  = "10.0.0.1"

module Main (N:Mirage_net_lwt.S)
            (Clock: Mirage_clock_lwt.MCLOCK)
            (Time: Mirage_time_lwt.S) = struct

  module E = Ethif.Make(N)
  module A = Arpv4.Make(E)(Clock)(Time)
  module I = Static_ipv4.Make(E)(A)

  let start n clock _time =
    Logs.debug (fun f -> f "starting...");
    E.connect n >>= fun e ->
    A.connect e clock >>= fun a ->
    I.connect ~ip:(snd @@ Ipaddr.V4.Prefix.of_address_string_exn ipaddr)
              ~network:(fst @@ Ipaddr.V4.Prefix.of_address_string_exn ipaddr)
              ~gateway:(Some (Ipaddr.V4.of_string_exn gateway))
    e a >>= fun i ->

    let handler s = fun ~src ~dst _data ->
      Logs.info (fun f -> f "%s > %s %s"
                   (Ipaddr.V4.to_string src) (Ipaddr.V4.to_string dst) s);
      Lwt.return_unit
    in
    N.listen n
      (E.input
         ~arpv4:(A.input a)
         ~ipv4:(I.input
                  ~tcp:(handler "TCP")
                  ~udp:(handler "UDP")
                  ~default:(fun ~proto ~src:_ ~dst:_ _data ->
                      Lwt.return (Logs.warn (fun f -> f "%d DEFAULT" proto)))
                  i
               )
         ~ipv6:(fun _buf -> Lwt.return (Logs.warn (fun f -> f "%s" "IP6")))
         e)
    >>= function
    | Ok () ->
      Logs.info (fun f -> f "done!");
      Lwt.return ()
    | Error e ->
      Logs.warn (fun f -> f
        "failure to listen from network interface: %a"
        N.pp_error e);
      Lwt.return_unit

end
```

and now we get a buildable unikernel:

```
mirage-skeleton/ping$ make
mirage build
ocamlfind ocamldep -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -modules unikernel.ml > unikernel.ml.depends
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmo unikernel.ml
ocamlfind ocamlc -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o main.cmo main.ml
ocamlfind ocamlopt -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o key_gen.cmx key_gen.ml
ocamlfind ocamlopt -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o unikernel.cmx unikernel.ml
ocamlfind ocamlopt -c -g -g -bin-annot -safe-string -principal -strict-sequence -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix -w A-4-41-42-44 -color always -o main.cmx main.ml
ocamlfind ocamlopt -g -linkpkg -g -package tcpip.ipv4 -package tcpip.ethif -package tcpip.arpv4 -package tcpip -package mirage-unix -package mirage-types-lwt -package mirage-types -package mirage-runtime -package mirage-net-unix -package mirage-logs -package mirage-clock-unix -package lwt -package functoria-runtime -predicates mirage_unix key_gen.cmx unikernel.cmx main.cmx -o main.native
```

Hooray, we've ported another unikernel!

## My problem wasn't fixed here

If you're encountering problems that weren't discussed here, you may find useful information in the [release notes for Mirage version 3](https://github.com/mirage/mirage/releases/tag/v3.0.0).  The updated examples in [the mirage-skeleton](https://github.com/mirage/mirage-skeleton) may also be of use to you -- look in the `device-usage` directory for examples of unikernels that may be trying to use the same libraries as you are, or the `applications` category for richer examples on which you may have based a running unikernel from Mirage 2.

If neither of those is helpful to you and you're stuck, please feel free to ask in the #mirage IRC channel on [FreeNode](https://freenode.net), via e-mail at [our mailing list, mirageos-devel](https://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel), or by raising an issue on [the mirage front-end tool repository at GitHub](https://github.com/mirage/mirage/issues/new).  We welcome problem reports and contributions (including suggestions for improving this document).  Thank you for helping us improve Mirage!

