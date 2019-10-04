#!/bin/sh

. "${0%/*}/fslst.sh"
if [ ! "${#FS[@]}" -gt 0 ]; then
    echo "Can't get fslst."
    exit 1
fi

for fs in "${FS[@]}"; do
    sync -f "/tmp/$fs"
done
# Show header
losetup -nal | sort | while read dev q q q q fs q; do
  printf "%20.20s   " $fs
done
echo
# Show numbers
losetup -nal | sort | while read dev q q q q fs q; do
  read q q q q q q wrsects q </sys/class/block/${dev##*/}/stat
  printf "%20.20s   " $wrsects
done
echo
