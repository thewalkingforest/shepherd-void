#!/bin/sh

msg() {
    printf "\033[1m=> $@\033[m\n"
}

msg_warn() {
    # bold/yellow
    printf "\033[1m\033[33mWARNING: $@\033[m\n"
}

emergency_shell() {
    echo
    echo "Cannot continue due to errors above, starting emergency shell."
    echo "When ready type exit to continue booting."
    /bin/sh -l
}

[ -x /etc/rc.shutdown ] && /etc/rc.shutdown

# ================
# 30 - seedrng
# ================
if [ -z "$IS_CONTAINER" ]; then
    # if not in a container
    msg "Saving random number generator seed..."
    seedrng
fi

# ================
# 40 - hwclock
# ================
if [ -z "$IS_CONTAINER" ] && [ -n "$HARDWARECLOCK" ]; then
    # if not in a container and HARDWARECLOCK is set
    hwclock --systohc ${HARDWARECLOCK:+--$(echo $HARDWARECLOCK |tr A-Z a-z)}
fi

# ================
# 40 - wtmp
# ================
halt -w

# ================
# 60 - udev
# ================
if [ -z "$IS_CONTAINER" ]; then
    msg "Stopping udev..."
    udevadm control --exit
fi

# ================
# 70 - pkill
# ================
msg "Sending TERM signal to processes..."
pkill --inverse -s0,1 -TERM
sleep 1
msg "Sending KILL signal to processes..."
pkill --inverse -s0,1 -KILL

# ================
# 80 - filesystems
# ================
if [ -z "$IS_CONTAINER" ]; then
    msg "Unmounting filesystems, disabling swap..."
    swapoff -a
    umount -r -a -t nosysfs,noproc,nodevtmpfs,notmpfs
    msg "Remounting rootfs read-only..."
    LIBMOUNT_FORCE_MOUNT2=always mount -o remount,ro /
fi

sync

# ================
# 90 - kexec
# ================
if [ -z "$IS_CONTAINER" ]; then
    # test -x returns false on a noexec mount, hence using find to detect x bit
    if [ -n "$(find /run/runit/reboot -perm -u+x 2>/dev/null)" ] &&
        command -v kexec >/dev/null
    then
        msg "Triggering kexec..."
        kexec -e 2>/dev/null
        # not reached when kexec was successful.
    fi
fi
