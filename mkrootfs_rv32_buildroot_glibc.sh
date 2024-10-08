#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds an RV32 buildroot rootfs.

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

root=$(mktemp -d -p "$PWD")

trap 'rm -rf "$root"' EXIT

export FORCE_UNSAFE_CONFIGURE=1

git clone git://git.buildroot.net/buildroot $root/buildroot

make -C $root/buildroot O=$root/glibc qemu_riscv32_virt_defconfig
echo "BR2_TOOLCHAIN_BUILDROOT_GLIBC=y" >> $root/glibc/.config
make -C $root/buildroot O=$root/glibc olddefconfig
make -C $root/buildroot O=$root/glibc

mkdir $root/glibc-root

tar -C $root/glibc-root -xf $root/glibc/images/rootfs.tar
$d/mkrootfs_tweak.sh $root/glibc-root

name="rootfs_rv32_buildroot_glibc_$(date +%Y.%m.%d).tar.zst"
rm -rf "$name"
tar -C "$root/glibc-root" -c -I 'zstd -T0 --ultra -20' -f "$name" .
