#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds an RV64 Ubuntu rootfs.

set -euo pipefail
set -x

d=$(dirname "${BASH_SOURCE[0]}")
distro=noble

packages=(
        arping
        binutils
        elfutils
        ethtool
        fsverity
        iproute2
        iptables
        jq
        keyutils
        libasound2t64
        libcap2
        libelf1
        libnuma1
        net-tools
        netsniff-ng
        openssl
        psmisc
        smcroute
        socat
        strace
        systemd-sysv
        tcpdump
        udev
        uuid-runtime
        zlib1g
)
packages=$(IFS=, && echo "${packages[*]}")

name="rootfs_rv64_ubuntu_$(date +%Y.%m.%d).tar"

mmdebstrap --include="$packages" \
           --architecture=riscv64 \
           --components="main restricted multiverse universe" \
           --customize-hook=$d/systemd-debian-customize-hook.sh \
           --skip=cleanup/reproducible \
           "${distro}" \
           "${name}"

zstd --rm -T0 --ultra -20 $name
