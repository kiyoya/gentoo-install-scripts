#!/bin/bash

sed -i \
	-e "s|c2:2345|#c2:2345|" \
	-e "s|c3:2345|#c3:2345|" \
	-e "s|c4:2345|#c4:2345|" \
	-e "s|c5:2345|#c5:2345|" \
	-e "s|c6:2345|#c6:2345|" \
	-e "s|s0:12345:respawn:/sbin/agetty 9600 ttyS0 vt100|s0:2345:respawn:/sbin/agetty -h -L 115200 ttyS0 vt100|" \
	/etc/inittab

echo "root:$1" | chpasswd

exit

cd
umount /mnt/gentoo/boot /mnt/gentoo/dev /mnt/gentoo/proc
swapoff /mnt/gentoo/swap.img
umount /mnt/gentoo

reboot
exit
