# fswritecompare - Scripts to compare different filesystems regarding block writes

The scripts are written with little care for security (read them if you so care), they're intended to be run by the root user.

## Usage
1.
        # ./prepare.sh
2.
        # ./test.sh

## Cleanup:
1.
        # umount `mount | awk '/^\/tmp/ { print $1 }'`
2.
        # losetup -D
3.
        # rm -i /tmp/*.img
