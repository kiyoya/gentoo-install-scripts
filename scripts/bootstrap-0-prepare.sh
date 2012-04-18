#!/bin/bash

BROOT=${BROOT-/mnt/gentoo}
SCRIPTSDIR=$(cd $(dirname $0); cd ../; pwd)
GENTOO_MIRROR=$(bash ${SCRIPTSDIR}/scripts/bootstrap-misc-mirror.sh)

cd /root

# Use swap partition as a temporary storage
swapoff /dev/vda2
fdisk /dev/vda <<EOF
t
3
83
w
EOF
mkfs.ext3 /dev/vda2
mkdir -p ${BROOT}
mount /dev/vda2 ${BROOT}

# Mount and Copy contents included in the latest minimal-install iso image
rm -f /root/install-*.iso
wget $(wget -q -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/current-iso/ | \
	egrep -o "(https?|ftp)://[^\"]+\.iso" | head -n 1)
mkdir -p /mnt/cdrom
mount -o loop /root/install-*.iso /mnt/cdrom
cp -a /mnt/cdrom/* ${BROOT}
umount /mnt/cdrom
rm -f /root/install-*.iso

# Backup network configuration
mkdir -p ${BROOT}/netconfig
ifconfig eth0 | egrep -o "inet addr:[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/addr.txt
ifconfig eth0 | egrep -o "Bcast:[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/bcast.txt
ifconfig eth0 | egrep -o "Mask:[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/mask.txt
route | egrep -o "default +[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/gw.txt
#cp -L /etc/resolv.conf ${BROOT}/netconfig/resolv.conf
cat /etc/resolv.conf | egrep -o 'nameserver +[0-9.]+' | egrep -o '[0-9.]+' | \
	perl -pe 's/\n/ /g' > ${BROOT}/netconfig/resolv.txt

# Grub configuration
cat > /boot/grub/menu.lst <<EOM
default 0
timeout 3
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=10 serial console
title=Gentoo install
	root (hd0,1)
	kernel /isolinux/gentoo root=/dev/ram0 init=/linuxrc looptype=squashfs loop=/image.squashfs cdroot=/dev/vda2 initrd=gentoo.igz udev nodevfs console=tty0 console=ttyS0,115200n8r doload=virtio,virtio_ring,virtio_pci,virtio_blk
	initrd /isolinux/gentoo.igz
title CentOS (2.6.32-220.7.1.el6.x86_64)
	root (hd0,0)
	kernel /vmlinuz-2.6.32-220.7.1.el6.x86_64 ro root=UUID=77bdc7b0-03e8-4abe-8c85-a3e1c0137309 rd_NO_LUKS rd_NO_MD SYSFONT=latarcyrheb-sun16  KEYBOARDTYPE=pc KEYTABLE=jp106 LANG=C rd_NO_LVM rd_NO_DM nomodeset clocksource=kvm-clock console=tty0 console=ttyS0,115200n8r
	initrd /initramfs-2.6.32-220.7.1.el6.x86_64.img
EOM

# Copy the scripts
cp -r ${SCRIPTSDIR} ${BROOT}/gentoo-sakura-vps

#if [ $# -gt 0 ] && [ -x $1 ]
#then
#	$1 ${BROOT} $2
#fi

#reboot
