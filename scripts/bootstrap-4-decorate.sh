#!/bin/bash

emerge --update --deep --newuse --with-bdeps=y world

emerge sudo
sed -i \
	-e 's|^# \(%wheel ALL=(ALL) ALL\)|\1|' \
	/etc/sudoers

emerge iptables
rc-update add iptables default
iptables -F
iptables -X
iptables -Z
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
/etc/init.d/iptables save
/etc/init.d/iptables start

sed -i \
	-e "s|^#ChallengeResponseAuthentication yes|ChallengeResponseAuthentication no|" \
	/etc/ssh/sshd_config
/etc/init.d/sshd restart
