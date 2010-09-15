#!/bin/bash

## Installing the Gentoo Installation Files

GENTOO_MIRROR=$(bash $(dirname $0)/bootstrap-misc-mirror.sh)

cd /mnt/gentoo

wget $(wget -q -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/current-stage3/ | \
	egrep -o "(https?|ftp)://[^\"]+/stage3[^.]+\.tar\.bz2" | head -n 1)
tar xvjpf stage3-*.tar.bz2

wget $(wget -q -O - ${GENTOO_MIRROR}/snapshots/ | \
	egrep -o "(https?|ftp)://[^\"]+/portage-latest\.tar\.bz2" | head -n 1)
tar xvjf portage-latest.tar.bz2 -C /mnt/gentoo/usr

cat > /mnt/gentoo/etc/make.conf <<EOM
CHOST="x86_64-pc-linux-gnu"

CFLAGS="-O2 -pipe -march=native -fomit-frame-pointer"
CXXFLAGS="-O2 -pipe -march=native -fomit-frame-pointer"
MAKEOPTS="-j3"

USE="logrotate m17n-lib mmx nls sse sse2 ssse3 thread unicode"
LINGUAS="ja"
EOM

