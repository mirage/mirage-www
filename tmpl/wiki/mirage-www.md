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

In order to configure the unikernel, we can use the mirage tool. To see all the available options:

```
cd src
mirage configure --help
```

Alternatively, You can get a quick overview of all the options (and their current value):

```
mirage describe
```

### A Unix development workflow

For editing content and generally working with the website on a day-to-day
basis, we simply compile it using kernel sockets and a pass-through filesystem.
This is pretty similar a conventional web server, and means you can edit content
using your favourite editor (though you must restart the website binary to make
edits visible).

First, if you wish to build the site to present the site statistics (garbage
collection, etc) data, build the JavaScript:

```
make prepare
```

Then configure and build the website itself:

```
$ cd src
$ mirage configure -t unix --kv_ro crunch --net socket
$ make depend
$ make
```

Finally, run the website application:

```
$ sudo ./mir-www
```

The website will now be available on `http://localhost/`.

## Building the direct networking version

Now you can build the Unix unikernel using the direct stack, via a similar
procedure to the [hello world](/wiki/hello-world) examples. As before,
Mirage will configure the stack to use the
[tap0 interface](http://en.wikipedia.org/wiki/TUN/TAP) with an address
of `10.0.0.2/255.255.255.0`. Verify that you have an existing `tap0`
interface by reviewing `$ sudo ip link show`; if you do not,
load the tuntap kernel module (`$ sudo modprobe tun`)
and create a `tap0` interface owned by you (`$ sudo tunctl -u $USER -t tap0`).
Bring `tap0` up using `$ sudo ifconfig tap0 10.0.0.1 up`, then:

```
$ cd src
$ mirage configure -t unix --net direct
$ make
$ ./mir-www
```

You should now be able to ping the unikernel's interface:

```
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
$ mirage configure -t unix --kv_ro fat
$ make
$ sudo ./mir-www & sudo ifconfig tap0 10.0.0.1 255.255.255.0 && fg
```

The `make-fat_*-images.sh` script uses the `fat` command-line helper installed by
the `ocaml-fat` package to build the FAT block image for you. If you now access
the website, it is serving the traffic straight from the FAT image you just
created, without requiring a Unix filesystem at all!

You can inspect the resulting FAT images for yourself by using the `fat` command
line tool, and the generated scripts.

```
$ file fat_block1.img
fat1.img: x86 boot sector, code offset 0x0, OEM-ID "ocamlfat",
sectors/cluster 4, FAT  1, root entries 512, Media descriptor 0xf8,
sectors/FAT 2, sectors 1728 (volumes > 32 MB) , dos < 4.0 BootSector (0x0)

$ fat list fat_block1.img
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
$ mirage configure -t xen
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
