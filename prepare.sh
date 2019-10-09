#!/bin/sh

. "${0%/*}/fslst.sh"
if [ ! "${#FS[@]}" -gt 0 ]; then
    echo "Can't get fslst."
    exit 1
fi

for fs in "${FS[@]}"; do
    umount "/tmp/$fs"
done
for fs in "${FS[@]}"; do
    dd if=/dev/zero of="/tmp/$fs.img" bs=1M count=200
    case "$fs" in
	ntfs) MKFSCMD=("mkfs.$fs" "-QCF"); MOUNTOPTS="compress,big_writes" ;;
    reiserfs) MKFSCMD=("mkfs.$fs" "-f"); MOUNTOPTS="" ;;
	   *) MKFSCMD=("mkfs.$fs"); MOUNTOPTS="" ;;
    esac
    "${MKFSCMD[@]}" "/tmp/$fs.img"
    mkdir -p "/tmp/$fs"
    mount -o "loop,noatime,$MOUNTOPTS" "/tmp/$fs.img" "/tmp/$fs"
done
