#!/bin/bash

parted -s /dev/vda mkfs 2 linux-swap
mkswap /dev/vda2
sed -i \
	-e "s:#/dev/vda2:/dev/vda2:" \
	/etc/fstab
