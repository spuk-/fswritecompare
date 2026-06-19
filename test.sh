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


echo -n "==_FILESYSTEM_=="
ONLYHEADERS=1 ./diskstats.sh
for srcf in uns urnd; do
    SRCF="$srcf"

    echo -n "==_PRE_COPY_($SRCF)_=="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
        cp -f "/tmp/testfswritecompare/$SRCF" "/tmp/testfswritecompare/$fs/"
    done
    echo -n "==_POST_COPY_/_PRE_WRITESIZE_MUTATION_($SRCF)_==_"
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=$WRITESIZE count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
    done
    echo -n "==_POST_WRITESIZE_MUTATION_/_PRE_1_SECTOR_MUTATION_($SRCF)_=="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=512 count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=512 count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
    done
    echo -n "==_POST_1_SECTOR_MUTATION_/_PRE_4kb_MUTATION_($SRCF)_=="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=4k count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=4k count=1 seek=$SEEK conv=notrunc oflag=sync 2>/dev/null
    done
    echo -n "==_POST_4kb_MUTATION_/_PRE_OVERLAPPING_1_SECTOR_+_4kb_MUTATION_($SRCF)_=="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=512 count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=512 count=1 seek=$SEEK conv=notrunc 2>/dev/null
      dd if="/tmp/testfswritecompare/$SRCF" bs=4k count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=512 count=4 seek=$SEEK conv=notrunc 2>/dev/null
    done
    echo -n "==_POST_4kb_MUTATION_/_PRE_APPEND_($SRCF)_=="
    NOHEADERS=1 ./diskstats.sh
    for fs in "${FS[@]}"; do
      dd if="/tmp/testfswritecompare/$SRCF" bs=$WRITESIZE count=1 2>/dev/null | dd of="/tmp/testfswritecompare/$fs/$SRCF" bs=$WRITESIZE count=1 conv=notrunc oflag=sync,append 2>/dev/null
    done
    echo -n "==_POST_APPEND_($SRCF)_=="
    NOHEADERS=1 ./diskstats.sh
done
