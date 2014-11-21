1. Download and unpack the image for your board.
http://blobs.openmirage.org/cubieboard2-xen-iso.tar.bz2
http://blobs.openmirage.org/cubietruck-xen-iso.tar.bz2

2. Copy to the SDcard, e.g.
dd if=cubie.img of=/dev/mmcblk0

3. Boot the device. It should get an IP address by DHCP.

The devices announce a .local name using mDNS, so you should be able to ssh to $BOARD.local
4. ssh mirage@cubieboard2.local.

To change hostname of the cubieboard:

1. edit /etc/hosts
127.0.1.1       newname

2. edit /etc/hostname
newname

To change the cubieboard to get a static ip address:

1. edit /etc/network/interfaces and update with:

//
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet manual
  up ip link set eth0 up

auto br0
iface br0 inet static
  bridge_ports eth0
  address 192.168.1.11
  broadcast 192.168.1.255
  netmask 255.255.255.0
  gateway 192.168.1.254
//

reboot

To set up ssh:

1. ssh mirage@192.168.1.11 (password: mirage)

2. ssh-keygen

3. logout (ctrl-d)

4. scp ~/.ssh/id_rsa.pub mirage@192.168.1.11:.ssh/authorized_keys

5. ssh  mirage@192.168.1.11

6. chmod 700 ~/.ssh

7. chmod 600 ~/.ssh/authorized_keys

You should now have a working Xen host ("xl list" to list current VMs, "lvcreate"
to create guest disks).

To install the ARM version of mirage:

1. opam init

2. opam install mirage

(You should now be able to follow the rest of the Mirage tutorial:)

