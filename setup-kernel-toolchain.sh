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

# Bump version here
gcc_ver=14.2.0
llvm_ver=19.1.1
###

gcc_base=gcc-${gcc_ver}-nolibc
llvm_dir=llvm-${llvm_ver}-${arch}

mkdir /opt || true
cd /opt

llvm=${llvm_dir}.tar.xz
curl -O https://mirrors.edge.kernel.org/pub/tools/llvm/files/${llvm}
tar xf ${llvm}
gcc=${tcarch}-${gcc_base}-riscv64-linux.tar.xz
curl -O https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/${tcarch}/${gcc_ver}/${gcc}
tar xf ${gcc}
rm *.xz

export PIPX_HOME=/root/.local/pipx/venvs
export PIPX_BIN_DIR=/root/.local/bin
pipx install tuxmake
pipx install dtschema

echo 'export PATH=${PATH}:/root/.local/bin' >> /etc/profile
echo "export PATH=/opt/${gcc_base}/riscv64-linux/bin:/opt/${llvm_dir}/bin:\${PATH}" >> /etc/profile
echo 'export CCACHE_DIR=/build/ccache' >> /etc/profile
echo 'export CCACHE_MAXSIZE="50G"' >> /etc/profile
echo 'export KBUILD_BUILD_TIMESTAMP=@1621270510' >> /etc/profile
echo 'export KBUILD_BUILD_USER=tuxmake' >> /etc/profile
echo 'export KBUILD_BUILD_HOST=tuxmake' >> /etc/profile

git config --global --add safe.directory '*'
