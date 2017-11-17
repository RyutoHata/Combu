#!/bin/sh
mkdir /home/kvm/disk/$1
cp /mnt/ia01/seed/disk.qcow2 /home/kvm/disk/$1
cp /mnt/ia01/seed/metadata_drive /home/kvm/disk/$1
virt-install --name $1 --memory 512 \
--disk /home/kvm/disk/$1/disk.qcow2,format=qcow2 \
--disk /home/kvm/disk/$1/metadata_drive \
--network bridge=br0 \
--vnc --noautoconsole --import
