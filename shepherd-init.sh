#!/bin/sh

msg() {
    printf "\033[1m=> $@\033[m\n"
}

emergency_shell() {
    echo
    echo "Cannot continue due to errors above, starting emergency shell."
    echo "When ready type exit to continue booting."
    /bin/sh -l
}

msg "Mounting pseudo-filesystems..."
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev

msg "Mounting /run..."
mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /run
mkdir -p /run/shepherd

mount -o remount,rw /
msg "Remounting rootfs read-only..."
mount -o remount,ro / || emergency_shell

[ -f /fastboot ] && FASTBOOT=1
[ -f /forcefsck ] && FORCEFSCK="-f"
for arg in $(cat /proc/cmdline); do
    case $arg in
        fastboot) FASTBOOT=1;;
        forcefsck) FORCEFSCK="-f";;
    esac
done

if [ -z "$FASTBOOT" ]; then
    msg "Checking filesystems..."
    fsck -A -T -a -t noopts=_netdev $FORCEFSCK
    if [ $? -gt 1 ]; then
        emergency_shell
    fi
fi

msg "Mounting rootfs read-write..."
mount -o remount,rw / || emergency_shell

msg "Mounting all non-network filesystems..."
mount -a -O no_netdev || emergency_shell

msg "Starting shepherd..."
exec /sbin/shepherd

# vim: set ft=sh ts=4 sw=4
