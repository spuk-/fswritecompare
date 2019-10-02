#!/bin/sh

echo "== PRE COPY =="
./diskstats.sh
dd if=/dev/urandom of=/tmp/urnd bs=3000000 count=1 2>/dev/null
cp -f /tmp/urnd /tmp/ext4/
cp -f /tmp/urnd /tmp/ext3/
cp -f /tmp/urnd /tmp/xfs/
cp -f /tmp/urnd /tmp/btrfs/
echo "== POST COPY / PRE SED =="
./diskstats.sh
sed -r -i -e 's/5/9/g' /tmp/ext4/urnd /tmp/ext3/urnd /tmp/xfs/urnd /tmp/btrfs/urnd
echo "== POST SED =="
./diskstats.sh
