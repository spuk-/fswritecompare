#!/bin/sh

sync /tmp/ext4/ /tmp/xfs/ /tmp/btrfs/
losetup | while read dev q q q q fs resto; do awk "/${dev##/dev/}/ { printf \"%20.20s %s\\n\",\"$fs\",\$10 }" /proc/diskstats; done

