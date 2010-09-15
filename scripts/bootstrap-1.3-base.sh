#!/bin/bash

## Installing the Gentoo Base System

GENTOO_MIRROR=$(bash $(dirname $0)/bootstrap-misc-mirror.sh)

# mirrorselect -i -r -o >> /mnt/gentoo/etc/make.conf
echo "GENTOO_MIRRORS=\"${GENTOO_MIRROR} \"" >> /mnt/gentoo/etc/make.conf

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc none /mnt/gentoo/proc
mount -o bind /dev /mnt/gentoo/dev
chroot /mnt/gentoo /bin/bash
env-update
source /etc/profile

emerge --sync --quiet

sed -i \
	-e "s/^#en_US ISO-8859-1/en_US ISO-8859-1/" \
	-e "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" \
	-e "s/^#ja_JP.EUC-JP EUC-JP/ja_JP.EUC-JP EUC-JP/" \
	-e "s/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" \
	-e "s/^#ja_JP EUC-JP/ja_JP UTF-8/" \
	/etc/locale.gen

locale-gen
