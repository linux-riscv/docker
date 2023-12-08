#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

arch=$(uname -m)
case ${arch} in
  "x86_64")
    tcarch="x86_64"
    ;;

  "aarch64")
    tcarch="arm64"
    ;;
esac

mkdir /opt || true
cd /opt
curl -O https://mirrors.edge.kernel.org/pub/tools/llvm/files/llvm-17.0.6-${arch}.tar.xz
tar xf llvm-17.0.6-${arch}.tar.xz

curl -O https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/${tcarch}/13.2.0/${tcarch}-gcc-13.2.0-nolibc-riscv64-linux.tar.xz
tar xf ${tcarch}-gcc-13.2.0-nolibc-riscv64-linux.tar.xz

rm *.xz

export PIPX_HOME=/root/.local/pipx/venvs
export PIPX_BIN_DIR=/root/.local/bin
pipx install tuxmake
pipx install dtschema

echo 'export PATH=${PATH}:/root/.local/bin' >> /etc/profile
echo "export PATH=/opt/gcc-13.2.0-nolibc/riscv64-linux/bin:/opt/gcc-13.2.0-nolibc/riscv32-linux/bin:/opt/llvm-17.0.2-${arch}/bin:\${PATH}" >> /etc/profile
echo 'export CCACHE_DIR=/ccache' >> /etc/profile
echo 'export CCACHE_MAXSIZE="50G"' >> /etc/profile

git config --global --add safe.directory '*'
