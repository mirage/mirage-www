---
updated: 2019-10-18 19:00
author:
  name: derpeter
  uri:
  email:
subject: MirageOS on ARM64
permalink: arm64
---

MirageOS unikernels can run on 64-bit ARM Linux systems using the [Solo5](https://github.com/Solo5/solo5)-based `hvt` and `spt` targets.

At least the following boards/SoCs have been tested:

* Raspberry Pi 3 or newer / Broadcom BCM2837
* A64-OLinuXino / Allwinner A64
* Odroid-C2 / Amlogic S905

In all cases you will need a Linux distribution using a recent **64-bit kernel**. For the Raspberry Pi 3 or newer, we recommend installing Debian Buster. You can download pre-built images from [here](https://wiki.debian.org/RaspberryPiImages).

_(Updated 2019-10-18. The following information is of historical interest, or for those who might want to cross-build a custom Linux kernel for their ARM64 board, so keeping it for now.)_

---------

Thanks to Solo5 and hvt MirageOS can run on ARM CPUs which support the ARM virtualization extensions.
As the layer for Mirage currently only supports the 64bit architecture a 64bit CPU is required.

So far this has been tested on the following SOCs.

<ul>
<li>Broadcom BCM2837 on Raspberry Pi 3/3+</li>
<li>Allwinner A64 on A64-OLinuXino / Pine A64</li>
<li>Amlogic S905 on Odroid-C2</li>
</ul>

It should be possible on all A53 based SOCs as long as a recent Kernel is available.

In the following the process to build yourself a debian based firmware image for the raspberry Pi 3/3+ is described.
For other targets the process is very similar and usually only differs in the bootloader related part.

If you are not into builing your own image, you can try to use Arch Linux as they seem to ship KVM enabled 64bit Kernel for the Raspberry Pi.

### Prerequirements 
You will need an arm64 / aarch64 cross compiler which supports -mgeneral-regs-only which was introduced in GCC-4.8. You can use e.g. the cross compiler shipped by Ubuntu or get the tool chain of your choice for your OS. We also need debootstrap to generate a root file system and qemu which helps us setting up our user land.

```bash
$ apt-get install gcc-aarch64-linux-gnu qemu-user-static debootstrap
```

### SD Card
The next step is to setup the SD card. We need to create two partitions like shown below

```ocaml
Device Boot Start End Sectors Size Id Type
2018-03-13-raspbian-stretch-lite.img1 8192 93802 85611 41,8M c W95 FAT32 (LBA)
2018-03-13-raspbian-stretch-lite.img2 98304 3629055 3530752 1,7G 83 Linux
```

You can change the last sector of second partition to the last sector of your SD card.
You can use fdisk or any other partition tool you fancy to perform this operations.

Now we need file systems. The first one needs to be fat32. The second one can be anything a Linux kernel can open. We use ext4 here.

```bash
$ sudo mkfs.vfat /dev/sdc1
$ sudo mkfs.ext4 /dev/sdc2
``` 

You can know give the partitions names for your convenience.

```bash
$ sudo fatlabel /dev/sdc1 boot
$ sudo tune2fs -L root /dev/sdc2
```

### Boot partition
As the raspberry Pi needs firmware for its GPU which is than loading the bootloader to the CPU we need these two blobs.
There are also so called overlay files which allow to alter e.g. the Pinout of the GPIO header. 
Check out the firmware files you will need

```bash
$ git clone --depth=1 https://github.com/raspberrypi/firmware
```

Copy the content of boot to your first partition. There will be some files you don't need like dtb's for older pis and some overlays but for the sake of easy updates in the future and personal laziness lets ignore that for now.

```bash
$ cp -r boot/* /<boot partition mount>/
```

You will need a config.txt in your boot partition. [https://elinux.org/RPiconfig](https://elinux.org/RPiconfig)
gives an good overview on the options.
You can start with a default config.ini 

```bash
$ wget https://github.com/RPi-Distro/pi-gen/raw/master/stage1/00-boot-files/files/config.txt
```

You may want to add
```ocaml
enable_uart=1
arm_control=0x200
kernel=Image
```
to enable the serial console (This will disable you bluetooth for now.), set the CPU to 64bit mode and choose the name of your kernel image. 

As we only have one gigabyte of memory on this board you may also want to limit the memory assigned to the GPU.
```ocaml 
gpu_mem=16
```

We also need a cmdline.txt to tell the kernel some options. We can get a default by
```bash
$ wget https://github.com/RPi-Distro/pi-gen/raw/master/stage1/00-boot-files/files/cmdline.txt
```

here we want to set the rootfs to 
```ocaml
root=/dev/mmcblk0p2 
```
and you may also want to get rid of predictable device names by adding 
```ocaml
net.ifnames=0
```

We will come back to the boot partition later when we have to build our kernel image.

### Root partition
Now we need a root file system. We use qemu-debootstrap for this as it will give us very plain Debian. For this mount the second partition somewhere. 
**Note** We here assume you SD card is present in your host system as /dev/sdc, this path may differ on your system.
E.g. on many systems it is something like /dev/mmcblk0. Make sure you mount the right partitions as this can break your system.

```bash
$ mount /dev/sdc2 /mnt
```

Now you can run the qemu debootstrap wrapper
You may want to read the debootstrap manpage at this point.

```bash
$ sudo qemu-debootstrap --arch arm64 stretch /mnt
```

This will install a minimal Debian stretch root file system to your SD card.

### Kernel
As the kernel that we got from the firmware repo is a rusty old 4.9 with 32bit and no virtualization we need to build our own. 
First we need to check out the kernel source. You can probably also get away with using a vanilla mainline kernel, but as there is a well maintained raspberry pi kernel we will use that to not miss any pi related patches.

```bash
$ git clone --depth=1 https://github.com/raspberrypi/linux.git -b rpi-4.16.y
```
**Note** We check out the branch 4.16 which my be outdated at the time you read this. So you may want to use a newer one. 

We use 
```bash
$ CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 make bcmrpi3_defconfig
```
to start with an kernel config fitting to the raspi. 

Now we need to enable virtualization. 
```bash
$ CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 make menuconfig
-> Virtualization -> 
        -> Kernel-based Virtual Machine (KVM) support *
        -> Host kernel accelerator for virtio net M
```

and we are good to go to build our kernel. 
**Note** You may want adjust the -j4 to the number of CPU cores you want to use for this. 

```bash
$ CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 make -j4 Image dtbs modules
```

We now need to copy the kernel image and the dtbs file to the SD card. 
**Note** We copy the dtb for an raspberrypi 3+, so if you use a different pi you may want to copy a different dtb file.

```bash
$ cp arch/arm64/boot/Image /<boot partition mount>/
$ cp arch/arm64/boot/dts/broadcom/bcm2710-rpi-3-b-plus.dtb /<boot partition mount>/
```

Now we need to copy the modules to the root file system.

```bash
$ sudo CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 INSTALL_MOD_PATH=/mnt make modules_install
```

As debootstrap gives us an unconfigured Debian you may want to edit 

/etc/network/interfaces
```ocaml
auto eth0
iface eth0 inet dhcp
```

/etc/fstab
```ocaml
UUID=31c566e0-0f1d-475d-9908-4740c8ca3653 / ext4 errors=remount-ro 0 1
```
You can get the uuid for your root partition by running 
```bash
$ blkid 
```
And you may also want to set a host name in /etc/hostname and /etc/hosts.
Finally you want to set a root password
```bash
$ sudo chroot /mnt
$ passwd 
$ exit
```

You should now have an bootable image. You can either hook up a serial UART cable to the pi or connect it to an HDMI screen.
You can now e.g. follow the mirage [hello world](https://mirage.io/docs/hello-world) to setup your unikernel.

