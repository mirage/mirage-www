# MirageOS 3.10 release - IPv6

IPv6 and dual (IPv4 and IPv6) stack support https://github.com/mirage/mirage/pull/1187 https://github.com/mirage/mirage/issues/1190

Since a long time, IPv6 code was around in our TCP/IP stack (thanks to @nojb who developed it in 2014). Some months ago, @hannesm and @MagnusS got excited to use it. After we managed to fix some bugs and add some test cases, and writing more code to setup IPv6-only and dual stacks, we are eager to share this support for MirageOS in a released version. We expect there to be bugs lingering around, but duplicate address detection (neighbour solicitation and advertisements) has been implemented, and (unless "--accept-router-advertisement=false") router advertisements are decoded and used to configure the IPv6 part of the stack. Configuring a static IPv6 address is also possible (with
"--ipv6=2001::42/64").

While at it, we unified the boot arguments between the different targets: namely, on Unix (when using the socket stack), you can now pass "--ipv4=127.0.0.1/24" to the same effect as the direct stack: only listen on 127.0.0.1 (the subnet mask is ignored for the Unix socket stack).

A dual stack unikernel has "--ipv4-only=BOOL" and "--ipv6-only=BOOL" parameters, so a unikernel binary could support both Internet Protocol versions, while the operator can decide which protocol version to use. I.e. now there are both development-time (stackv4 vs stackv6 vs stackv4v6) choices, as well as the run-time choice (via boot parameter).

I'm keen to remove the stackv4 & stackv6 in future versions, and always develop with dual stack (leaving it to configuration & startup time to decide whether to enable ipv4 and ipv6).

Please also note that the default IPv4 network configuration no longer uses 10.0.0.1 as default gateway (since there was no way to unset the default gateway https://github.com/mirage/mirage/issues/1147).

For unikernel developers, there are some API changes in the Mirage module
- New "v4v6" types for IP protocols and stacks
- The ipv6_config record was adjusted in the same fashion as the ipv4_config type: it is now a record of a network (V6.Prefix.t) and gateway (V6.t option)

Some parts of the Mirage_key module were unified as well:
- Arp.ip_address is available (for a dual Ipaddr.t)
- Arg.ipv6_address replaces Arg.ipv6 (for an Ipaddr.V6.t)
- Arg.ipv6 replaces Arg.ipv6_prefix (for a Ipaddr.V6.Prefix.t)
- V6.network and V6.gateway are available, mirroring the V4 submodule

If you're ready to experiment with the dual stack: below is a diff for our basic network example (from mirage-skeleton/device-usage/network) replacing IPv4 with a dual stack, and the tlstunnel unikernel commit
https://github.com/roburio/tlstunnel/commit/2cb3e5aa11fca4b48bb524f3c0dbb754a6c8739b
changed tlstunnel from IPv4 stack to dual stack.

```
diff --git a/device-usage/network/config.ml b/device-usage/network/config.ml
index c425edb..eabc9d6 100644
--- a/device-usage/network/config.ml
+++ b/device-usage/network/config.ml
@@ -4,9 +4,9 @@ let port =
   let doc = Key.Arg.info ~doc:"The TCP port on which to listen for
incoming connections." ["port"] in
   Key.(create "port" Arg.(opt int 8080 doc))

-let main = foreign ~keys:[Key.abstract port] "Unikernel.Main" (stackv4
@-> job)
+let main = foreign ~keys:[Key.abstract port] "Unikernel.Main"
(stackv4v6 @-> job)

-let stack = generic_stackv4 default_network
+let stack = generic_stackv4v6 default_network

 let () =
   register "network" [
diff --git a/device-usage/network/unikernel.ml
b/device-usage/network/unikernel.ml
index 5d29111..1bf1228 100644
--- a/device-usage/network/unikernel.ml
+++ b/device-usage/network/unikernel.ml
@@ -1,19 +1,19 @@
 open Lwt.Infix

-module Main (S: Mirage_stack.V4) = struct
+module Main (S: Mirage_stack.V4V6) = struct

   let start s =
     let port = Key_gen.port () in
-    S.listen_tcpv4 s ~port (fun flow ->
-        let dst, dst_port = S.TCPV4.dst flow in
+    S.listen_tcp s ~port (fun flow ->
+        let dst, dst_port = S.TCP.dst flow in
         Logs.info (fun f -> f "new tcp connection from IP %s on port %d"
-                  (Ipaddr.V4.to_string dst) dst_port);
-        S.TCPV4.read flow >>= function
+                  (Ipaddr.to_string dst) dst_port);
+        S.TCP.read flow >>= function
         | Ok `Eof -> Logs.info (fun f -> f "Closing connection!");
Lwt.return_unit
-        | Error e -> Logs.warn (fun f -> f "Error reading data from
established connection: %a" S.TCPV4.pp_error e); Lwt.return_unit
+        | Error e -> Logs.warn (fun f -> f "Error reading data from
established connection: %a" S.TCP.pp_error e); Lwt.return_unit
         | Ok (`Data b) ->
           Logs.debug (fun f -> f "read: %d bytes:\n%s" (Cstruct.len b)
(Cstruct.to_string b));
-          S.TCPV4.close flow
+          S.TCP.close flow
       );

     S.listen s
```

Other bug fixes include https://github.com/mirage/mirage/issues/1188 (in https://github.com/mirage/mirage/pull/1201) and adapt to charrua 1.3.0 and arp 2.3.0 changes (https://github.com/mirage/mirage/pull/1199).
