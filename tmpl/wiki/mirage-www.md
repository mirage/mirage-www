This assumes that you've followed the [Hello World](/wiki/hello-world)
instructions from earlier and are now familiar with the basic console, block
device and networking configurations from the
[mirage-skeleton](https://github.com/mirage/mirage-skeleton) repository. To
build the live MirageOS website, we'll need several device drivers: two block
devices for the static HTML content and the templates, and a network device to
actually serve the traffic.

First, clone the website [source code](https://github.com/mirage/mirage-www):

```
$ git clone git://github.com/mirage/mirage-www
$ cd mirage-www/src
$ cat config.ml
```

This `config.ml` is more complex to reflect all the different ways we want to
statically build the website, but it also does a lot more! We'll walk through it
step by step.

## Building a Unix version

The `src/config.ml` takes its configuration variables from some environment
variables, which can be supplied manually or provided via the `Makefile`:

```
MODE   ?= unix
FS     ?= crunch
NET    ?= direct
XENIMG ?= www
HOST   ?= localhost
```

These `Makefile` variables do the following:
* `MODE` is either `unix` or `xen`, selecting the backend you're compiling for.
* `FS` is either `fat` or `crunch`, depending on if you want to use an external
  block device or simply compile the website contents directly into the `mirage`
  binary.
* `NET` is either `socket` or `direct`, selecting whether you wish to use the
  host-local network stack, or the MirageOS network stack respectively. Note
  that building for `MODE=xen` implies `NET=direct`.
* `XENIMG` sets the name of the built Xen VM image and configuration.
* `HOST` sets the root domain for the site, to which links are relative.

To configure the network, the following further variables can be set:
+ `DHCP` is either `false` (or blank) or `true`, specifying whether the
  unikernel should acquire address information via DHCP on startup.
+ (`IP`,`NETMASK`,`GATEWAYS`) indicate static IP configuration and should be set
  to the desired IP address, the netmask and a `:`-separated list of gateways.
+ `TLS` is either `false` or `true` (default: `false`).
+ `REDIRECT` is set to the `https` target for all `http` requests. If `TLS` is
  set but `REDIRECT` is not, then `REDIRECT=https://$HOST` is assumed.

If neither `DHCP` nor all of `IP`, `NETMASK` and `GATEWAYS` are set, then
`IP="10.0.0.2"`, `NETMASK="255.255.255.0"` and `GATEWAYS="10.0.0.1"` are
assumed. This can be overridden by editing the `config.ml` (see the
[live website configuration](https://github.com/mirage/mirage-www/blob/master/.travis.yml)
for an example of a static IPv4 address).

### A Unix development workflow

For editing content and generally working with the website on a day-to-day
basis, we simply compile it using kernel sockets and a pass-through filesystem.
This is pretty similar a conventional web server, and means you can edit content
using your favourite editor (though you must restart the website binary to make
edits visible).

First, if you wish to build the site to present the site statistics (garbage
collection, etc) data, build the JavaScript:

```
cd stats && make depend build
```

Then configure and build the website itself:

```
$ cd src
$ env NET=socket FS=crunch mirage configure --unix
$ make
```

Alternatively you can use the toplevel `Makefile` to achieve both the above
steps:

```
$ make NET=socket FS=crunch configure
$ make build
```

Finally, run the website application:

```
$ sudo ./mir-www
```

For the rest of the tutorial, we'll call `mirage` directly rather than use the
`Makefile`, as this makes the tools usage clearer. If you run the above
commands, the website will now be available on `http://localhost/`.

## Building the direct networking version

Now you can build the Unix unikernel using the direct stack, via a similar
procedure to the [hello world](/wiki/hello-world) examples.

On Unix with a tuntap device:

```
$ cd src
$ env NET=direct mirage configure --unix
$ make
$ sudo ./mir-www
```

This will open a [tap device](http://en.wikipedia.org/wiki/TUN/TAP) device and
assign itself a default IP of `10.0.0.2`/`255.255.255.0`. You need to set up
your routing so that you can see this IP by assigning an IP to the `tap0`
interface in a separate terminal.

```
$ sudo ifconfig tap0 10.0.0.1 255.255.255.0
$ ping 10.0.0.2
```

If you see ping responses, then you are now communicating with the MirageOS
unikernel via the OCaml TCP/IP stack! Point your web browser at
`http://10.0.0.2` and you should be able to surf this website too.

### Serving the site from a FAT filesystem instead

This site won't quite compile to Xen yet. Despite doing all networking via an
OCaml TCP/IP stack, we still have a dependency on the Unix filesystem for our
files. MirageOS provides a [FAT filesystem](http://github.com/mirage/ocaml-fat)
which we'll use as an alternative. Our new `config.ml` will now contain this:

The FAT filesystem needs to be installed onto a block device, which we assign to
a Unix file. The driver for this is provided via *mmap* in the
[mirage/mirage-block-unix](https://github.com/mirage/mirage-block-unix) module.

Now build the FAT version of the website. The `config.ml` supplied in the real
`mirage-www` repository uses an environment variable to switch to these
variables, so we can quickly try it as follows.

```
$ cd src
$ env FS=fat mirage configure --unix
$ make
$ sudo ./mir-www & sudo ifconfig tap0 10.0.0.1 255.255.255.0 && fg
```

The `make-fat-images.sh` script uses the `fat` command-line helper installed by
the `ocaml-fat` package to build the FAT block image for you. If you now access
the website, it is serving the traffic straight from the FAT image you just
created, without requiring a Unix filesystem at all!

You can inspect the resulting FAT images for yourself by using the `fat` command
line tool, and the `make-fat1-image.sh` script.

```
$ file fat1.img
fat1.img: x86 boot sector, code offset 0x0, OEM-ID "ocamlfat",
sectors/cluster 4, FAT  1, root entries 512, Media descriptor 0xf8,
sectors/FAT 2, sectors 1728 (volumes > 32 MB) , dos < 4.0 BootSector (0x0)

$ fat list fat1.img
/wiki (DIR)(1856 bytes)
/wiki/xen-synthesize-virtual-disk.md (FILE)(8082 bytes)
/wiki/xen-suspend.md (FILE)(14120 bytes)
/wiki/xen-events.md (FILE)(10921 bytes)
/wiki/xen-boot.md (FILE)(5244 bytes)
/wiki/weekly (DIR)(768 bytes)
```

(The details of the file listing may vary if, for example, new posts have been
added to the site recently.)

## Building a Xen kernel

We're now ready to build a Xen kernel.  This can use eithr FAT or a builtin
crunch (to avoid the need for an external block device).  The latter is the
default, for simplicity's sake.

```
$ cd src
$ mirage configure --xen
$ make
```

This will build a static kernel that uses the `ocaml-crunch` tool to convert the
static website files into an OCaml module that is linked directly into the
image. While it of course will not work for very large websites, it's just fine
for this website (or for configuration files that will never be very large). The
advantage of this mode is that you don't need to worry about configuring any
external block devices for your VM, and boot times are much faster as a result.

You can now boot the `mir-www.xen` kernel using `sudo xl create -c www.xl` --
don't forget to edit `www.xl` to supply a VIF first though!

### Modifying networking to use DHCP or static IP

Chances are that the Xen kernel you just built doesn't have a useful IP address,
since it was hardcoded to `10.0.0.2`. You can modify the HTTP driver to give it
a static IP address, as the
[live deployment script](https://github.com/mirage/mirage-www/blob/master/.travis-www.ml)
does.

We've shown you the very low-levels of the configuration system in MirageOS
here. While it's not instantly user-friendly, it's an extremely powerful way of
assembling your own components for your unikernel for whatever specialised
unikernels you want to build.

We'll talk about the deployment scripts that run the
[live site](http://openmirage.org) in the
[next article](/docs/deploying-via-ci).
