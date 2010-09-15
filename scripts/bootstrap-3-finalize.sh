#!/bin/bash

rm -f /stage3-*.tar.bz2
rm -f /portage-latest.tar.bz2

rm -f /swap.img
fdisk /dev/hda <<EOM
t
3
82
w
EOM
mkswap /dev/hda3
sed -i \
	-e "s:#/dev/sda3:/dev/sda3:" \
	/etc/fstab

rm -rf /netconfig

rm -f /kernel-version.txt

#reboot
