#!/bin/bash

BROOT=${BROOT-/mnt/gentoo}
SCRIPTSDIR=$(cd $(dirname $0); cd ../; pwd)
GENTOO_MIRROR=$(bash ${SCRIPTSDIR}/scripts/bootstrap-misc-mirror.sh)

cd /root

# Use swap partition as a temporary storage
swapoff /dev/vda2
fdisk /dev/vda <<EOF
t
2
83
w
EOF
mkfs.ext3 /dev/vda2
mkdir -p ${BROOT}
mount /dev/vda2 ${BROOT}

# Mount and Copy contents included in the latest minimal-install iso image
rm -f /root/install-*.iso
wget $(wget -q -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/current-iso/ | \
	egrep -o "(https?|ftp)://[^\"]+\.iso" | head -n 1)
mkdir -p /mnt/cdrom
mount -o loop /root/install-*.iso /mnt/cdrom
cp -a /mnt/cdrom/* ${BROOT}
cd ${BROOT}
yum -y install squashfs-tools
unsquashfs image.squashfs
mv squashfs-root squashfsroot

mkdir -p initrd
cd initrd
zcat ../isolinux/gentoo.igz | cpio -i
mv ../isolinux/gentoo.igz ../isolinux/gentoo.igz.old
cp ../squashfsroot/lib/modules/3.2.1-gentoo-r2/kernel/drivers/block/virtio_blk.ko lib/modules/3.2.1-gentoo-r2/kernel/drivers/block/
cp -r ../squashfsroot/lib/modules/3.2.1-gentoo-r2/kernel/drivers/virtio lib/modules/3.2.1-gentoo-r2/kernel/drivers/
find . | sort | cpio -H newc -o | gzip > ../isolinux/gentoo.igz
umount /mnt/cdrom
rm -f /root/install-*.iso

# Backup network configuration
mkdir -p ${BROOT}/netconfig
ifconfig eth0 | egrep -o "inet addr:[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/addr.txt
ifconfig eth0 | egrep -o "Bcast:[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/bcast.txt
ifconfig eth0 | egrep -o "Mask:[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/mask.txt
route | egrep -o "default +[0-9.]+" | egrep -o "[0-9.]+" > ${BROOT}/netconfig/gw.txt
#cp -L /etc/resolv.conf ${BROOT}/netconfig/resolv.conf
cat /etc/resolv.conf | egrep -o 'nameserver +[0-9.]+' | egrep -o '[0-9.]+' | \
	perl -pe 's/\n/ /g' > ${BROOT}/netconfig/resolv.txt

cd ${BROOT}
cp -r netconfig ./squashfsroot/root/
cp -r ${SCRIPTSDIR} ./squashfsroot/root/gentoo-sakura-vps

mv image.squashfs image.squashfs.old
mksquashfs squashfsroot image.squashfs

# Grub configuration
sed -i \
	-e "s:^hiddenmenu:Gentoo install\n\troot (hd0,1)\n\tkernel /isolinux/gentoo root=/dev/ram0 init=/linuxrc looptype=squashfs loop=/image.squashfs cdroot=/dev/vda2 initrd=gentoo.igz udev nodevfs console=tty0 console=ttyS0,115200n8r doload=virtio,virtio_ring,virtio_pci,virtio_blk\n\tinitrd /isolinux/gentoo.igz:" \
	/boot/grub/menu.lst

# Copy the scripts
cp -r ${SCRIPTSDIR} ${BROOT}/gentoo-sakura-vps

#if [ $# -gt 0 ] && [ -x $1 ]
#then
#	$1 ${BROOT} $2
#fi

#reboot
