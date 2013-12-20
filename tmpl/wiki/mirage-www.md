This assumes that you've followed the [Hello World](/wiki/hello-world) instructions from earlier.
The `config.ml` for the console example earlier didn't have any interesting device drivers.  To build the Mirage website, we'll need several: two block devices for the static HTML content and the templates, and a network device to serve the traffic.

First, clone the website [source code](https://github.com/mirage/mirage-www):

{{
git clone git://github.com/mirage/mirage-www
cd mirage-www/src
less config.ml
}}

This `config.ml` is much more complex than the earlier one, but it also does a lot more!  We'll walk through it step by step.

!! Building a Unix version

The simplest development version to build is a Unix binary, with the data
served off a local filesystem.  The two block drivers are defined in `config.ml` as follows.

{{
let static_fs =
    Driver.KV_RO {
    KV_RO.name = "files";
    dirname    = "../files";
  }

let static_tmpl =
  Driver.KV_RO {
    KV_RO.name = "tmpl";
    dirname    = "../tmpl";
  }
}}

The `files` and `tmpl` key/value stores map onto the respective directories,
and any lookups will be served from that directory root.  The implementation of
this backend can be found in
[mirage/mirage-fs-unix](https://github.com/mirage/mirage-fs-unix).

We also need a driver for the HTTP network, which is here:

{{
let http =
   Driver.HTTP {
     HTTP.port  = 80;
     address    = None;
     ip         = IP.local Network.Tap0;
   }
}}

This binds the HTTP server to port 80, and hardcodes the IP address to a
convenient default local value of `10.0.0.2` (we'll come back to how to do
DHCP or another static IP later).

Finally, all this is glued together by registering the job with the new
drivers.

{{
let () =
  Job.register
    [ "Dispatch.Main",
      [ Driver.console; static_fs; static_tmpl; http ]
    ]
}} 

Looking at `src/dispatch.ml` now reveals that the `Main` functor is parameterized over more modules than our earlier `Console` example.

{{
module Main
  (C:CONSOLE)
  (FS:KV_RO)
  (TMPL:KV_RO)
  (Server:HTTP.Server) = struct
}}

Note that although both `FS` and `TMPL` share the same `KV_RO` signature, they
do not need to have the same implementation at all, and handles to one of them
cannot be passed to the other module without causing a static type error.

Now you can build the unikernel using `mirage`.

{{
mirage configure --unix
make
sudo ./mir-main
}}

This will open a [tap device](http://en.wikipedia.org/wiki/TUN/TAP) device and
assign itself a default IP of `10.0.0.2/255.255.255.0`.  You need to set up your
routing so that you can see this IP by assigning an IP to the `tap0` interface.

{{
sudo ifconfig tap0 10.0.0.1 255.255.255.0
ping 10.0.0.2
}}

If you see ping responses, then you are now communicating with the Mirage
unikernel via the OCaml TCP/IP stack!  Point your web browser at `http://10.0.0.2`
and you should be able to surf this website too.

!! Serving the site from a FAT filesystem instead

This site won't quite compile to Xen yet.  Despite doing all networking via
an OCaml TCP/IP stack, we still have a dependency on the Unix filesystem for
our files.
Mirage provides a [FAT filesystem](http://github.com/mirage/ocaml-fat) which
we'll use as an alternative.  Our new `config.ml` will now contain this:

{{
let fat_fs =
  let block = {
    Block.name = "fs_block";
    filename   = "files.img";
    read_only  = true;
  } in
  Driver.Fat_KV_RO {
    Fat_KV_RO.name = "files";
    block;
  }

let fat_tmpl =
  let block = {
    Block.name = "tmpl_block";
    filename   = "tmpl.img";
    read_only  = true;
  } in
  Driver.Fat_KV_RO {
    Fat_KV_RO.name = "tmpl";
    block;
  }

let () =
  Job.register
    [ "Dispatch.Main",
      [ Driver.console; fat_fs; fat_tmpl; http ]
    ]
}}

The FAT filesystem needs to be installed onto a block device, which we assign
to a Unix file.  The driver for this is provided via *mmap* in the
[mirage/mirage-block-unix](https://github.com/mirage/mirage-block-unix) module.

Now build the FAT version of the website.  The `config.ml` supplied in the
real mirage-www repository uses an environment variable to switch to these
variables, so we can quickly try it as follows.

{{
env MODE=fat mirage configure --unix
make
./make-fat-images.sh
sudo ./mir-main
sudo ifconfig tap0 10.0.0.1 255.255.255.0
}}

The `make-fat-images.sh` script uses the `fat` command-line helper installed
by the `ocaml-fat` package to build the FAT block image for you.
If you now access the website, it is serving the traffic straight from the
FAT image you just created, without requiring a Unix filesystem at all!

!! Building a Xen kernel

We're now ready to build a Xen kernel. 

{{
mirage configure --xen
make
}}

This will build a static kernel that uses the `ocaml-crunch` tool to convert
the static website files into an OCaml module that is linked directly into
the image.  While it of course will not work for very large websites, it's
just fine for this website (or for configuration files that will never be
very large).  The advantage of this mode is that you don't need to worry
about configuring any external block devices for your VM, and boot times are
much faster as a result.

You can now boot the `mir-main.xen` kernel using `xl` (don't forget to supply
it a VIF so that the network can work).

!!! Modifying networking to use DHCP or static IP

Chances are that the Xen kernel you just built doesn't have a useful IP address,
since it was hardcoded to `10.0.0.2`.  You can modify the HTTP driver to give
it a static IP address, as the [live deployment script](https://github.com/mirage/mirage-www/blob/master/.travis-www.ml) does.

{{
let http =
  let ip = 
    let open IP in 
    let address = Ipaddr.V4.of_string_exn "128.232.97.54" in
    let netmask = Ipaddr.V4.of_string_exn "255.255.255.224" in
    let gateway = [Ipaddr.V4.of_string_exn "128.232.97.33"] in
    let config = IPv4 { address; netmask; gateway } in
    { name = "www4"; config; networks = [ Network.Tap0 ] } 
  in
  Driver.HTTP {
    HTTP.port  = 80;
    address    = None;
    ip
  }
}}

This code assigns a static IP address and binds it to the HTTP driver.  You can
also make this DHCP instead, by:

{{
let http =
  let ip =
    let config = IP.DHCP in
    { name = "www4"; config; networks = [ Network.Tap0 ] } 
  in
  Driver.HTTP {
    HTTP.port  = 80;
    address    = None;
    ip
  }
}}

We've shown you the very low-levels of the configuration system in Mirage here.
While it's not instantly user-friendly, it's an extremely powerful way of
assembling your own components for your unikernel for whatever specialised
unikernels you want to build.

We'll talk about the deployment scripts that run the [live site](http://openmirage.org) next.
