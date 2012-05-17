#!/bin/bash

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

reboot
