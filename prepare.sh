#!/bin/sh

umount /tmp/btrfs /tmp/ext4 /tmp/ext3 /tmp/xfs
dd if=/dev/zero of=/tmp/btrfs.img bs=1M count=200
dd if=/dev/zero of=/tmp/ext4.img bs=1M count=200
dd if=/dev/zero of=/tmp/ext3.img bs=1M count=200
dd if=/dev/zero of=/tmp/xfs.img bs=1M count=200
mkfs.btrfs /tmp/btrfs.img
mkfs.ext4 /tmp/ext4.img
mkfs.ext3 /tmp/ext3.img
mkfs.xfs /tmp/xfs.img
mkdir /tmp/btrfs /tmp/ext4 /tmp/ext3 /tmp/xfs
mount -o loop,compress /tmp/btrfs.img /tmp/btrfs
mount -o loop /tmp/ext4.img /tmp/ext4
mount -o loop /tmp/ext3.img /tmp/ext3
mount -o loop /tmp/xfs.img /tmp/xfs
