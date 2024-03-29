#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds and packages RV32 OpenSBI

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d -p "$PWD")

trap 'rm -rf "$tmp"' EXIT

git clone https://github.com/riscv/opensbi.git -b v1.4 $tmp

make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- PLATFORM_RISCV_XLEN=32 PLATFORM=generic -j $(nproc)

cd $tmp/build/platform/generic/firmware/
rm -rf $(ls |egrep -v '.bin$|.elf$')
short_sha1=`git rev-parse --short HEAD`
echo "${short_sha1}" > sha1
cd -

name="firmware_rv32_opensbi_${short_sha1}.tar.xz"
rm -rf "$name"
tar -C "$tmp/build/platform/generic/firmware" -c -I 'xz -9 -T0' -f "$name" .
