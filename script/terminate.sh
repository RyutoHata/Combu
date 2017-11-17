#!/bin/sh
KHOME=/home/kvm/disk/$1
SEED=/mnt/ia01/seed
virsh shutdown $1
virsh undefine $1
rm -rf $KHOME
