#!/bin/sh

. "${0%/*}/fslst.sh"
if [ ! "${#FS[@]}" -gt 0 ]; then
    echo "Can't get fslst."
    exit 1
fi

mkdir /tmp/testfswritecompare

for fs in "${FS[@]}"; do
    umount "/tmp/testfswritecompare/$fs"
done
for fs in "${FS[@]}"; do
    dd if=/dev/zero of="/tmp/testfswritecompare/$fs.img" bs=1M count=200
    case "$fs" in
	ntfs) MKFSCMD=("mkfs.$fs" "-QCF"); MOUNTOPTS="compress,big_writes" ;;
    reiserfs) MKFSCMD=("mkfs.$fs" "-f"); MOUNTOPTS="" ;;
	   *) MKFSCMD=("mkfs.$fs"); MOUNTOPTS="" ;;
    esac
    "${MKFSCMD[@]}" "/tmp/testfswritecompare/$fs.img"
    mkdir -p "/tmp/testfswritecompare/$fs"
    mount -o "loop,noatime,$MOUNTOPTS" "/tmp/testfswritecompare/$fs.img" "/tmp/testfswritecompare/$fs"
done
