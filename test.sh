#!/bin/sh

FSIZE=30000000
SEEK=3333
WRITESIZE=${WRITESIZE:-1}

echo "FSIZE=$FSIZE SEEK=$SEEK WRITESIZE=$WRITESIZE"

echo "== PRE COPY =="
./diskstats.sh
dd if=/dev/urandom of=/tmp/urnd bs=$FSIZE count=1 2>/dev/null
cp -f /tmp/urnd /tmp/ext4/
cp -f /tmp/urnd /tmp/ext3/
cp -f /tmp/urnd /tmp/xfs/
cp -f /tmp/urnd /tmp/btrfs/
echo "== POST COPY / PRE MUTATION =="
./diskstats.sh
for fs in ext4 ext3 xfs btrfs; do
  dd if=/tmp/urnd bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=$WRITESIZE count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
done
echo "== POST MUTATION =="
./diskstats.sh
