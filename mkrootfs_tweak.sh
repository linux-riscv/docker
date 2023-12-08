#!/bin/bash
# Copyright 2023 Rivos Inc.
# Copyright (c) 2015 The Libbpf Authors. All rights reserved.
# SPDX-License-Identifier: LGPL-2.1 OR BSD-2-Clause

# Parts from https://github.com/libbpf/ci

# Creates a simple busybox script. Add a /etc/rcS.d/S* scipt to have
# it run.

set -euo pipefail

root=$1

rm -rf \
   "$root"/etc/rcS.d \
   "$root"/usr/share/{doc,info,locale,man,zoneinfo} \
   "$root"/var/cache/apt/archives/* \
   "$root"/var/lib/apt/lists/*

chroot "${root}" /bin/busybox --install

cat > "$root/etc/inittab" << "EOF"
::sysinit:/etc/init.d/rcS
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
::restart:/sbin/init
EOF
chmod 644 "$root/etc/inittab"

mkdir -m 755 -p "$root/etc/init.d" "$root/etc/rcS.d"
cat > "$root/etc/rcS.d/S10-mount" << "EOF"
#!/bin/sh

set -eux

/bin/mount proc /proc -t proc

# Mount devtmpfs if not mounted
if [[ -z "$(/bin/mount -t devtmpfs)" ]]; then
        /bin/mount devtmpfs /dev -t devtmpfs
fi

/bin/mount sysfs /sys -t sysfs
# /bin/mount bpffs /sys/fs/bpf -t bpf
/bin/mount debugfs /sys/kernel/debug -t debugfs

# Symlink /dev/fd to /proc/self/fd so process substitution works.
[[ -e /dev/fd ]] || ln -s /proc/self/fd /dev/fd

echo 'Listing currently mounted file systems'
/bin/mount
EOF
chmod 755 "$root/etc/rcS.d/S10-mount"

cat > "$root/etc/rcS.d/S40-network" << "EOF"
#!/bin/sh

set -eux

ip link set lo up
EOF
chmod 755 "$root/etc/rcS.d/S40-network"

cat >"$root/etc/rcS.d/S99-poweroff" <<"EOF"
#!/bin/sh

rm -f /shutdown-status
echo "clean" > /shutdown-status
chmod 644 /shutdown-status

poweroff
EOF
chmod 755 "$root/etc/rcS.d/S99-poweroff"

cat >"$root/etc/rcS.d/S30-start" <<"EOF"
#!/bin/sh

rm -f /shutdown-status
dmesg | cut -d']' -f2- > /dmesg

EOF
chmod 755 "$root/etc/rcS.d/S30-start"

cat > "$root/etc/init.d/rcS" << "EOF"
#!/bin/sh

set -eux

for path in /etc/rcS.d/S*; do
        [ -x "$path" ] && "$path"
done
EOF
chmod 755 "$root/etc/init.d/rcS"

chmod 755 "$root"
