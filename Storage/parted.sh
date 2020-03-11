#!/bin/bash

set -e

if [ ! -x "/usr/sbin/parted" ]; then
    echo "This script requires /sbin/parted to run!" >&2
    exit 1
fi
DISKS="d e f g h i j k l m n o p"
for i in ${DISKS}; do
  echo "Creating partitions on /dev/sd${i} ..."
  parted -a optimal --script /dev/sd${i} -- mktable gpt"
  parted -a optimal --script /dev/sd${i} -- mkpart primary xfs 0% 100%"
  sleep 1
  echo "Formatting /dev/sd${i}1 ..."
  mkfs.xfs -f /dev/sd${i}1 &
done

SSDS="b c"
for i in ${SSDS}; 
do
  echo "parted -s /dev/sd${i} mktabel gpt"
  echo "parted -s /dev/sd${i} mkpart primary 0% 20%"
  echo "parted -s /dev/sd${i} mkpart primary 21% 40%"
  echo "parted -s /dev/sd${i} mkpart primary 41% 60%"
  echo "parted -s /dev/sd${i} mkpart primary 61% 80%"
  echo "parted -s /dev/sd${i} mkpart primary 81% 100%"
done

chown -R ceph:ceph /dev/sdb[1-7]
chown -R ceph:ceph /dev/sdc[1-7]
