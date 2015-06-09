Building a MirageOS unikernel for Xen, e.g., as at [the end of how to build the MirageOS website](/wiki/mirage-www) results in a Xen PV kernel with a `.xen` extension. This must be booted as a normal Xen domU kernel. The specifics vary based on your setup or cloud provider, and in some cases are wrapped up in the Mirari configuration and deployment tool.

## Open Source Xen

When using open-source Xen, you need to create a configuration file, e.g., `app.cfg`, for the VM that looks something like:

```
    name="app"
    kernel="app.xen"
```

You can launch this domain with `xm create -c app.cfg` (for Xen versions earlier than 4.1) and `xl create -c app.cfg` for Xen 4.1 or greater.

Alternatively, for Xen versions greater than 4.1, you can simply invoke Mirage to do this for you:

```
    $ mirage configure --xen
    $ make
```

The [MirageOS website](/wiki/mirage-www) contains an example.  Thie `mirage configure` will create an `xl` configuration file, and you will
then need to edit it to add any VIFs or disks required by your application.  Consult the Xen documentation for your distro for
the specifics on this.

## Amazon EC2

Amazon has recently added support for booting [user-specified kernels](http://ec2-downloads.s3.amazonaws.com/user_specified_kernels.pdf). This involves a two-stage boot procedure behind the scenes:

* The VM is launched using a `pvgrub` stub domain that is a micro-kernel containing a small grub interpreter.
* `pvgrub` mounts the root device, looks for `/boot/menu.lst`, and parses it for the default kernel location on that filesystem.
* The actual kernel is loaded into memory, and `pygrub` execs it, erasing it from memory.
* From this point on, the second kernel is active and boot proceeds normally.

So to boot a MirageOS kernel on EC2, it must first be wrapped in a block device. After that, the image needs to be bundled into an AMI, and then registered as a bootable image using the EC2 tools.

###Command Line Tools

First download the [API tools](http://aws.amazon.com/developertools/351) and [AMI tools](http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip) from Amazon.
Edit your `.profile` to add the following variables:

* `EC2_USER`: 12 digit account number (not email) obtained from the EC2 management console.
* `EC2_ACCESS`: from Account/Access credentials in the EC2 management console.
* `EC2_ACCESS_SECRET`: as above, in a different tab.
* `EC2_CERT`: location of the certificate file you download from the Account/Access page.
* `EC2_PRIVATE_KEY`: location of the private key.

There is a script that then takes care of packaging up the MirageOS kernel image and uploading it to Amazon automatically..
It is found at [scripts/ec2.sh](https://raw.github.com/samoht/mirari/master/scripts/ec2.sh), and you specify your `kernel.xen` file as the first argument to the script.

### Using micro instances

To use the EC2 `t1.micro` instances the kernel needs to reside inside an EBS volume. To create a bootable EBS volume containing an MirageOS kernel use the following steps:

* Start a t1.micro instance: `ec2-run-instances ami-7f418316 -k mirage -t t1.micro` - We need this instance to access the EBS volume which will later contain our MirageOS kernel
* Create an EBS volume: `ec2-create-volume --size 1` - We use the smallest possible size: 1G
* Attach volume to your instance: `ec2-attach-volume ${VOLUME} -i ${INSTANCE} -d /dev/sdh` - Where `$VOLUME` is your volume id and `$INSTANCE` is your instance id
* Login to the miro instance using ssh: `ssh -i mirage-ssh-key.pem ec2-user@${PUBLIC-AWS-NAME}` - Where `$PUBLIC-AWS-NAME` is your public DNS name of your running micro instance
* Create a partition on `/dev/sdh` and format it using `mkfs.ext2 /dev/sdh1` and mount the volume: `sudo mount /dev/sdh1 /mnt`
* Copy a Xen MirageOS kernel (e.g. the http example with DHCP enabled) to the running micro instance
* Login via ssh and move the kernel to `/mnt/kernel`
* Create grub directories `sudo mkdir -p /mnt/boot/grub/`
* Create grub menu.lst file in `/mnt/boot/grub/menu.lst`

```
    default 0
    timeout 1
    title Mirage-Test
         root (hd0,0)
         kernel /kernel
```

* Log out of instance
* Create EBS snapshot `ec2-create-snapshot ${VOLUME}`
* You can stop the running mirco instance now
* Register your AMI using `ec2-register --snapshot ${SNAPSHOT} --kernel aki-4e7d9527 --architecture x86_64` Note the familiar kernel id: This is the pv-grub kernel that is also used in `script/ec2.sh`.
* Start your EBS backed MirageOS kernel in a micro instance: `ec2-run-instances ${EBSAMI} -k mirage -t t1.micro`

This process could be put in a script easily.

## Xen Cloud Platform

The [Xen Cloud Platform](http://www.xen.org/products/cloudxen.html) is a distribution that provides cluster-wide support for multi-tenant VMs. It uses a command-line interface and an XML-RPC API to configure and control VMs.

There is a script in [scripts/xcp.sh](https://github.com/avsm/mirage/tree/master/scripts/xcp.sh) that takes a `kernel.xen` output from MirageOS and makes the appropriate API and SSH calls. Thanks to [Mike McClurg](https://twitter.com/mcclurmc) from Citrix for contributing this script.

## Rackspace Cloud

Noone has tried this yet. Get in touch if you do!
