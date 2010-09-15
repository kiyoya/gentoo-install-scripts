#!/bin/bash

BROOT=${BROOT-/mnt/cdrom}

## Configuring your network

ifconfig eth0 $(cat ${BROOT}/netconfig/addr.txt) \
	netmask $(cat ${BROOT}/netconfig/mask.txt) \
	broadcast $(cat ${BROOT}/netconfig/bcast.txt) up

route add default gw $(cat ${BROOT}/netconfig/gw.txt)

for ip in ${BROOT}/netconfig/resolv.txt
do
	echo "nameserver ${ip}" >> /etc/resolv.conf
done
