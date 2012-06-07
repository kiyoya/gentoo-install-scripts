#!/bin/bash

BROOT=${BROOT-/mnt/livecd/root}
SCRIPTSDIR=$(cd $(dirname $0); cd ../; pwd)
GENTOO_MIRROR=$(bash ${SCRIPTSDIR}/scripts/bootstrap-misc-mirror.sh)

## Configuring your network

ifconfig eth0 $(cat ${BROOT}/netconfig/addr.txt) \
	netmask $(cat ${BROOT}/netconfig/mask.txt) \
	broadcast $(cat ${BROOT}/netconfig/bcast.txt) up

route add default gw $(cat ${BROOT}/netconfig/gw.txt)

for ip in $(cat ${BROOT}/netconfig/resolv.txt)
do
	echo "nameserver ${ip}" >> /etc/resolv.conf
done

## Preparing the Disks

mkfs.ext4 /dev/vda3
mount /dev/vda3 /mnt/gentoo
mkdir -p /mnt/gentoo/boot
mke2fs /dev/vda1
mount /dev/vda1 /mnt/gentoo/boot

## Installing the Gentoo Installation Files

cd /mnt/gentoo

wget $(wget -q -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/current-stage3/ | \
	egrep -o "(https?|ftp)://[^\"]+/stage3[^.]+\.tar\.bz2" | head -n 1)
tar xvjpf stage3-*.tar.bz2
rm -f stage3-*.tar.bz2

wget $(wget -q -O - ${GENTOO_MIRROR}/snapshots/ | \
	egrep -o "(https?|ftp)://[^\"]+/portage-latest\.tar\.bz2" | head -n 1)
tar xvjf portage-latest.tar.bz2 -C /mnt/gentoo/usr
rm -f portage-latest.tar.bz2

mkdir -p /mnt/gentoo/etc/portage
cp ${SCRIPTSDIR}/make.conf /mnt/gentoo/etc/portage/make.conf

## Installing the Gentoo Base System

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc none /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev

## Copy the scripts
cp -r ${SCRIPTSDIR} /mnt/gentoo/root/gentoo-sakura-vps/
cp -r ${BROOT}/netconfig /mnt/gentoo/root/

chroot /mnt/gentoo ${SCRIPTSDIR}/scripts/bootstrap-2-chroot.sh

cd
umount -l /mnt/gentoo/boot /mnt/gentoo/dev /mnt/gentoo/proc
umount -l /mnt/gentoo

#reboot
