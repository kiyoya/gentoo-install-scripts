#!/bin/bash

## Configuring your System

sed -i \
	-e "s:/dev/BOOT:/dev/sda1:" \
	-e "s:/dev/ROOT:/dev/sda2:" \
	-e "s:ext3:ext4:" \
	-e "s:/dev/SWAP:#/dev/sda3:" \
	/etc/fstab

cat >> /etc/conf.d/net <<EOM
config_eth0=( "$(cat /netconfig/addr.txt) netmask $(cat /netconfig/mask.txt) broadcast $(cat /netconfig/bcast.txt)" )
routes_eth0=( "default via $(cat /netconfig/gw.txt)" )
dns_servers_eth0="$(cat /netconfig/resolv.txt)"
EOM

rc-update add net.eth0 default

sed -i \
	-e "s:KEYMAP=\"us\":KEYMAP=\"jp106\":" \
	/etc/conf.d/keymaps

sed -i \
	-e "s:#TIMEZONE=\"Factory\":TIMEZONE=\"Asia/Tokyo\":" \
	/etc/conf.d/clock
