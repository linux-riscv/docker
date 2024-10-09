#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds and packages RV64 U-Boot, to be used as UEFI firmware.

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d -p "$PWD")

trap 'rm -rf "$tmp"' EXIT

git clone https://github.com/u-boot/u-boot.git $tmp -b v2024.10
make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- qemu-riscv64_smode_defconfig acpi.config

cat <<EOF >>$tmp/.config
CONFIG_CMD_KASLRSEED=y
CONFIG_CMD_RNG=y
CONFIG_EFI_RNG_PROTOCOL=y
CONFIG_VIRTIO_RNG=y
CONFIG_EFI_VARIABLE_FILE_STORE=n
CONFIG_EFI_VARIABLE_NO_STORE=n
CONFIG_BOOTCOMMAND="virtio scan; load virtio 0:1 \$kernel_addr_r /Image; setenv bootargs \"root=/dev/vda2 rw earlycon console=tty0 console=ttyS0 panic=-1 oops=panic sysctl.vm.panic_on_oom=1 acpi=force\"; bootefi \${kernel_addr_r} \${fdtcontroladdr}"
CONFIG_BOOTDELAY=0
EOF

make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc)

mv $tmp/u-boot.bin $tmp/rv64-u-boot-acpi.bin

cd $tmp
short_sha1=`git rev-parse --short HEAD`
cd ..

name="firmware_rv64_uboot_acpi_${short_sha1}.tar.zst"
echo "${short_sha1}" > $tmp/sha1
rm -rf "$name"
tar -C "$tmp" -c -I 'zstd -T0 --ultra -20' -f "$name" ./rv64-u-boot-acpi.bin ./sha1
