First make sure you have followed the [installation
instructions](/wiki/install) to get a working Mirage installation.  The
examples below are in the
[mirage-skeleton](http://github.com/mirage/mirage-skeleton) repository. Begin
by cloning and changing directory to it:

```
$ git clone git://github.com/mirage/mirage-skeleton.git
$ cd mirage-skeleton
```

### Step 1: Hello World!

As a first step, let's build and run the Mirage "Hello World" unikernel -- this
will print `hello\nworld\n` 5 times before terminating:

```
    hello
    world
    hello
    world
    hello
    world
    hello
    world
    hello
    world
```

First, let's look at the code:

```
    $ cat console/unikernel.ml
    open Lwt

    module Main (C: V1_LWT.CONSOLE) = struct

    let start c =
      for_lwt i = 0 to 4 do
        C.log c "hello" ;
        lwt () = OS.Time.sleep 1.0 in
        C.log c "world" ;
        return ()
      done
    end
```

To veteran OCaml programmers among you, this might look a little odd: we have a
`Main` module parameterised by another module (`C`, of type `CONSOLE`) that
contains a method `start` taking a single parameter `c` (an instance of a
`CONSOLE`). This is the basic structure required to make this a Mirage
unikernel rather than a standard OCaml POSIX application.

The concrete implementation of `CONSOLE` will be supplied at compile-time,
depending on the target that you are compiling for.  This configuration is
stored in `config.ml`, which is very simple for our first application.

```
    $ cat console/config.ml
    open Mirage

    let main =
      foreign "Unikernel.Main" (console @-> job)

    let () =
      register "console" [ main $ default_console ]
```

The configuration file is a normal OCaml module that calls `register` to create
one or more jobs, each of which represent a process (with a start/stop
lifecycle).  Each job most likely depends on some device drivers; all the
available device drivers are defined in the `Mirage` module (see
[here](http://mirage.github.io/mirage/)).

In this case, the `main` variable declares that the entry point of the process
is the `Main` module from the file `unikernel.ml`.  The `@->` combinator is
used to add a device driver to the list of functor arguments in the job
definition (see `unikernel.ml`), and the final value of using this combinator
should always be a `job` if you intend to register it.

Notice that we refer to the module name as a string here, instead of directly
as an OCaml value.  The `mirage` command-line tool evaluates this configuration
file at build-time and outputs a `main.ml` that has the concrete values filled in
for you, with the exact modules varying by which backend you selected (e.g. Unix or
Xen).

Mirage mirrors the Xen model on UNIX as far as possible: your application is
built as a unikernel which needs to be instantiated and run whether on UNIX or
on Xen. When your unikernel is run, it starts much as a VM on Xen does -- and
so must be passed references to devices such as the console, network interfaces
and block devices on startup.

In this case, this simple `hello world` example requires just a console for
output, so we register a single `Job` consisting of the `Hello.Main` module
(and, implicitly its `start` function) and passing it a single reference to a
console.

You can find the module signatures of all the device drivers (such as `CONSOLE`)
in the [`types/`](https://github.com/mirage/mirage/tree/master/types) directory
of the main Mirage repository.  Since you'll find yourself referring back to
these quite often when building Mirage applications, it's worth bookmarking
the [documentation](http://mirage.github.io) for this module.

#### Building a Unix binary

We invoke all this by configuring, building and finally running the resulting
unikernel under Unix first.


```
cd console
mirage configure --unix
make depend
```

`mirage configure` will generate a `Makefile` with all the build rules included
from evaluating the configuration file.  It also creates a `main.ml` that
represents the entry point of your unikernel.  `make depend` will first check
that you have all the right OPAM packages installed to build a Unix
application, and will install them if they're not present.

```
make
```

This builds a UNIX binary called `mir-console` that contains the simple console
application.  If you are on a multicore machine and want to do parallel builds,
`export OPAMJOBS=4` (or some other value equal to the number of cores) will do
the trick.

```
# run the binary
./mir-console
```

Since this is a normal Unix binary, you can just run it directly, and observe
the exciting console commands that our `for` loop is generating.

#### Building a Xen unikernel

If you are on a 64-bit Linux system able to build Xen images, simply change
`--unix` for `--xen` to build a Xen VM:

```
mirage configure --xen
make depend
make
```

*Everything* else remains the same!  The `main.ml` and `Makefile` generated
differ significantly, but since the source code of your application was
parameterised over the `CONSOLE` type, it doesn't need to be changed to run
using the Xen console driver instead of Unix.

When you build the Xen version, you'll have a `mir-console.xen` unikernel that
can be booted as a standalone kernel. You will also have a `console.xl` Xen
configuration file in the current directory that looks something like this:

```
# Generated by Mirage (Tue, 31 Dec 2013 19:27:12 GMT).

name = 'console'
kernel = '/home/avsm/src/git/avsm/mirage-www/src/mir-console.xen'
builder = 'linux'
memory = 256
```

Edit this to customize the VM name or memory, and then run it via `xl create -c console.xl`
(or, if you're still on the older Xen, swap the `xl` command for `xm`).
You should see the same output on the Xen console as you did on the
UNIX version you ran earlier. If you need more help, or would like to boot your
Xen VM on Amazon's EC2, [click here](/wiki/xen-boot).

If you are using an ARM processor, such as the Cubie Board, you will need some extra pins that can be found [here](http://openmirage.org/blog/introducing-xen-minios-arm).

### Step 2: Getting a block device

Most useful unikernels will need to obtain data from the outside world, so
we'll explain this subsystem next.

#### Sector-addressible block devices

The [block/](https://github.com/mirage/mirage-skeleton/tree/master/block)
directory in `mirage-skeleton` contains an example of attaching a raw
block device to your unikernel.
The [V1.BLOCK](https://github.com/mirage/mirage/blob/1.1.0/types/V1.mli#L134)
interface signature contains the operations that are possible on a block
device: primarily reading and writing aligned buffers to a 64-bit offset within
the device.

On Unix, the development workflow to handle block devices is by mapping them
onto local files.  The `config.ml` for the block example looks like this:

```
open Mirage

let () =
  let main = foreign "Unikernel.Block_test" (console @-> block @-> job) in
  let img = block_of_file "disk.img" in
  register "block_test" [main $ default_console $ img]
```

The `main` binding looks much like the earlier console example, except for the
addition of a `block` device in the list.  When we register the job, we supply
a block device from a local file via `block_of_file`.

<br />
<div class="panel callout">
  <i class="fa fa-info fa-3x pull-left"> </i>
  <p>As an aside, if you have your editor configured with OCaml mode, you should be
     able to see the inferred types for some of the variables in the
     configuration file.  The <code>@-></code> and <code>$</code>
     combinators are designed such that any mismatches in the declared
     device driver types and the concrete registered implementations
     will result in a type error at configuration time.</p>
</div>


Build this on Unix in the same way as the console example.

```
cd block
mirage configure --unix
make depend
make
./generate_disk_img.sh
./mir-block_test
```

The `generate_disk_img.sh` script just calls `dd` to create an
empty file that will act as our block device.   Once it runs,
`mir-block-test` will write a series of patterns to the block device
and read them back to check that they are the same (the logic for
this is in `unikernel.ml` within the `Block_test` module).

The Xen version of this is pretty similar, except that you will
need to edit the VM configuration file to attach the `disk.img`
as a virtual block device.  First build the Xen version.

```
mirage configure --xen
make depend
make
make run
```

This will output a Xen config file called `block_test.xl`.  Edit
it to add a file-backed virtual block device, for example like
this (obviously edit the paths to reflect your local setup):

```
name = 'block_test'
kernel = '/home/avsm/src/git/avsm/mirage-skeleton/block/mir-block_test.xen'
builder = 'linux'
memory = 256
disk = [ 'file:/home/avsm/src/git/avsm/mirage-skeleton/block/disk.img,,xvda1,w']
```

Now you just need to `xl create -c block_test.xl`, and you should
see the same output as you had for the Unix one.  The difference is
that instead of going through the Linux or FreeBSD kernel, Mirage
linked in the Xen [block device driver](https://github.com/mirage/mirage-block-xen)
and mapped the unikernel block requests directly through to it.

For ARM, if `qemu` is not available, it might be better do it through `losetup` so that you can access the 'disk'.
```
sudo losetup -f ../block/disk.img
sudo losetup -a
```

```
disk = [ '/dev/loop0,,xvda1,w']
```

### Step 3: Key/value stores

The earlier block device example shows how very low-level access can work.  Now
let's move up to a more familiar abstraction: a key/value store that can
retrieve buffers from string keys.  This is essential for many common uses
such as retrieving configuration data or website HTML and images.

The [kv_ro_crunch/](https://github.com/mirage/mirage-skeleton/tree/master/kv_ro_crunch)
directory in `mirage-skeleton` contains the simplest key/value store example. The
subdirectory `t/` contains a couple of data files that the unikernel uses.  Our
example `unikernel.ml` reads in the data from one file and compares to the other
file, printing out `YES` if the values match, and `NO` otherwise.

The `config.ml` should look familiar after the earlier block and console examples:

```
open Mirage

let main =
  foreign "Unikernel.Main" (console @-> kv_ro @-> kv_ro @-> job)

let disk1 = crunch "t"
let disk2 = crunch "t"

let () =
  register "kv_ro" [ main $ default_console $ disk1 $ disk2 ]
```

We construct the `kv_ro` devices by using the `crunch` function.  This
takes a single directory as its argument, and converts that entire directory
into a static ML file that can respond with the file contents directly.
This removes the need to have an external block device entirely and is
very convenient indeed for small files.

Build the example and run it in the usual way under either Unix or Xen.
Because this no longer needs an external block device, you can run it
under Xen without having to edit the `xl` configuration file at all.
You can read the generated ML file by looking at the `static1.ml` file
in your build tree.

```
cd kv_ro_crunch
mirage configure --unix
make depend
make
less static1.ml # the generated filesystem
make run
mirage configure --xen
make depend
make
make run
sudo xl create -c kv_ro.xl
```

Of course, this scheme doesn't really scale up to large website, and
we often need a more elaborate configuration for larger datasets depending
on how we are deploying our unikernels (i.e. for development or production).
Switch to the [kv_ro/](https://github.com/mirage/mirage-skeleton/tree/master/kv_ro)
directory, which has exactly the same example as before, but with several
new configuration options: it can generate a block device that contains
a FAT filesystem that mirror the directory contents, or (when running under
Unix) simply proxy calls dynamically to the underlying filesystem.

Since the `config.ml` file is normal OCaml that is executed at build time,
all of this selection logic is simple enough.

```
open Mirage

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
  | `Crunch, `Unix -> direct_kv_ro "t"

let main =
  foreign "Unikernel.Main" (console @-> kv_ro @-> kv_ro @-> job)

let () =
  register "kv_ro" [ main $ default_console $ disk $ disk ]
```

This example is controlled by setting the `FS` environment variable
at build time.  If you set it to `fat`, then the configuration tool
will generate the appropriate settings for external filesystem access.

```
$ env FS=fat mirage configure
$ file fat1.img
fat1.img: x86 boot sector, code offset 0x0, OEM-ID "ocamlfat",
sectors/cluster 4, FAT  1, root entries 512, Media descriptor 0xf8,
sectors/FAT 1, sectors 49 (volumes > 32 MB) , dos < 4.0 BootSector (0x0)
```

However, notice that the definition of `disk` now checks to see if the build is
happening on Unix or Xen when crunch mode is requested.  If the build is Xen,
then a statically linked filesystem is used. On Unix however, the overhead
of building this can be removed by simply passing through to the underlying
filesystem, which is done via the `direct_kv_ro` implementation.

You should now be seeing the power of the Mirage configuration tool: we
have built several applications that use fairly complex concepts such as
filesystems and block devices that are independent of the implementations
(by virtue of our application logic being a functor), and then are able
to assemble several combinations of unikernels via relatively simple
configuration files.

### Step 4: Networking

Block devices don't require a huge amount of configuration, but now we
move onto networking, which sadly has far more knobs attached.  There
are several ways that we might want to configure our networking:

* On Unix, it's convenient to use the standard kernel socket API for
  developing higher level protocols (such as [HTTP](http://github.com/avsm/ocaml-cohttp).
  These run over TCP or UDP and so sockets work just fine.
* When we want finer control over the network stack, or simply to test
  the OCaml networking subsystem, we can use Unix's [tuntap](http://en.wikipedia.org/wiki/TUN/TAP)
  facility to parse Ethernet frames from userspace.  This requires additional
  configuration to assign IP addresses, and possibly configure a network
  bridge to let the unikernel talk to the outside world.
* Once the unikernel works under Unix with the direct [OCaml TCP/IP stack](https://github.com/mirage/mirage-tcpip),
  recompiling it under Xen is just a matter of linking in the [Xen netfront](https://github.com/mirage/mirage-net-xen)
  driver to provide the Ethernet frames directly to the unikernel.

All of this can be manipulated via the `config.ml` file as usual, and
we use the `NET` environment variable in the example below.
The example below is config.ml from the [stackv4/](https://github.com/mirage/mirage-skeleton/tree/master/stackv4)
directory in `mirage-skeleton`.

```
open Mirage

let main = foreign "Unikernel.Main" (console @-> stackv4 @-> job)

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

let () =
  register "network" [
    main $ default_console $ stack default_console
  ]
```

This configuration shows how composable the network stack subsystem is:
the application can be configured at compile-time to either
listen on a socket port (using the Linux kernel) *or*
use tuntap directly - the application code remains the same.
The definition of `main` just adds a new `stackv4` device driver.

The `net` handler checks to see if it's building for a socket or direct network stack.
Crucially, both the socket and direct network stacks have
a very similar modular API which you can see in [mirage/types/V1.mli](https://github.com/mirage/mirage/blob/1.1.0/types/V1.mli#L512).
This lets your applications be parameterized across either backend.

We then define the `dhcp` variable to configure the network stack to either use DHCP or
using the "default" ipv4 address
(for convenience, Mirage assigns a default of `10.0.0.2` in this case;
this is of course overridden for production deployments).
The definition of `stack` then uses `dhcp` and `net` accordingly to set up the networking stack.


<br />
<div class="panel callout">
  <i class="fa fa-info fa-3x pull-left"> </i>
  <p>You will have noticed by this stage that <code>mirage configure</code>
     invokes OPAM to install any libraries that it needs.  If your application
     needs some extra packages, you can use the optional <code>~packages</code>
     and <code>~libraries</code> arguments to <code>foreign</code> to add the extra
     OPAM packages and ocamlfind libraries.  For example, you could modify the code above to add an <a href='https://github.com/mirage/mirage-http'>HTTP library</a>.</p>
</div>

Let's get the network stack compiling on Unix first.  On a Mac, be sure
to install the [tuntap](http://tuntaposx.sourceforge.net/) kernel module
before trying this.

```
$ cd stackv4
$ mirage configure --unix
$ make
$ sudo make run
```

This Unix application is now listening simultaneously on the local
port, and also via a direct tuntap interface.  Let's test the
socket interface first by communicating via telnet, probably best using a different terminal.

```
$ telnet localhost 8080
hello!
```

Next, let's configure the direct tuntap bridge so that we have a
route available to it from our machine.

```
$ sudo ifconfig tap0 10.0.0.1 netmask 255.255.255.0
$ ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2): 56 data bytes
64 bytes from 10.0.0.2: icmp_seq=0 ttl=38 time=0.559 ms
64 bytes from 10.0.0.2: icmp_seq=1 ttl=38 time=0.161 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=38 time=0.181 ms
$ telnet 10.0.0.2 8080
hello!
```

The `ifconfig` call binds `10.0.0.1` as the gateway IP address to
our unikernel.  We then test our userspace network stack by pinging
it, and if that succeeds, the subsequent `telnet` call now retrieves
the request via the OCaml TCP/IP stack!

At this point, recompiling a Xen unikernel is pretty straightforward.
The configuration file already disables the socket-based job if a
Xen compilation is detected, leaving just the OCaml TCP/IP stack.

```
$ mirage configure --xen
$ make
$ make run
```

You will need to configure an appropriate Xen [network bridge](http://wiki.xen.org/wiki/Xen_Networking)
to connect to this.  Assuming that you have a bridge called `xenbr0`, edit the generated `stackv4.xl`
to have a VIF entry that looks like this:

```
# Generated by Mirage (Tue, 11 Feb 2014 12:07:14 GMT).

name = 'stackv4'
kernel = '/Users/avsm/src/git/avsm/mirage-skeleton/stackv4/mir-stackv4.xen'
builder = 'linux'
memory = 256
vif = ['bridge=xenbr0']
```

This tells Xen to bring up the virtual network interface and add it to the
`xenbr0` bridge with a static `10.0.0.2` IPv4 address.  If you prefer DHCP
instead, just set `env DHCP="true"`, and rerun `mirage configure --xen`.  You can
manually inspect the generated `main.ml` file to see what's happening under the
hood with the functor applications (something that we'll explain further in a
future tutorial!).

Now that we've covered the basics of configuration, block devices and
networking, let's get the real Mirage website up and running with a [networked
application](/wiki/mirage-www).
