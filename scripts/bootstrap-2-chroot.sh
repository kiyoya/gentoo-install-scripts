#!/bin/bash

BROOT=${BROOT-/root}
NETCONF=${BROOT}/netconfig
SCRIPTSDIR=$(cd $(dirname $0); cd ../; pwd)

## Installing the Gentoo Base System

env-update
source /etc/profile
export PS1="(chroot) $PS1"

emerge --sync --quiet

sed -i \
	-e "s/^#en_US ISO-8859-1/en_US ISO-8859-1/" \
	-e "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" \
	-e "s/^#ja_JP.EUC-JP EUC-JP/ja_JP.EUC-JP EUC-JP/" \
	-e "s/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" \
	-e "s/^#ja_JP EUC-JP/ja_JP UTF-8/" \
	/etc/locale.gen

locale-gen

## Configuring the Kernel

cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

emerge gentoo-sources --quiet
emerge gentoo-sources -p --quiet | \
	egrep -o "gentoo-sources-[r0-9.-]+" | egrep -o "[0-9][r0-9.-]+" > /kernel-version.txt

cd /usr/src/linux
cp $(find ${SCRIPTSDIR}/scripts/linux-config -type f | sort -nr | head -n 1) .config
make oldconfig
make && make modules_install
cp arch/x86_64/boot/bzImage /boot/kernel-$(cat /kernel-version.txt)
rm -f /kernel-version.txt

## Configuring your System

sed -i \
	-e "s:/dev/BOOT:/dev/vda1:" \
	-e "s:/dev/ROOT:/dev/vda3:" \
	-e "s:ext3:ext4:" \
	-e "s:/dev/SWAP:#/dev/vda2:" \
	/etc/fstab

cat >> /etc/conf.d/net <<EOM
config_eth0="$(cat ${NETCONF}/addr.txt) netmask $(cat ${NETCONF}/mask.txt) broadcast $(cat ${NETCONF}/bcast.txt)"
routes_eth0="default via $(cat ${NETCONF}/gw.txt)"
dns_servers_eth0="$(cat ${NETCONF}/resolv.txt)"
EOM

(cd /etc/init.d && ln -s net.lo net.eth0)
rc-update add net.eth0 default

sed -i \
	-e "s:keymap=\"us\":keymap=\"jp106\":" \
	/etc/conf.d/keymaps

## Installing Necessary System Tools

rc-update add sshd default

emerge syslog-ng --quiet
rc-update add syslog-ng default

emerge vixie-cron --quiet
rc-update add vixie-cron default

emerge ntp --quiet
sed -i \
	-s "s|^NTPCLIENT_OPTS=\"-s -b -u \\|NTPCLIENT_OPTS=\"-b ntp1.sakura.ad.jp\"|" \
	-s "s|\t0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org \\\n||" \
	-s "s|\t2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org\"\n||" \
	/etc/conf.d/ntp-client
sed -i \
	-s "s|^server 0.gentoo.pool.ntp.org\n|server ntp1.sakura.ad.jp|" \
	-s "s|^server 1.gentoo.pool.ntp.org\n||" \
	-s "s|^server 2.gentoo.pool.ntp.org\n||" \
	-s "s|^server 3.gentoo.pool.ntp.org\n||" \
	/etc/ntp.conf
cat >> /etc/ntp.conf <<EOM

logfile	/var/log/ntpd.log
EOM
rc-update add ntp-client default
rc-update add ntpd default

emerge logrotate --quiet

## Configuring the Bootloader

emerge grub --quiet

cat > /boot/grub/menu.lst <<EOM
default 0
timeout 5
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=10 serial console
title=Gentoo
	root (hd0,0)
	kernel /boot/kernel-$(cat /kernel-version.txt) root=/dev/vda3 console=tty0 console=ttyS0,115200n8r
EOM

grep -v rootfs /proc/mounts > /etc/mtab
grub-install --no-floppy /dev/vda

# Post install

sed -i \
	-e "s|^c2:2345|#c2:2345|" \
	-e "s|^c3:2345|#c3:2345|" \
	-e "s|^c4:2345|#c4:2345|" \
	-e "s|^c5:2345|#c5:2345|" \
	-e "s|^c6:2345|#c6:2345|" \
	-e "s|^#s0:12345:respawn:/sbin/agetty 9600 ttyS0 vt100|s0:2345:respawn:/sbin/agetty -h -L 115200 ttyS0 vt100|" \
	/etc/inittab

if [ $# -gt 0 ]
then
	echo "root:$1" | chpasswd
else
	echo "Changing password for root"
	passwd
fi

cat > /etc/init.d/gentoo-sakura-vps-finalize <<EOM
#!/sbin/runscript

depend() {
	need localmount
}

start() {
	rc-update del gentoo-sakura-vps-finalize default
	rm -f /etc/init.d/gentoo-sakura-vps-finalize
	if [[ -d ${BROOT}/gentoo-sakura-vps ]]
	then
		${BROOT}/gentoo-sakura-vps/scripts/bootstrap-3-finalize.sh
	fi
}
EOM
chmod +x /etc/init.d/gentoo-sakura-vps-finalize
rc-update add gentoo-sakura-vps-finalize default

exit
