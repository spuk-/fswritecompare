#!/bin/sh

. "${0%/*}/fslst.sh"
if [ ! "${#FS[@]}" -gt 0 ]; then
    echo "Can't get fslst."
    exit 1
fi

for fs in "${FS[@]}"; do
    sync -f "/tmp/$fs"
done
if [ -z "$NOHEADERS" ]; then
    # Show header
    losetup -nal | sort | while read dev q q q q fs q; do
      printf "%10.10s   " ${fs##*/}
    done
    echo
fi
# Show numbers
losetup -nal | sort | while read dev q q q q fs q; do
  read q q q q q q wrsects q </sys/class/block/${dev##*/}/stat
  printf "%10.10s   " $wrsects
done
echo
