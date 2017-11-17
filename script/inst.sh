#!/bin/sh
mkdir /home/kvm/disk/$1
virt-install \
--connect=qemu:///system \
--name=$1 \
--vcpus=1 \
--memory=1024 \
--location='/home/kvm/iso/CentOS-7-x86_64-Minimal-1708.iso' \
--disk path=/home/kvm/disk/$1/disk.qcow2,format=qcow2,size=8 \
--network bridge=br0 \
--os-variant=rhel7 \
--os-type linux \
--console pty,target_type=serial \
--nographics \
-v -x 'console=ttyS0'
