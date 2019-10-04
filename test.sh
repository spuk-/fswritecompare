#!/bin/sh

FSIZE=30000000
SEEK=3333
WRITESIZE=${WRITESIZE:-1}

. "${0%/*}/fslst.sh"
if [ ! "${#FS[@]}" -gt 0 ]; then
    echo "Can't get fslst."
    exit 1
fi

echo "FSIZE=$FSIZE SEEK=$SEEK WRITESIZE=$WRITESIZE"

echo "== PRE COPY =="
./diskstats.sh
dd if=/dev/urandom of=/tmp/urnd bs=$FSIZE count=1 2>/dev/null
for fs in "${FS[@]}"; do
    cp -f /tmp/urnd "/tmp/$fs/"
done
echo "== POST COPY / PRE WRITESIZE MUTATION =="
./diskstats.sh
for fs in "${FS[@]}"; do
  dd if=/tmp/urnd bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=$WRITESIZE count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
done
echo "== POST WRITESIZE MUTATION / PRE 1 SECTOR MUTATION =="
./diskstats.sh
for fs in "${FS[@]}"; do
  dd if=/tmp/urnd bs=512 count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=512 count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
done
echo "== POST 1 SECTOR MUTATION / PRE 4kb MUTATION =="
./diskstats.sh
for fs in "${FS[@]}"; do
  dd if=/tmp/urnd bs=4k count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=4k count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
done
echo "== POST 4kb MUTATION / PRE OVERLAPPING 1 SECTOR + 4kb MUTATION =="
./diskstats.sh
for fs in "${FS[@]}"; do
  dd if=/tmp/urnd bs=512 count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=512 count=1 seek=$SEEK conv=notrunc 2>/dev/null
  dd if=/tmp/urnd bs=4k count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=512 count=4 seek=$SEEK conv=notrunc 2>/dev/null
done
echo "== POST 4kb MUTATION / PRE APPEND =="
./diskstats.sh
for fs in "${FS[@]}"; do
  dd if=/tmp/urnd bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/$fs/urnd" bs=$WRITESIZE count=1 conv=notrunc oflag=sync,append 2>/dev/null
done
echo "== POST APPEND =="
./diskstats.sh
