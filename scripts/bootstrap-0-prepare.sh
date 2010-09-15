#!/bin/bash

GENTOO_MIRROR=$(bash $(dirname $0)/bootstrap-misc-mirror.sh)

cd /root

# Use swap partition as a temporary storage
swapoff /dev/hda3
fdisk /dev/hda <<EOF
t
3
83
w
EOF
mkfs.ext3 /dev/hda3
mkdir -p /mnt/gentoo
mount /dev/hda3 /mnt/gentoo

# Mount and Copy contents included in the latest minimal-install iso image
wget $(wget -q -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/current-iso/ | egrep -o "(https?|ftp)://[^\"]+\.iso" | head -n 1)
mkdir -p /mnt/cdrom
mount -o loop /root/install-*.iso /mnt/cdrom
cp -a /mnt/cdrom/* /mnt/gentoo
umount /mnt/cdrom
rm -f /root/install-*.iso

# Backup network configuration
mkdir -p /mnt/gentoo/netconfig
ifconfig eth0 | egrep -o "inet addr:[0-9.]+" | egrep -o "[0-9.]+" > /mnt/gentoo/netconfig/addr.txt
ifconfig eth0 | egrep -o "Bcast:[0-9.]+" | egrep -o "[0-9.]+" > /mnt/gentoo/netconfig/bcast.txt
ifconfig eth0 | egrep -o "Mask:[0-9.]+" | egrep -o "[0-9.]+" > /mnt/gentoo/netconfig/mask.txt
route | egrep -o "default +[0-9.]+" | egrep -o "[0-9.]+" > /mnt/gentoo/netconfig/gw.txt
#cp -L /etc/resolv.conf /mnt/gentoo/netconfig/resolv.conf
cat /etc/resolv.conf | egrep -o 'nameserver +[0-9.]+' | egrep -o '[0-9.]+' | perl -pe 's/\n/ /g' > /mnt/gentoo/netconfig/resolv.txt

# Grub configuration
cat > /boot/grub/menu.lst <<EOM
default 0
timeout 3
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=10 serial console
title=Gentoo install
	root (hd0,2)
	kernel /isolinux/gentoo root=/dev/ram0 init=/linuxrc looptype=squashfs loop=/image.squashfs cdroot initrd=gentoo.igz udev console=tty0 console=ttyS0,115200n8r
	initrd /isolinux/gentoo.igz
EOM

reboot