To install libvirt (the precompiled version doesn't contain the drivers for xen):

1. sudo apt-get install uuid-dev libxml2-dev libdevmapper-dev libpciaccess-dev \
   libnl-dev libxen-dev libgnutls-dev

2. download a release tarball from libvirt.org (I used 1.2.6) (download to local
   machine, decompress, scp libvirt-1.2.6.tar mirage@cubieboard2:

3. ssh mirage@cubieboard2; tar xf libvirt-1.2.6.tar; rm libvirt-1.2.6.tar; cd libvirt-1.2.6

3. ./configure --prefix=/usr --localstatedir=/var  --sysconfdir=/etc --with-xen \
   --with-qemu=no --with-gnutls --with-uml=no --with-openvz=no --with-vmware=no \
   --with-phyp=no --with-xenapi=no --with-libxl=yes --with-vbox=no --with-lxc=no \
   --with-esx=no  --with-hyperv=no --with-parallels=no --with-init-script=upstart

4. make

5. sudo make install

6. Add the two scripts (below, if they don't already exist) to 
   /etc/init.d/libvirt-bin and /etc/default/libvirt-bin

6. Ensure that /etc/default/libvirt-bin has '-l' to libvirtd_opts

7. Follow the instructions in http://wiki.libvirt.org/page/TLSSetup in install 
   tls on the cubieboards and admin machine

8. cd /etc/rc5.d
   sudo ln -s ../init.d/libvirt-bin S22libvirt-bin

9. cd /etc/rc6.d
   sudo ln -s ../init.d/libvirt-bin K19libvirt-bin
   sudo  update-rc.d libvirt-bin defaults
   sudo service libvirt-bin start

10. Reboot the board

11. From the admin machine, edit /etc/hosts and add the cubieboard addresses and
    names so that (a) the names are resolvable and (b) matches the name on the certificates

ie.
192.168.1.10 cubieboard2

Test that the admin machine can talk to the cubieboard:

1. sudo virsh -c xen://cubieboard2/system hostname

..... and you should get 'cubieboard2' returned, if not, ssh to the cubieboard 
      and check/restart the daemon (sudo service libvirt-bin start)


To set up the admin machine to ensure another user (instead of root) can run virsh commands:

On the admin machine

1. Add the user to the libvirt group (on older releases of libvirt, this group 
   is sometimes 'libvirtd')

2. Ensure that the clientcert.pem and clientkey.pem in /etc/pki/libvirt belong 
   to the libvirt group, ie:
sudo chgrp libvirt /etc/pki/libvirt/clientcert.pem
sudo chmod 440 /etc/pki/libvirt/clientcert.pem
sudo chgrp libvirt /etc/pki/libvirt/private/clientkey.pem
sudo chmod 440 /etc/pki/libvirt/private/clientkey.pem

3. Edit /etc/libvirt/libvirtd.conf and ensure unix_sock_group, unix_sock_ro_perms, 
   unix_sock_rw_perms are uncommented, allowing users in the libvirt(d) group to use tls, ie

unix_sock_group = "libvirt"
unix_sock_ro_perms = "0777"
unix_sock_rw_perms = "0770"

On the cubieboard

4. ssh into the cubieboard and create a user which matches the 'admin' user ( - 'nick' in my case),
sudo adduser 'username'

5. create a 'libvirt' group if one doesn't already exist
sudo addgroup libvirt

6. add the admin user to the libvirt group
sudo adduser 'username' libvirt

7. reboot


The cubieboard should now be accessible remotely from a non-root account.

Clone the mirage example mirage-skeleton/xen/static_website+ip 

Compile the example (this currently needs to be built on a cubieboard), and then 
edit www.xl. Change the ipaddress, gateway etc. to suit, and then run the 
virsh 'domxml-from-native' translator to get the libvirt xml file

virsh -c xen:/// domxml-from-native xen-xm www.xl > www.xml

virsh -c xen://cubie0/system create www.xml

**/etc/default/libvirt-bin**

```
# Defaults for libvirt-bin initscript (/etc/init.d/libvirt-bin)
# This is a POSIX shell fragment

# Start libvirtd to handle qemu/kvm:
start_libvirtd="yes"

# options passed to libvirtd, add "-l" to listen on tcp
libvirtd_opts="-d -l"

# pass in location of kerberos keytab
#export KRB5_KTNAME=/etc/libvirt/libvirt.keytab
```

**/etc/init.d/libvirt-bin**

```
#! /bin/sh
#
# Init script for libvirtd
#
# (c) 2007 Guido Guenther <agx@sigxcpu.org>
# based on the skeletons that comes with dh_make
#
### BEGIN INIT INFO
# Provides:          libvirt-bin libvirtd
# Required-Start:    $network $local_fs $remote_fs $syslog
# Required-Stop:     $local_fs $remote_fs $syslog
# Should-Start:      hal avahi cgconfig
# Should-Stop:       hal avahi cgconfig
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: libvirt management daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/libvirtd
NAME=libvirtd
DESC="libvirt management daemon"
export PATH

test -x $DAEMON || exit 0
. /lib/lsb/init-functions

PIDFILE=/var/run/$NAME.pid
DODTIME=1                   # Time to wait for the server to die, in seconds

# Include libvirtd defaults if available
if [ -f /etc/default/libvirt-bin ] ; then
	. /etc/default/libvirt-bin
fi

check_start_libvirtd_option() {
  if [ ! "$start_libvirtd" = "yes" ]; then
    log_warning_msg "Not starting libvirt management daemon libvirtd, disabled via /etc/default/libvirt-bin"
    return 1
  else
    return 0
  fi
}

running_pid()
{
    # Check if a given process pid's cmdline matches a given name
    pid=$1
    name=$2
    [ -z "$pid" ] && return 1 
    [ ! -d /proc/$pid ] &&  return 1
    cmd=`cat /proc/$pid/cmdline | tr "\000" "\n"|head -n 1 |cut -d : -f 1`
    # Is this the expected child?
    [ "$cmd" != "$name" ] &&  return 1
    return 0
}

running()
{
# Check if the process is running looking at /proc
# (works for all users)
    # No pidfile, probably no daemon present
    [ ! -f "$PIDFILE" ] && return 1
    # Obtain the pid and check it against the binary name
    pid=`cat $PIDFILE`
    running_pid $pid $DAEMON || return 1
    return 0
}

force_stop() {
# Forcefully kill the process
    [ ! -f "$PIDFILE" ] && return
    if running ; then
        kill -15 $pid
        # Is it really dead?
        [ -n "$DODTIME" ] && sleep "$DODTIME"s
        if running ; then
            kill -9 $pid
            [ -n "$DODTIME" ] && sleep "$DODTIME"s
            if running ; then
                echo "Cannot kill $LABEL (pid=$pid)!"
                exit 1
            fi
        fi
    fi
    rm -f $PIDFILE
    return 0
}

case "$1" in
  start)
	if check_start_libvirtd_option; then
		log_daemon_msg "Starting $DESC" "$NAME"
        	if running ;  then
            		log_progress_msg "already running"
            		log_end_msg 0
            		exit 0
        	fi
		rm -f /var/run/libvirtd.pid
		start-stop-daemon --start --quiet --pidfile $PIDFILE \
			--exec $DAEMON -- $libvirtd_opts
		if running; then
			log_end_msg 0
		else
			log_end_msg 1
		fi
	fi
	;;
  stop)
	log_daemon_msg "Stopping $DESC" "$NAME"
	if ! running ;  then
           	log_progress_msg "not running"
            	log_end_msg 0
            	exit 0
       	fi
	start-stop-daemon --stop --quiet --pidfile $PIDFILE \
		--exec $DAEMON
	log_end_msg 0
	;;
  force-stop)
	log_daemon_msg "Forcefully stopping $DESC" "$NAME"
	force_stop
	if ! running; then
		log_end_msg 0
	else
		log_end_msg 1
	fi
	;;
  restart)
	if check_start_libvirtd_option; then
		log_daemon_msg "Restarting $DESC" "$DAEMON"
		start-stop-daemon --oknodo --stop --quiet --pidfile \
			/var/run/$NAME.pid --exec $DAEMON
		[ -n "$DODTIME" ] && sleep $DODTIME
		start-stop-daemon --start --quiet --pidfile \
			/var/run/$NAME.pid --exec $DAEMON -- $libvirtd_opts
		if running; then
			log_end_msg 0
		else
			log_end_msg 1
		fi
	fi
	;;
  reload|force-reload)
  	if running; then
            log_daemon_msg "Reloading configuration of $DESC" "$NAME"
	    start-stop-daemon --stop --signal 1 --quiet --pidfile \
	             /var/run/$NAME.pid --exec $DAEMON
	    log_end_msg 0
	else
            log_warning_msg "libvirtd not running, doing nothing."
	fi
	;;
  status)
        log_daemon_msg "Checking status of $DESC" "$NAME"
        if running ;  then
            log_progress_msg "running"
            log_end_msg 0
        else
            log_progress_msg "not running"
            log_end_msg 1
            if [ -f "$PIDFILE" ] ; then
                exit 1
            else
                exit 3
            fi
	fi
    ;;
  *)
	N=/etc/init.d/libvirt-bin
	echo "Usage: $N {start|stop|restart|reload|force-reload|status|force-stop}" >&2
	exit 1
	;;
esac

exit 0

```


