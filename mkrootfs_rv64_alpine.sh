#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds an RV64 Alpine rootfs.

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

root=$(mktemp -d -p "$PWD")
mkdir -p $root/alpine

trap 'rm -rf "$root"' EXIT

arch=$(uname -m)

cd $root
curl -O http://dl-cdn.alpinelinux.org/alpine/edge/main/${arch}/apk-tools-static-2.14.4-r4.apk
tar xvf *.apk

./sbin/apk.static --arch riscv64 \
             -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ \
             -U --allow-untrusted \
             --root "./alpine" \
             --initdb add alpine-base
cd ..

$d/mkrootfs_tweak.sh "$root"/alpine

name="rootfs_rv64_alpine_$(date +%Y.%m.%d).tar.zst"
rm -rf "$name"

tar -C "$root/alpine" -c -I 'zstd -T0 --ultra -20' -f "$name" .
