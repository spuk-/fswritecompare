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

# Make random (uncompressible) file
dd if=/dev/urandom of="/tmp/testfswritecompare/urnd" bs=$FSIZE count=1 2>/dev/null
# Make compressible file
dd if=/dev/zero bs=$FSIZE count=1 2>/dev/null | tr '\0' '1' >"/tmp/testfswritecompare/uns"


for srcf in uns urnd; do
    SRCF="$srcf"

    echo "== PRE COPY ($SRCF) =="
    ./diskstats.sh
    for fs in "${FS[@]}"; do
        cp -f "/tmp/testfswritecompare/$SRCF" "/tmp/testfswritecompare/$fs/"
    done
    echo "== POST COPY / PRE WRITESIZE MUTATION ($SRCF) =="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=$WRITESIZE count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
    done
    echo "== POST WRITESIZE MUTATION / PRE 1 SECTOR MUTATION ($SRCF) =="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=512 count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=512 count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
    done
    echo "== POST 1 SECTOR MUTATION / PRE 4kb MUTATION ($SRCF) =="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=4k count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=4k count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
    done
    echo "== POST 4kb MUTATION / PRE OVERLAPPING 1 SECTOR + 4kb MUTATION ($SRCF) =="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=512 count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=512 count=1 seek=$SEEK conv=notrunc 2>/dev/null
      dd if="/tmp/testfswritecompare/$SRCF" bs=4k count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=512 count=4 seek=$SEEK conv=notrunc 2>/dev/null
    done
    echo "== POST 4kb MUTATION / PRE APPEND ($SRCF) =="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=$WRITESIZE count=1 conv=notrunc oflag=sync,append 2>/dev/null
    done
    echo "== POST APPEND ($SRCF) =="
    NOHEADERS=1 ./diskstats.sh
done
