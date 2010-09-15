#!/bin/bash

## Installing the Gentoo Base System

GENTOO_MIRROR=$(bash $(dirname $0)/bootstrap-misc-mirror.sh)

# mirrorselect -i -r -o >> /mnt/gentoo/etc/make.conf
echo "GENTOO_MIRRORS=\"${GENTOO_MIRROR} \"" >> /mnt/gentoo/etc/make.conf

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc none /mnt/gentoo/proc
mount -o bind /dev /mnt/gentoo/dev
chroot /mnt/gentoo /bin/bash

cd
umount /mnt/gentoo/boot /mnt/gentoo/dev /mnt/gentoo/proc
swapoff /mnt/gentoo/swap.img
umount /mnt/gentoo

reboot
exit
