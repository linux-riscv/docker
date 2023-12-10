#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds an RV64 Ubuntu rootfs.

set -euo pipefail

set -x

d=$(dirname "${BASH_SOURCE[0]}")
distro=mantic

trap 'rm -rf "$setup"' EXIT

packages=(
	systemd-sysv
	udev
        binutils
        elfutils
        ethtool
        iproute2
        iptables
        keyutils
        libcap2
        libelf1
        openssl
        strace
        zlib1g
)
packages=$(IFS=, && echo "${packages[*]}")

name="rootfs_rv64_ubuntu_$(date +%Y.%m.%d).tar"

setup=$(mktemp)

cat >"$setup" <<"EOF"
set -x
rm -f /shutdown-status
dmesg -t > /dmesg

rm -f /shutdown-status
echo "clean" > /shutdown-status
chmod 644 /shutdown-status

poweroff
EOF
chmod +x $setup

mmdebstrap --include="$packages" \
           --variant=minbase \
           --architecture=riscv64 \
	   --customize-hook='echo rivos > "$1/etc/hostname"' \
	   --customize-hook='echo 44f789c720e545ab8fb376b1526ba6ca > "$1/etc/machine-id"' \
	   --customize-hook='mkdir -p "$1/etc/systemd/system/serial-getty@ttyS0.service.d"' \
	   --customize-hook='printf "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o \"-p -f -- \\\\\\\\u\" --keep-baud --autologin root 115200,57600,38400,9600 - \$TERM\n" > "$1/etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf"' \
	   --customize-hook="upload $setup /setup" \
	   --customize-hook='cat $1/setup >> "$1/root/.profile"' \
	   --customize-hook='rm $1/setup' \
	   --skip=cleanup/reproducible \
           "${distro}" \
           "$name"

xz -9 -T0 $name
