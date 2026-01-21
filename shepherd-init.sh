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

. /etc/rc.conf

# ===========================
# 02 - Setting up udev
# ===========================

if [ -x /usr/lib/systemd/systemd-udevd ]; then
    _udevd=/usr/lib/systemd/systemd-udevd
elif [ -x /sbin/udevd -o -x /bin/udevd ]; then
    _udevd=udevd
else
    msg_warn "cannot find udevd!"
fi

if [ -n "${_udevd}" ]; then
    msg "Starting udev and waiting for devices to settle..."
    ${_udevd} --daemon
    udevadm trigger --action=add --type=subsystems
    udevadm trigger --action=add --type=devices
    udevadm settle
fi

# ===========================
# 03 - Setting up console
# ===========================

TTYS=${TTYS:-12}
FONT=${FONT:-'lat9w-16'}
if [ -n "$FONT" ]; then
    msg "Setting up TTYs font to '${FONT}'..."

    _index=0
    while [ ${_index} -le $TTYS ]; do
        setfont ${FONT_MAP:+-m $FONT_MAP} ${FONT_UNIMAP:+-u $FONT_UNIMAP} \
                $FONT -C "/dev/tty${_index}"
        _index=$((_index + 1))
    done
fi

KEYMAP=${KEYMAP:-us}
if [ -n "$KEYMAP" ]; then
    msg "Setting up keymap to '${KEYMAP}'..."
    loadkeys -q -u ${KEYMAP}
fi

if [ -n "$HARDWARECLOCK" ]; then
    msg "Setting up RTC to '${HARDWARECLOCK}'..."
    TZ=$TIMEZONE hwclock --systz \
        ${HARDWARECLOCK:+--$(echo $HARDWARECLOCK |tr A-Z a-z) --noadjfile} || emergency_shell
fi

# ===========================
# 03 - Setting up Filesystems
# ===========================

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


# ====================
# 04 - Setting up Swap
# ====================

msg "Initializing swap..."
swapon -a || emergency_shell

# ====================
# 05 - Misc
# ====================

[ -r /etc/hostname ] && read -r HOSTNAME < /etc/hostname
if [ -n "$HOSTNAME" ]; then
    msg "Setting up hostname to '${HOSTNAME}'..."
    printf "%s" "$HOSTNAME" > /proc/sys/kernel/hostname
else
    msg_warn "Didn't setup a hostname!"
fi

if [ -n "$TIMEZONE" ]; then
    msg "Setting up timezone to '${TIMEZONE}'..."
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
fi

# ====================
# 08 - sysctl
# ====================

if [ -x /sbin/sysctl -o -x /bin/sysctl ]; then
    msg "Loading sysctl(8) settings..."
    mkdir -p /run/vsysctl.d
    for i in /run/sysctl.d/*.conf \
        /etc/sysctl.d/*.conf \
        /usr/local/lib/sysctl.d/*.conf \
        /usr/lib/sysctl.d/*.conf; do

        if [ -e "$i" ] && [ ! -e "/run/vsysctl.d/${i##*/}" ]; then
            ln -s "$i" "/run/vsysctl.d/${i##*/}"
        fi
    done
    for i in /run/vsysctl.d/*.conf; do
        sysctl -p "$i"
    done
    rm -rf -- /run/vsysctl.d
    sysctl -p /etc/sysctl.conf
fi

# ====================
# 97 - dmesg
# ====================

dmesg >/var/log/dmesg.log
if [ $(sysctl -n kernel.dmesg_restrict 2>/dev/null) -eq 1 ]; then
    chmod 0600 /var/log/dmesg.log
else
    chmod 0644 /var/log/dmesg.log
fi

# ====================
# 98 - sbin merge
# ====================

if [ -d /usr/sbin -a ! -L /usr/sbin ]; then
    for f in /usr/sbin/*; do
        if [ -f $f -a ! -L $f ]; then
            msg "Detected $f file, can't create /usr/sbin symlink."
            return 0
        fi
    done
    msg "Creating /usr/sbin -> /usr/bin symlink, moving existing to /usr/sbin.old"
    mv /usr/sbin /usr/sbin.old
    ln -sf bin /usr/sbin
fi

# ====================
# 99 - cleanup
# ====================

if [ ! -e /var/log/wtmp ]; then
	install -m0664 -o root -g utmp /dev/null /var/log/wtmp
fi
if [ ! -e /var/log/btmp ]; then
	install -m0600 -o root -g utmp /dev/null /var/log/btmp
fi
if [ ! -e /var/log/lastlog ]; then
	install -m0600 -o root -g utmp /dev/null /var/log/lastlog
fi
install -dm1777 /tmp/.X11-unix /tmp/.ICE-unix
rm -f /etc/nologin /forcefsck /forcequotacheck /fastboot

# ====================
# 99 - Exec shepherd
# ====================

msg "Starting shepherd..."
exec /sbin/shepherd

# vim: set ft=sh ts=4 sw=4 et
