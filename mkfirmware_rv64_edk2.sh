#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds and packages RV64 U-Boot, to be used as UEFI firmware.

# Do not set -u because edk2 building scripts fail.
set -x
set -eo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d -p "$PWD")

trap 'rm -rf "$tmp"' EXIT

cd $tmp

# Instructions from
# https://github.com/vlsunil/riscv-uefi-edk2-docs/wiki/RISC-V-Qemu-Virt-support
git clone --recurse-submodule https://github.com/tianocore/edk2.git -b edk2-stable202302

export WORKSPACE=`pwd`
export GCC5_RISCV64_PREFIX=/usr/bin/riscv64-linux-gnu-
export PACKAGES_PATH=$WORKSPACE/edk2
export EDK_TOOLS_PATH=$WORKSPACE/edk2/BaseTools
source edk2/edksetup.sh
make -C edk2/BaseTools clean
make -C edk2/BaseTools
make -C edk2/BaseTools/Source/C
source edk2/edksetup.sh BaseTools
build -a RISCV64 --buildtarget RELEASE -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t GCC5

truncate -s 32M Build/RiscVVirtQemu/RELEASE_GCC5/FV/RISCV_VIRT.fd

cd edk2
short_sha1=`git rev-parse --short HEAD`
cd ..

name="firmware_rv64_edk2_${short_sha1}.tar.xz"
echo "${short_sha1}" > Build/RiscVVirtQemu/RELEASE_GCC5/FV/sha1
rm -rf "$name"
tar -C "$tmp/Build/RiscVVirtQemu/RELEASE_GCC5/FV/" -c -I 'xz -9 -T0' -f "../$name" ./RISCV_VIRT.fd ./sha1
