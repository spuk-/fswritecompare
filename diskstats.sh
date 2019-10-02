#!/bin/sh

sync -f /tmp/ext4/ /tmp/ext3/ /tmp/xfs/ /tmp/btrfs/
losetup | while read dev q q q q fs resto; do awk "/${dev##/dev/}/ { printf \"%20.20s %s\\n\",\"$fs\",\$10 }" /proc/diskstats; done

