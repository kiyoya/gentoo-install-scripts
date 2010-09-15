#!/bin/bash

BROOT=${BROOT-/mnt/cdrom}

## Configuring your System

sed -i \
	-e "s:/dev/BOOT:/dev/sda1:" \
	-e "s:/dev/ROOT:/dev/sda2:" \
	-e "s:ext3:ext4:" \
	-e "s:/dev/SWAP:#/dev/sda3:" \
	/etc/fstab

ADDR=$(cat ${BROOT}/netconfig/addr.txt)
MASK=$(cat ${BROOT}/netconfig/mask.txt)
BCAST=$(cat ${BROOT}/netconfig/bcast.txt)
GW=$(cat ${BROOT}/netconfig/gw.txt)
RESOLV=$(cat ${BROOT}/netconfig/resolv.txt)

cat >> /etc/conf.d/net <<EOM
config_eth0=( "${ADDR} netmask ${MASK} broadcast ${BCAST}" )
routes_eth0=( "default via ${GW}" )
dns_servers_eth0="${RESOLV}"
EOM

rc-update add net.eth0 default

sed -i \
	-e "s:KEYMAP=\"us\":KEYMAP=\"jp106\":" \
	/etc/conf.d/keymaps

sed -i \
	-e "s:#TIMEZONE=\"Factory\":TIMEZONE=\"Asia/Tokyo\":" \
	/etc/conf.d/clock
