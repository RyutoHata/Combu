#!/bin/sh
# $1 : VM Domain Name
# $2 : Number of VCPU
# $3 : Memory Size (MB)
# $4 : IP_address
# $5 : VM Hostname(ex:'hogehoge')
# $6 : SSH-Key
#
KHOME=/home/kvm/disk/$1
SEED=/mnt/ia01/seed
mkdir $KHOME
cp $SEED/disk.qcow2 $KHOME
/usr/bin/truncate -s 10m $KHOME/metadata_drive; sync;
parted $KHOME/metadata_drive < $SEED/parted_procedure.txt
MAPPER=`kpartx -av $KHOME/metadata_drive | cut -d' ' -f3`
udevadm settle
echo $MAPPER
mkfs -t vfat -n METADATA /dev/mapper/$MAPPER
mkdir $KHOME/md_mount
/bin/mount -t vfat /dev/mapper/$MAPPER $KHOME/md_mount
cp $SEED/metadata_master/* $KHOME/md_mount
echo $5 > $KHOME/md_mount/hostname
echo 'IPADDR='\"$4\" >> $KHOME/md_mount/ifcfg-ens3
echo $6 > $KHOME/md_mount/id_rsa.pub
/bin/umount -l $KHOME/md_mount
virt-install --name $1 --vcpus $2 --memory $3 \
--disk $KHOME/disk.qcow2,format=qcow2 \
--disk $KHOME/metadata_drive \
--network bridge=br0 \
--mac=RANDOM \
--vnc --noautoconsole --import
