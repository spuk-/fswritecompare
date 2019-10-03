#!/bin/sh

sync -f /tmp/ext4/ /tmp/ext3/ /tmp/xfs/ /tmp/btrfs/
losetup -nal | while read dev q q q q fs resto; do awk "{ printf \"%20.20s %s\\n\",\"$fs\",\$7 }" /sys/class/block/${dev##*/}/stat; done

