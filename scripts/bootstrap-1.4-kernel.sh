#!/bin/bash

## Configuring the Kernel

cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

emerge gentoo-sources --quiet
emerge gentoo-sources -p --quiet | egrep -o "gentoo-sources-[r0-9.-]+" | egrep -o "[0-9][r0-9.-]+" > /boot/kernel-version.txt

cd /usr/src/linux
cp $(find $(dirname $0)/linux-config -type f | sort -nr | head -n 1) .config
make oldconfig
cp arch/x86_64/boot/bzImage /boot/kernel-\$(cat /boot/kernel-version.txt)
