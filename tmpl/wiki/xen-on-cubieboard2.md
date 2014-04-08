# Running Xen on the Cubieboard2

Author: Thomas Leonard

Status: work-in-progress

These notes detail the process of setting up a Xen system on a Cubieboard2.
They are based on the [Xen ARM with Virtualization Extensions/Allwinner](http://wiki.xen.org/wiki/Xen_ARM_with_Virtualization_Extensions/Allwinner) documentation, but try to collect everything into one place.
I'm trying to document the exact steps I took (with the wrong turns removed); some changes will be needed for other systems.

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

I'm using Arch Linux, but similar commands should work on other distributions:

    yaourt -S arm-linux-gnueabihf-gcc

This installs files such as:

    /usr/bin/arm-linux-gnueabihf-ld
    /usr/bin/arm-linux-gnueabihf-gcc


## U-Boot

Xen needs to be started in non-secure HYP mode. Use this U-Boot Git repository:

    git clone git@github.com:jwrdegoede/u-boot-sunxi.git
    cd u-boot-sunxi
    git checkout -b sunxi-next origin/sunxi-next

Note: only the "sunxi-next" branch has the required hypervisor support; DO NOT use the "sunxi" branch.

Configure and build U-Boot using the ARM toolchain:

    make CROSS_COMPILE=arm-linux-gnueabihf- Cubieboard2_config
    make CROSS_COMPILE=arm-linux-gnueabihf- -j 4


## U-Boot configuration

Create a directory for the boot commands (e.g. "boot"). Create "boot/boot.cmd" with:

    # SUNXI Xen Boot Script
    
    # Addresses suitable for 1GB system, adjust as appropriate for a 2GB system.
    # Top of RAM:         0x80000000
    # Xen relocate addr   0x7fe00000
    setenv kernel_addr_r  0x7f600000 # 8M
    setenv ramdisk_addr_r 0x7ee00000 # 8M
    setenv fdt_addr       0x7ec00000 # 2M
    setenv xen_addr_r     0x7ea00000 # 2M
    
    setenv fdt_high      0xffffffff # Load fdt in place instead of relocating
    
    # Load xen/xen to ${xen_addr_r}.
    fatload mmc 0 ${xen_addr_r} /xen
    setenv bootargs "console=dtuart dtuart=/soc@01c00000/serial@01c28000 dom0_mem=128M"
    
    # Load appropriate .dtb file to ${fdt_addr}
    fatload mmc 0 ${fdt_addr} /sun7i-a20-cubieboard2.dtb
    fdt addr ${fdt_addr} 0x40000
    fdt resize
    fdt chosen
    fdt set /chosen \#address-cells <1>
    fdt set /chosen \#size-cells <1>
    
    # Load Linux arch/arm/boot/zImage to ${kernel_addr_r}
    fatload mmc 0 ${kernel_addr_r} /vmlinuz
    
    fdt mknod /chosen module@0
    fdt set /chosen/module@0 compatible "xen,linux-zimage" "xen,multiboot-module"
    fdt set /chosen/module@0 reg <${kernel_addr_r} 0x${filesize} >
    fdt set /chosen/module@0 bootargs "console=hvc0 ro root=/dev/mmcblk0p2 rootwait init=/bin/bash clk_ignore_unused"
    
    bootz ${xen_addr_r} - ${fdt_addr}

The above is the template from the wiki, but configured to:

- Load Xen, the FDT and Linux from mmcblk0p1
- Use mmcblk0p2 as Linux's root FS
- Wait for the device (`rootwait`)
- Run /bin/bash as init.

Create a `Makefile` to compile it:

    all: boot.scr

    %.scr: %.cmd
    	mkimage -C none -A arm -T script -d "$<" "$@"

Run `make` to build `boot.scr`.


## Building Linux

Get [linux-sunxi Git tree](https://github.com/linux-sunxi/linux-sunxi), sunxi-devel branch.

Note: DO NOT use the "sunxi-next" branch! Only the "sunxi-devel" branch has MMC support.

Configure:

    make ARCH=arm multi_v7_defconfig
    make ARCH=arm menuconfig

Here are the settings I used (TODO: this is extracted from `config.working`; check it works with just these settings and whether they're all actually necessary):

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

Then:

    make ARCH=arm zImage dtbs -j 4

## Building Xen

You can use the official [Xen 4.4 release](http://www.xenproject.org/downloads/xen-archives/xen-44-series/xen-440.html), but I used the Git version:

    git clone git://xenbits.xen.org/xen.git
    cd xen
    git checkout stable-4.4

Edit `Config.mk` and turn debug on: `debug ?= y`.
This enables some features that are useful when debugging guests, such as allowing guests to write debug messages to the Xen console.

Note: If you already built Xen without debug, `make clean` is NOT sufficient! Use `git clean -xfd` for a clean build.

Compile with:

    make dist-xen XEN_TARGET_ARCH=arm32 CROSS_COMPILE=arm-linux-gnueabihf- CONFIG_EARLY_PRINTK=sun7i -j4


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

Mount the fat partition and copy in boot.scr, the Linux kernel, the FDT and Xen:

    mount /dev/mmcblk0p1 /mnt/mmc1
    cp boot/boot.scr /mnt/mmc1/
    cp linux/arch/arm/boot/zImage /mnt/mmc1/vmlinuz
    cp linux/arch/arm/boot/dts/sun7i-a20-cubieboard2.dtb /mnt/mmc1/
    cp xen/xen/xen /mnt/mmc1/
    umount /mnt/mmc1


## Root FS

The wiki's links to the prebuilt root images are broken, but a bit of searching turns up some alternatives.

I used [linaro-saucy-developer-20140406-651.tar.gz](https://snapshots.linaro.org/ubuntu/images/developer/latest/linaro-saucy-developer-20140406-651.tar.gz).

    cd /mnt/mmc2
    sudo tar xf /data/arm/linaro-saucy-developer-20140406-651.tar.gz
    sudo mv binary/* .
    sudo rmdir binary

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

You should now be able to connect with e.g.

    ssh root@192.168.1.79

Kill the network and shut down:

    ifdown eth0
    mount -o remount,ro /
    halt -f

Remove the `init=/bin/bash` from `boot.cmd` and put the new `boot.scr` into mmcblk0p1. Then boot again.
You should now be able to ssh in directly.


## Xen toolstack

The Ubuntu 13.10 image comes with Xen 4.3, so we need to upgrade:

    apt-get install update-manager-core python-apt
    do-release-upgrade -d

Reboot and fix any problems. Edit `/etc/init/rc-sysinit.conf` if you need to change the default runlevel - for some reason, booting to level 1 and then doing `init 2` works for me, but booting directly to level 2 doesn't.

Then install the new Xen tools:

    apt-get install xen-utils-4.4

Note: if you get `add bridge failed: Package not installed`, you forgot to include Ethernet bridging in your kernel.

Once Xen 4.4 is installed, you can list your domains:

    # xl list
    Name                                        ID   Mem VCPUs      State   Time(s)
    Domain-0                                     0   128     2     r-----      15.8


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

Mount it and install an OS (e.g. Ubuntu 13.10 here):

    mount /dev/vg0/linux-guest-1 /mnt
    debootstrap --arch armhf saucy /mnt
    chroot /mnt
    passwd

Edit `/etc/hostname`, `/etc/network/interfaces`:

    auto eth0
    iface eth0 inet dhcp

`/etc/fstab` should contain:

    /dev/xvda       / ext4   rw,relatime,data=ordered       0 1

Unmount:

    apt-get install openssh-server	# (and add authorized_keys)
    exit
    umount /mnt

Note: openssh will fail to start as port 22 is taken, but it still installs.

Copy the Linux kernel image into /root (the dom0 one is fine). Create `domU_test`:

    kernel = "/root/zImage"
    memory = 512
    name = "Ubuntu-13.10"
    vcpus = 2
    serial="pty"
    disk = [ 'phy:/dev/vg0/linux-guest-1,xvda,w' ]
    vif = ['bridge=br0']
    extra = 'console=hvc0 xencons=tty root=/dev/xvda'

You should now be able to boot the Linux guest:

    xl create domU_test -c

Note: it stops for a long time (about 2 min) at `init: ureadahead main process (42) terminated with status 5`,
but it does boot eventually. You can add `init=/bin/bash` to `extra` if you want to boot faster (this is almost instant).


## Xen Mini-OS

Mini-OS is a small demonstration OS for Xen. I had to make some changes to the (experimental) ARM version to make it work on the Cubieboard2.
You'll need to install a few things to build it:

    apt-get install build-essential libfdt-dev git

Clone the repository and build:

    git clone https://github.com/talex5/xen.git
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

(to be continued...)
