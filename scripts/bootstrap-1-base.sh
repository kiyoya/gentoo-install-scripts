#!/bin/bash

BROOT=${BROOT-/mnt/cdrom}
SCRIPTSDIR=$(cd $(dirname $0); pwd)
GENTOO_MIRROR=$(bash ${SCRIPTSDIR}/bootstrap-misc-mirror.sh)

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

mkfs.ext4 /dev/hda2
mount /dev/hda2 /mnt/gentoo
mkdir -p /mnt/gentoo/boot
mke2fs /dev/hda1
mount /dev/hda1 /mnt/gentoo/boot

## Preparing the swap file
cd /mnt/gentoo
dd if=/dev/zero of=swap.img bs=1024K count=128
mkswap swap.img
swapon swap.img

## Installing the Gentoo Installation Files

cd /mnt/gentoo

wget $(wget -q -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/current-stage3/ | \
	egrep -o "(https?|ftp)://[^\"]+/stage3[^.]+\.tar\.bz2" | head -n 1)
tar xvjpf stage3-*.tar.bz2

wget $(wget -q -O - ${GENTOO_MIRROR}/snapshots/ | \
	egrep -o "(https?|ftp)://[^\"]+/portage-latest\.tar\.bz2" | head -n 1)
tar xvjf portage-latest.tar.bz2 -C /mnt/gentoo/usr

cat > /mnt/gentoo/etc/make.conf <<EOM
CHOST="x86_64-pc-linux-gnu"

CFLAGS="-O2 -pipe -march=native -fomit-frame-pointer"
CXXFLAGS="-O2 -pipe -march=native -fomit-frame-pointer"
MAKEOPTS="-j3"

USE="logrotate m17n-lib mmx nls sse sse2 ssse3 thread unicode"
LINGUAS="ja"
EOM

## Installing the Gentoo Base System

# mirrorselect -i -r -o >> /mnt/gentoo/etc/make.conf
echo "GENTOO_MIRRORS=\"${GENTOO_MIRROR} \"" >> /mnt/gentoo/etc/make.conf

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc none /mnt/gentoo/proc
mount -o bind /dev /mnt/gentoo/dev
mount -o bind /mnt/cdrom /mnt/gentoo/mnt/cdrom
chroot /mnt/gentoo /bin/bash

cd
umount /mnt/gentoo/boot /mnt/gentoo/dev /mnt/gentoo/proc /mnt/gentoo/mnt/cdrom
swapoff /mnt/gentoo/swap.img
umount /mnt/gentoo

#reboot
