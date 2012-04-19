#!/bin/bash

rm -f /stage3-*.tar.bz2
rm -f /portage-latest.tar.bz2

#rm -f /swap.img
fdisk /dev/vda <<EOM
t
2
82
w
EOM
mkswap /dev/vda2
sed -i \
	-e "s:#/dev/vda2:/dev/vda2:" \
	/etc/fstab

rm -f /kernel-version.txt

reboot

