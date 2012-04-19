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
mkswap /dev/sda3
sed -i \
	-e "s:#/dev/vda3:/dev/vda3:" \
	/etc/fstab

rm -f /kernel-version.txt

reboot

