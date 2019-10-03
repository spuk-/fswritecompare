#!/bin/sh

sync -f /tmp/ext4/ /tmp/ext3/ /tmp/xfs/ /tmp/btrfs/
# Show header
losetup -nal | while read dev q q q q fs q; do
  printf "%20.20s   " $fs
done
echo
# Show numbers
losetup -nal | while read dev q q q q fs q; do
  read q q q q q q wrsects q </sys/class/block/${dev##*/}/stat
  printf "%20.20s   " $wrsects
done
echo
