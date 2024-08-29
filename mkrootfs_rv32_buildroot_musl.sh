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

cp -R $d/patches/buildroot $root/

make -C $root/buildroot O=$root/musl qemu_riscv32_virt_defconfig
echo "BR2_TOOLCHAIN_BUILDROOT_MUSL=y" >> $root/musl/.config
make -C $root/buildroot O=$root/musl olddefconfig
make -C $root/buildroot O=$root/musl

mkdir $root/musl-root

tar -C $root/musl-root -xf $root/musl/images/rootfs.tar
$d/mkrootfs_tweak.sh $root/musl-root

name="rootfs_rv32_buildroot_musl_$(date +%Y.%m.%d).tar.zst"
rm -rf "$name"
tar -C "$root/musl-root" -c -I 'zstd -T0 --ultra -20' -f "$name" .
