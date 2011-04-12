The `mir-xen` build script outputs a Xen PV kernel with a `.xen` extension. This must be booted as a normal Xen domU kernel. The specifics vary based on your setup or cloud provider.

!!Open Source Xen

When using open-source Xen, you need to create a configuration file for the VM that looks something like:

{{
name="app"
memory=1024
kernel="app.xen"
vif=['bridge=eth0']
superpages=1
}}

You can launch this domain with `xm create -c app.cfg` (for Xen versions earlier than 4.1) and `xl create -c app.cfg` for Xen 4.1 or greater.

!!Amazon EC2

Amazon has recently added support for booting [user-specified kernels](http://ec2-downloads.s3.amazonaws.com/user_specified_kernels.pdf). This involves a two-stage boot procedure behind the scenes:

* The VM is launched using a `pvgrub` stub domain that is a micro-kernel containing a small grub interpreter.
* `pvgrub` mounts the root device, looks for `/boot/menu.lst`, and parses it for the default kernel location on that filesystem.
* The actual kernel is loaded into memory, and `pygrub` execs it, erasing it from memory.
* From this point on, the second kernel is active and boot proceeds normally.

So to boot a Mirage kernel on EC2, it must first be wrapped in a block device. After that, the image needs to be bundled into an AMI, and then registered as a bootable image using the EC2 tools.

There is a script that does most of this work for you in [scripts/ec2.sh](https://github.com/avsm/mirage/tree/master/scripts/ec2.sh). You need to install the command-line tools from Amazon, set the `EC2_PRIVATE_KEY`, `EC2_CERT`, `EC2_USER`, `EC2_ACCESS` and `EC2_ACCESS_SECRET` environment variables, and specify your `kernel.xen` file as the first argument to the script.

This support can be improved a lot, and we should also wrap the kernel as an EBS image instead of an AMI so that it can be booted on the `m1.micro` (free-tier) instances that do not support AMI storage. Anyone sufficiently motivated, please send in a patch.

!!Xen Cloud Platform

The [Xen Cloud Platform](http://www.xen.org/products/cloudxen.html) is a distribution that provides cluster-wide support for multi-tenant VMs. It uses a command-line interface and an XML-RPC API to configure and control VMs.

There is a script in [scripts/xcp.sh](https://github.com/avsm/mirage/tree/master/scripts/xcp.sh) that takes a `kernel.xen` output from Mirage and makes the appropriate API and SSH calls. Thanks to [Mike McClurg](https://twitter.com/mcclurmc) from Citrix for contributing this script.

!!Rackspace

Noone has tried this yet. Get in touch if you do!
