Mirage applications can be compiled all into micro-kernels, and so have to handle traffic from [Ethernet](http://en.wikipedia.org/wiki/Ethernet) and up.  Ethernet is a low-level protocol that encapsulates [IPv4](http://en.wikipedia.org/wiki/Internet_protocol), which in turns drives the reliable [TCP](http://en.wikipedia.org/wiki/Transmission_Control_Protocol) protocol.  This web-page is then served over the [HTTP](http://en.wikipedia.org/wiki/HTTP) request/response protocol. The Mirage standard library includes an implementation of all these protocols, written in pure OCaml.

Actually developing complex code in a micro-kernel environment is not terribly productive, as you do not have access to the usual UNIX debugging tools (there are other reasons to compile to kernels that I will describe in a future post).  Luckily, many variants of UNIX provide the facility to "tap" Ethernet traffic into user-space directly via the [Tuntap](http://en.wikipedia.org/wiki/Tuntap) interface.  This post describes how to get Mirage up and running with Ethernet traffic under UNIX.

* First, ensure you have a working Mirage installation by following the [INSTALL]("https://github.com/avsm/mirage/blob/master/INSTALL.md") file in the source repository. You can verify it by running `mir tests/basic/sleep && ./tests/basic/sleep/mirage-unix` from the root source directory.

* Next, make sure your operating system supports the `tuntap` driver. On MacOS X, you will need to install [TunTapOSX](http://tuntaposx.sourceforge.net/). Most Linux distributions will have it already enabled by default. I havent had a chance to run this on *BSD yet; it will likely require a minor patch to the [driver](http://github.com/avsm/mirage/tree/master/runtime/unix) as the `ioctl` interface varies between implementations.

* Build `tests/net/tcp_echo` by `mir tests/net/tcp_echo` from the root of the source repository. If successful, you then run `sudo ./tests/net/tcp_echo/mirage-unix`, that should start up on the interface.

* The details of how to connect now vary by OS:

	* MacOS X unfortunately does not support Ethernet bridging, which means that you cannot talk to the outside world. The driver automatically assigns an IP address of `10.0.0.1 netmask 255.255.255.0` to the `tun0` interface ([see code](https://github.com/avsm/mirage/blob/master/runtime/unix/tap_stubs_macosx.c#L60)). The test application uses `10.0.0.2` for itself, and so you can test it by `ping 10.0.0.2`. If you see ping replies, and some debug output from the application, you are set!

	* Linux does support bridging, but this is not set up by default. After running the test application, run `ifconfig tap0 10.0.0.1 netmask 255.255.255.0` to set up the `tap0` interface (remember the interface will not be created until the application is run, so you cannot configure it before). Then try to `ping 10.0.0.2` and see if you get a response.

* Once this is working, you can play around with the rest of the protocol stack:

	* [ARP](http://en.wikipedia.org/wiki/Address_Resolution_Protocol) translates between Ethernet MAC addresses and IP addresses ([`lib/net/ether/arp.ml`]("https://github.com/avsm/mirage/blob/master/lib/net/ether/arp.ml")).
	* [ICMP](http://en.wikipedia.org/wiki/Internet_Control_Message_Protocol) is a control protocol for IP, usually to send back errors ([`lib/net/ether/icmp.ml`]("https://github.com/avsm/mirage/blob/master/lib/net/ether/icmp.ml")).  [IPv4](http://en.wikipedia.org/wiki/Internet_Protocol_Suite) is in [`lib/net/ether/ipv4.ml`]("https://github.com/avsm/mirage/blob/master/lib/net/ether/ipv4.ml").
	* The datagram protocol [UDP](http://en.wikipedia.org/wiki/User_Datagram_Protocol) is in [`lib/net/ether/udp.ml`]("https://github.com/avsm/mirage/blob/master/lib/net/ether/udp.ml"), and the beginnings of a [TCP](http://en.wikipedia.org/wiki/Transmission_Control_Protocol) stack is in [`lib/net/ether/tcp.ml`]("https://github.com/avsm/mirage/blob/master/lib/net/ether/tcp.ml").
	* If you have Ethernet bridging, you can use the [DHCP](http://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) client in [`lib/net/dhcp/client.ml`]("https://github.com/avsm/mirage/blob/master/lib/net/dhcp/client.ml") to get an IP address. The [`tests/net/dhcp`]("https://github.com/avsm/mirage/blob/master/tests/net/dhcp/main.ml") example shows how this works.
	* Finally, a full [DNS](http://en.wikipedia.org/wiki/Domain_Name_System) server exists in [`lib/net/dns`]("https://github.com/avsm/mirage/tree/master/lib/net/dns"). No DNS client exists, but it should be fairly easy to extend the server code.

If you want to modify the code, then just edit any of those ML files, and type in `make` at the top-level of the repository, and then rebuild the application using `mir tests/net/dhcp` or similar.  You should get familiar with the `tcpdump` utility, and graphical ones like [Wireshark](http://www.wireshark.org/). Run these against the `tap0` interface, for example:

{{
$ sudo tcpdump -i tap0 -vvvx
}}

This will show you the protocol traffic appearing on the bridge. I will describe some of the innards of the protocol code (most notably the `MPL` modules) in a future post!

