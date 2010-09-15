#!/bin/bash

## Configuring your network

ifconfig eth0 \$(cat /netconfig/addr.txt) netmask \$(cat /netconfig/mask.txt) broadcast \$(cat /netconfig/bcast.txt) up
route add default gw \$(cat /netconfig/gw.txt)
for ip in /netconfig/resolv.txt
do
	echo "nameserver ${ip}" >> /etc/resolv.conf
done
