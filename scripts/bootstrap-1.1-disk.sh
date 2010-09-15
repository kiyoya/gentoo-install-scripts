#!/bin/bash

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
