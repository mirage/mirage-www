---
updated: 2014-04-16 17:30
author:
  name: Thomas Leonard
  uri: http://roscidus.com/blog/
  email: talex5@gmail.com
subject: Running Xen on the Cubieboard2
permalink: xen-on-cubieboard2
---

**Author:** Thomas Leonard, addendums from Anil Madhavapeddy

These notes detail the process of setting up a Xen system on a Cubieboard2 (or Cubietruck).
They are based on the [Xen ARM with Virtualization Extensions/Allwinner](http://wiki.xen.org/wiki/Xen_ARM_with_Virtualization_Extensions/Allwinner) documentation, but try to collect everything into one place.
I'm trying to document the exact steps I took (with the wrong turns removed); some changes will be needed for other systems.

**TL;DR**: There is now a script available that generates an image with Xen, Ubuntu dom0, and the OCaml tools installed.  Just run the `make` instructions at [mirage/xen-arm-builder](https://github.com/mirage/xen-arm-builder) and copy the resulting image onto an SDcard and boot up your Cubieboard2 or Cubietruck (password `mirage`/`mirage` which you should change as the first thing you do). The script is kept more up-to-date than the instructions on this page.

The remainder of this guide covers:

* Installing U-Boot, Xen and a Linux Dom0
* Running a Linux DomU
* Running a FreeBSD DomU
* Running a Mini-OS DomU



## Warning: Out of date

_(Updated 2020-10-26. The following information is of historical interest, since MirageOS 3.9.0 our Xen backend has been revised, and only supports PVH mode and x86_64 as architecture.)_


## Glossary

[ARMv7](http://en.wikipedia.org/wiki/ARM_architecture)
: Version 7 of the ARM architecture, which adds optional virtualisation support.

[ARM Cortex-A7](http://www.arm.com/products/processors/cortex-a/cortex-a7.php)
: A 32-bit RISC CPU designed by ARM. It implements ARMv7, including the virtualisation extensions.

[sunxi](http://linux-sunxi.org)
: An ARM SoC (System-on-Chip) family, made by Allwinner Tech.

[A20](http://linux-sunxi.org/A20)
: An SoC with two Cortex-A7 CPUs (plus GPU, memory controller, etc).

[Cubieboard2](http://docs.cubieboard.org/products/start)
: A small board with an A20, 1 GB RAM, etc.

[SPL](http://wandboard.org/index.php/57-20131104-wandboard-spl-universal-boot) (Secondary Program Loader)
: "SPL is a very small bootloader able to fit into the very small amount of memory (128kB) available inside the CPU. SPL does autodetection and sets up memory accordingly. After memory is set up, SPL loads u-boot, and the booting proceeds as usual."



### Initial testing

This step can be skipped, but it's useful to check that everything works.

Download [Cubieez](http://www.cubieforums.com/index.php/topic,528.0.html), a Debian 7.1 image that works on the Cubieboard2.
Write to microSD card with:

    dd if=cubieez_1.0.0_A20.img of=/dev/mmcblk0

You will need to hook up the serial console on the Cubieboard, being careful not to connect up one of the pins.
One good cable that is known is work can be bought [here](http://proto-pic.co.uk/usb-to-ttl-serial-cable-debug-console-cable-for-raspberry-pi/).
Follow the instructions at the [Sunxi/TTL](http://linux-sunxi.org/Cubieboard/TTL) page to connect up 3 of the cables to the right pins.

Connect the USB serial cable and run "screen" to monitor it:

    screen -h 10000 /dev/ttyUSB0 115200

Note: I tried using "minicom" first, but for some reason keyboard input didn't work with that.

Insert microSD card in board and connect power. You should see boot messages in screen:

    U-Boot SPL 2013.04-07297-gc8f265c (Jun 17 2013 - 17:26:22)
    Board: Cubieboard2
    DRAM: 1024MB
    CPU: 960000000Hz, AXI/AHB/APB: 3/2/2
    SUNXI SD/MMC: 0

You can connect a keyboard/mouse/screen and use it. The login is cubie/cubieboard.

If the device boots instead into Android then it is probably booting from NAND (it tries the microSD first, then the NAND).


## ARM Toolchain

To build the various binaries (U-Boot, Linux, Xen), we need an [ARM cross-compiler toolchain](http://linux-sunxi.org/Toolchain).

[The A20 has hardware FPU](http://en.wikipedia.org/wiki/ARM_Cortex-A7_MPCore), so use the hf version of the cross-compiler for best performance.

On Arch Linux, run:

    yaourt -S arm-linux-gnueabihf-gcc

On Debian testing, run (as root):

    apt-get install gcc-arm-none-eabi

On a modern Ubuntu, run:

    sudo apt-get install gcc-arm-linux-gnueabihf

This installs files such as, say, on Ubuntu:

    /usr/bin/arm-linux-gnueabihf-ld
    /usr/bin/arm-linux-gnueabihf-gcc

Take note of the common prefix.  Define a variable to hold it:

    export CROSS_COMPILE=arm-linux-gnueabihf-

## U-Boot

Xen needs to be started in non-secure HYP mode. Use this U-Boot Git repository:

    git clone git://github.com/jwrdegoede/u-boot-sunxi.git
    cd u-boot-sunxi
    git checkout -b sunxi-next origin/sunxi-next

**WARNING** This branch no longer exists.

Note: only the "sunxi-next" branch has the required hypervisor support; DO NOT use the "sunxi" branch.

Configure and build U-Boot using the ARM toolchain:

    make CROSS_COMPILE=$CROSS_COMPILE Cubieboard2_config
    make CROSS_COMPILE=$CROSS_COMPILE -j 4

## U-Boot configuration

Create a directory for the boot commands (e.g. `boot`). Create
`boot/boot.cmd` whose content is the same as
[boot-cubieboard2.cmd](https://github.com/mirage/xen-arm-builder/blob/master/boot/boot-cubieboard2.cmd)
for the Cubieboard2 or
[boot-cubietruck.cmd](https://github.com/mirage/xen-arm-builder/blob/master/boot/boot-cubietruck.cmd)
for the Cubietruck.

The above is configured to:

- Load Xen, the FDT and Linux from `mmcblk0p1`
- Use `mmcblk0p2` as Linux's root FS
- Wait for the device (`rootwait`)
- Run `/bin/bash` as init.

More information on
[the format of `boot.cmd`](http://www.denx.de/wiki/view/DULG/UBoot)
is available on the [denx site](http://www.denx.de/wiki/view/DULG/Manual).

Create a `boot/Makefile` to compile it using
[mkimage](https://github.com/jwrdegoede/u-boot-sunxi/blob/sunxi/doc/mkimage.1):

    all: boot.scr

    %.scr: %.cmd
        ../tools/mkimage -C none -A arm -T script -d "$<" "$@"

Go to `boot` and run `make` to build `boot.scr`.

Remark: You may have noticed that the above `.cmd` files allocate a
rather large amount of memory to `dom0` (look at the `dom0_mem`
parameter).  This is needed to compile large libraries like
[Core](https://github.com/janestreet/core).
However, if you use `autoballoon=on` in
[`/etc/xen/xl.conf`](http://xenbits.xen.org/docs/unstable/man/xl.conf.5.html),
`xl` will automatically reduce the amount of memory assigned to dom0
to free memory for new domains.  An OCaml daemon
[squeezed](https://github.com/xapi-project/squeezed), currently in
development (and based on
[xenopsd](https://github.com/xapi-project/xenopsd)), will dynamically
move memory between dom0 and VMs to satisfy their needs.

## Building Linux

Get my [Linux Git tree](https://github.com/talex5/linux.git), master branch. This fork has a few extra patches we need.

    cd ../..
    git clone https://github.com/talex5/linux.git
    cd linux

Configure:

    make ARCH=arm multi_v7_defconfig
    make ARCH=arm menuconfig

Here are the settings I used (check it works with just these settings and whether they're all actually necessary):

    CONFIG_CROSS_COMPILE="/usr/bin/arm-linux-gnueabihf-"
    CONFIG_XEN_DOM0=y
    CONFIG_XEN=y
    CONFIG_IPV6=y
    CONFIG_NETFILTER=y
    CONFIG_NETFILTER_ADVANCED=y
    CONFIG_BRIDGE_NETFILTER=y
    CONFIG_STP=y
    CONFIG_BRIDGE=y
    CONFIG_SYS_HYPERVISOR=y
    CONFIG_XEN_BLKDEV_FRONTEND=y
    CONFIG_XEN_BLKDEV_BACKEND=y
    CONFIG_AHCI_SUNXI=y
    CONFIG_XEN_NETDEV_FRONTEND=y
    CONFIG_XEN_NETDEV_BACKEND=y
    CONFIG_INPUT_AXP20X_PEK=y
    CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y
    CONFIG_HVC_DRIVER=y
    CONFIG_HVC_IRQ=y
    CONFIG_HVC_XEN=y
    CONFIG_HVC_XEN_FRONTEND=y
    CONFIG_MFD_AXP20X=y
    CONFIG_REGULATOR_AXP20X=y
    CONFIG_FB_SYS_FOPS=y
    CONFIG_FB_DEFERRED_IO=y
    CONFIG_XEN_FBDEV_FRONTEND=y
    CONFIG_MMC_SUNXI=y
    CONFIG_VIRT_DRIVERS=y
    CONFIG_XEN_BALLOON=y
    CONFIG_XEN_SCRUB_PAGES=y
    CONFIG_XEN_DEV_EVTCHN=y
    CONFIG_XEN_BACKEND=y
    CONFIG_XENFS=y
    CONFIG_XEN_COMPAT_XENFS=y
    CONFIG_XEN_SYS_HYPERVISOR=y
    CONFIG_XEN_XENBUS_FRONTEND=y
    CONFIG_XEN_GNTDEV=y
    CONFIG_XEN_GRANT_DEV_ALLOC=y
    CONFIG_SWIOTLB_XEN=y
    CONFIG_XEN_PRIVCMD=y
    ONFIG_PHY_SUN4I_USB
    CONFIG_HAS_IOPORT=y

    # LVM
    CONFIG_MD=y
    CONFIG_BLK_DEV_DM_BUILTIN=y
    CONFIG_BLK_DEV_DM=y
    CONFIG_DM_BUFIO=y
    CONFIG_DM_SNAPSHOT=y

A simpler alternative to `make ARCH=arm menuconfig` is to copy
[`config-cubie2`](https://github.com/mirage/xen-arm-builder/blob/master/config/config-cubie2)
to `.config`
(note that `CONFIG_CROSS_COMPILE` *must* have the value of `$CROSS_COMPILE`).

Then:

    make ARCH=arm zImage dtbs modules -j 4

## Building Xen

Currently, some minor patches are needed to the official [Xen 4.4 release](http://www.xenproject.org/downloads/xen-archives/xen-44-series/xen-440.html), so use this Git version:

    cd ..
    git clone -b stable-4.4 https://github.com/talex5/xen.git
    cd xen

Edit `Config.mk` and turn debug on: `debug ?= y`.
This enables some features that are useful when debugging guests, such as allowing guests to write debug messages to the Xen console.

Note: If you already built Xen without debug, `make clean` is NOT sufficient! Use `git clean -xfd` for a clean build.

Compile with:

    make dist-xen XEN_TARGET_ARCH=arm32 CROSS_COMPILE=$CROSS_COMPILE CONFIG_EARLY_PRINTK=sun7i -j4


## Partitioning the SD card

Source: [Bootable SD card](http://linux-sunxi.org/Bootable_SD_card)

Clear the device (maybe not really necessary):

    dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=1

Create a partition table. I used gparted (Device -> Create Partition Table -> msdos).

Create the partitions (a 16 MB FAT boot partition, a 4 GB dom0 root, and the rest for the guests as an LVM volume):

    sfdisk -R /dev/mmcblk0
    cat <<EOT | sudo sfdisk --in-order -uM /dev/mmcblk0
    1,16,c
    ,4096,L
    ,,8e
    EOT

    mkfs.vfat /dev/mmcblk0p1
    mkfs.ext4 /dev/mmcblk0p2


## Installing the bootloader

Write the U-Boot SPL and main program:

    dd if=u-boot-sunxi-with-spl.bin of=/dev/mmcblk0 bs=1024 seek=8

Mount the fat partition and copy in `boot.scr`, the Linux kernel, the
FDT and Xen (you must create `/mnt/mmc1` if it does not exist):

    mount /dev/mmcblk0p1 /mnt/mmc1
    cp u-boot-sunxi/boot/boot.scr /mnt/mmc1/
    cp linux/arch/arm/boot/zImage /mnt/mmc1/vmlinuz
    cp linux/arch/arm/boot/dts/sun7i-a20-cubieboard2.dtb /mnt/mmc1/
    cp xen/xen/xen /mnt/mmc1/
    umount /mnt/mmc1

For the Cubietruck, replace the third line with:

    cp linux/arch/arm/boot/dts/sun7i-a20-cubietruck.dtb /mnt/mmc1/

(You must run these commands as root or prefix them with `sudo`.)

## Root FS

The wiki's links to the prebuilt root images are broken, but a bit of searching turns up some alternatives.

I used [linaro-trusty-developer-20140522-661.tar.gz](http://releases.linaro.org/14.05/ubuntu/trusty-images/developer/linaro-trusty-developer-20140522-661.tar.gz).

    mount /dev/mmcblk0p2 /mnt/mmc2
    cd /mnt/mmc2
    sudo tar xf /your/path/to/linaro-trusty-developer-20140522-661.tar.gz
    sudo mv binary/* .
    sudo rmdir binary

Go back to the directory where you compiled your Linux kernel and do:

    make ARCH=arm INSTALL_MOD_PATH='/mnt/mmc2' modules_install

`/mnt/mmc2/etc/fstab` should contain:

    /dev/mmcblk0p2  / ext4   rw,relatime,data=ordered       0 1

`/mnt/mmc2/etc/resolv.conf`:

    nameserver 8.8.8.8

Append to `/mnt/mmc2/etc/network/interfaces` (this sets up a bridge, which will be useful for guest networking):

    auto lo
    iface lo inet loopback

    auto eth0
    iface eth0 inet manual
      up ip link set eth0 up

    auto br0
    iface br0 inet dhcp
      bridge_ports eth0

Unmount:

    umount /mnt/mmc2

## Boot process

At this point, it's possible to boot and get the U-Boot prompt and run Xen and Dom0:

    U-Boot SPL 2014.04-rc2-01269-gf8616c0 (Apr 07 2014 - 18:53:46)
    Board: Cubieboard2
    DRAM: 1024 MiB
    CPU: 960000000Hz, AXI/AHB/APB: 3/2/2
    spl: not an uImage at 1600


    U-Boot 2014.04-rc2-01269-gf8616c0 (Apr 07 2014 - 18:53:46) Allwinner Technology

    CPU:   Allwinner A20 (SUN7I)
    Board: Cubieboard2
    I2C:   ready
    DRAM:  1 GiB
    MMC:   SUNXI SD/MMC: 0
    *** Warning - bad CRC, using default environment

    In:    serial
    Out:   serial
    Err:   serial
    Net:   dwmac.1c50000
    Warning: failed to set MAC address

    Hit any key to stop autoboot:  0

The first bit "U-Boot SPL" is the SPL running, setting up the RAM and loading the main U-Boot.
The "spl: not an uImage at 1600" warning is harmless. It looks at offset 1600 first, and then tries 80 next and succeeds.

The "bad CRC" warning is just because we didn't specify an environment file.


## Dom0 setup

After booting, you should get a root prompt. Install openssh:

    mount -o remount,rw /
    mount -t proc proc /proc
    export PATH=/bin:/usr/bin:/sbin:/usr/sbin
    export HOME=/root
    ifup eth0
    ip addr show dev eth0
    apt-get install openssh-server

Add your ssh key:

    cd
    mkdir .ssh
    vi .ssh/authorized_keys

Install Avahi:

    apt-get install avahi-daemon libnss-mdns

You must also install these packages and `avahi-utils` on your
computer.

You probably want to give your Cubieboard a nice name.  Edit
`/etc/hostname` and replace the existing name with the one of your
choice — `cubie2` for the following.
(You should also change `linaro-developer` in `/etc/hosts`
to `cubie2`.)
For the changes to take effect, you can either reboot or run
`hostname cubie2` followed by `/etc/init.d/avahi-daemon restart`.
You should now be able to connect with e.g., from your computer

    ssh root@cubie2.local

To see the list of Avahi services on your network, do `avahi-browse
-alr`.  If you do not see your Cubieboard, check that its network is
up: doing

    ip addr show

at the Cubieboard root prompt, should output some information
including a line starting with `br0:
<BROADCAST,MULTICAST,UP,LOWER_UP>`.  If it doesn't try

    brctl addbr br0

If you get `add bridge failed: Package not installed`, you forgot to
include Ethernet bridging in your kernel (it is included with the
recommended `.config` file above so this should not happen).

Kill the network and shut down:

    ifdown eth0
    mount -o remount,ro /
    halt -f

Remove the `init=/bin/bash` from `boot.cmd` and put the new `boot.scr` into mmcblk0p1. Then boot again.
You should now be able to ssh in directly.


## Xen toolstack

Ssh to your Cubieboard and install the Xen tools:

    apt-get install xen-utils-4.4

Once Xen 4.4 is installed, you can list your domains:

    # xl list
    Name                                        ID   Mem VCPUs      State   Time(s)
    Domain-0                                     0   512     2     r-----      19.7


## LVM configuration

Install the LVM tools in dom0 and set up the volume group:

    apt-get install lvm2
    pvcreate /dev/mmcblk0p3
    vgcreate vg0 /dev/mmcblk0p3

## Linux DomU

Source: [Xen ARM with Virtualization Extensions/RootFilesystem](http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/RootFilesystem)

Create a new LVM partition for the guest's root FS and format it:

    lvcreate -L 4G vg0 --name linux-guest-1
    /sbin/mkfs.ext4 /dev/vg0/linux-guest-1

Note: we're going to make a fairly big VM, as we'll be using it as a build machine soon.

Mount it and install an OS (e.g. Ubuntu 14.04 here):

    mount /dev/vg0/linux-guest-1 /mnt
    debootstrap --arch armhf trusty /mnt
    chroot /mnt
    passwd

Edit `/etc/hostname`, `/etc/network/interfaces`:

    auto eth0
    iface eth0 inet dhcp

`/etc/fstab` should contain:

    /dev/xvda       / ext4   rw,relatime,data=ordered       0 1

Add any extra software you want:

    apt-get install openssh-server
    mkdir -m 0700 /root/.ssh
    vi /root/.ssh/authorized_keys

Note: openssh will fail to start as port 22 is taken, but it still installs.

Unmount:

    exit
    umount /mnt

Copy the Linux kernel image into /root (the dom0 one is fine). Create `domU_test`:

    kernel = "/root/zImage"
    memory = 512
    name = "Ubuntu-14.04"
    vcpus = 2
    serial="pty"
    disk = [ 'phy:/dev/vg0/linux-guest-1,xvda,w' ]
    vif = ['bridge=br0']
    extra = 'console=hvc0 xencons=tty root=/dev/xvda'

You should now be able to boot the Linux guest:

    xl create domU_test -c


## FreeBSD guest

Source: [Add support for Xen ARM guest on FreeBSD](http://lists.freebsd.org/pipermail/freebsd-xen/2014-January/001974.html)

I created a VM on my laptop and installed FreeBSD from [FreeBSD-10.0-RELEASE-amd64-bootonly.iso](http://www.freebsd.org/where.html). I then used that to cross-compile the Xen/ARM version. Your build VM will need to have at least 4 GB of disk space.

Get the `xen-arm-v2` branch:

    git clone git://xenbits.xen.org/people/julieng/freebsd.git -b xen-arm-v2

Note: I tested with the `xen-arm` branch, but the `xen-arm-v2` branch has some useful fixes.

Note: Installing Git using FreeBSD using ports on a clean system is very slow, uses a lot of disk space, requires many confirmations and, in my case, failed. So I suggest cloning the repository with your main system and then transferring the files directly to the FreeBSD build VM instead.

In the build FreeBSD (note: the build takes several hours; you might want to assign multiple CPUS to your VM and use `-j` here):

    cd freebsd
    truncate -s 512M xenvm.img
    mdconfig -f xenvm.img -u0
    newfs /dev/md0
    mount /dev/md0 /mnt

    make TARGET_ARCH=armv6 kernel-toolchain
    make TARGET_ARCH=armv6 KERNCONF=XENHVM buildkernel
    make TARGET_ARCH=armv6 buildworld
    make TARGET_ARCH=armv6 DESTDIR=/mnt installworld distribution

    echo "/dev/xbd0 / ufs rw 1 1" > /mnt/etc/fstab
    echo 'xc0 "/usr/libexec/getty Pc" xterm on secure' >> /mnt/etc/ttys

    umount /mnt
    mdconfig -d -u0

Then you can copy `xenvm.img` and the kernel (`/usr/obj/arm.armv6/root/freebsd/sys/XENHVM/kernel`) to dom0 on the Cubieboard2.
You might want to rename the kernel (e.g. to `freebsd-kernel`).

Create a new partition for it and copy the filesystem in:

    lvcreate --name freebsd -L 512M vg0
    dd if=xenvm.img of=/dev/vg0/freebsd

Here's a suitable `freebsd.cfg` config file:

    kernel="freebsd-kernel"
    memory=64
    name="freebsd"
    vcpus=1
    autoballon="off"
    disk=[ 'phy:/dev/vg0/freebsd,xvda,w' ]

If you try to start the domain with Debian's version of `xl`, you'll get `Unable to find arch FDT info for xen-3.0-unknown`.
To fix this, you need to rebuild the Xen toolstack with these two patches (I applied them to the `stable-4.4` branch):

- https://patches.linaro.org/22228/
- https://patches.linaro.org/22227/

Build it using the ARM build guest:

    cd xen/tools
    ./configure --prefix=/opt/xen-freebsd
    make
    make install

Transfer `/opt/xen-freebsd` to dom0 and you can then start the FreeBSD domain with:

    export LD_LIBRARY_PATH=/opt/xen-freebsd/lib/
    /opt/xen-freebsd/sbin/xl create -c freebsd.cfg

You should get a root prompt:

    # uname -a
    FreeBSD  11.0-CURRENT FreeBSD 11.0-CURRENT #2: Tue Apr 15 20:37:04 BST 2014     root@freebsd:/usr/obj/arm.armv6/root/freebsd/sys/XENHVM  arm


## Xen Mini-OS

Mini-OS is a small demonstration OS for Xen. I had to make some changes to the (experimental) ARM version to make it work on the Cubieboard2.
You'll need to install a few things to build it:

    apt-get install build-essential libfdt-dev git

Clone the repository and build:

    git clone -b devel https://github.com/talex5/xen.git
    cd xen/extras/mini-os
    make

Transfer the resulting `mini-os.img` to your dom0 and add a configuration file for it:

    kernel = "/root/mini-os.img"
    memory = 128
    name = "Mini-OS"
    vcpus = 1
    serial="pty"
    disk = [ 'phy:/dev/vg0/mini-os,xvda,w' ]
    vif = ['bridge=br0']

Create a disk for it:

    lvcreate -L 8M vg0 --name mini-os

You should now be able to start it:

    xl create mini-os.cfg

On success, it will write lots of text to the Xen console (note: this requires a debug build of Xen):

    (d6) dtb_pointer : 87fff000
    (d6) MM: Init
    (d6)     _text: 80008000(VA)
    (d6)     _etext: 80018f1c(VA)
    (d6)     _erodata: 8001b000(VA)
    (d6)     _edata: 8002820c(VA)
    (d6)     stack start: 8001c000(VA)
    (d6)     _end: 8002dee0(VA)
    (d6)     start_pfn: 80415
    (d6)     max_pfn: 8282d
    (d6) MM: Initialise page allocator for 80415000(80415000) - 0(8282d000)
    (d6) MM: done
    (d6) Initialising timer interface
    ...

You can now try [running a MirageOS unikernel](/blog/introducing-xen-minios-arm).

