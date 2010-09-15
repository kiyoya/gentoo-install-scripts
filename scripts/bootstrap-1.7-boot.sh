#!/bin/bash

## Configuring the Bootloader

emerge grub --quiet

cat > /boot/grub/menu.lst <<EOM
default 0
timeout 5
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=10 serial console
title=Gentoo
	root (hd0,0)
	kernel /boot/kernel-$(cat /kernel-version.txt) root=/dev/sda2 console=tty0 console=ttyS0,115200n8r
EOM

grep -v rootfs /proc/mounts > /etc/mtab
grub-install --no-floppy /dev/hda
