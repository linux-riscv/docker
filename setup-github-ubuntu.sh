#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

arch=$(uname -m)
case ${arch} in
  "x86_64")
    debarch="amd64"
    ;;

  "aarch64")
    debarch="arm64"
    ;;
esac

mkdir /opt || true
cd /opt
curl -O https://mirrors.edge.kernel.org/pub/tools/llvm/files/llvm-17.0.2-${arch}.tar.xz
tar xf llvm-17.0.2-${arch}.tar.xz

if [[ $debarch == "amd64" ]]; then
    curl -O https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/13.2.0/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz || exit 1
    tar xf x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz
else
    curl -O https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/arm64/13.2.0/arm64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz || exit 1
    tar xf arm64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz
fi

rm *.xz

export PIPX_HOME=/root/.local/pipx/venvs
export PIPX_BIN_DIR=/root/.local/bin
pipx install tuxmake
pipx install dtschema

apt-get clean && rm -rf /var/lib/apt/lists/

echo 'export PATH=${PATH}:/root/.local/bin' >> /etc/profile
echo "export PATH=/opt/gcc-13.2.0-nolibc/riscv64-linux/bin:/opt/gcc-13.2.0-nolibc/riscv32-linux/bin:/opt/llvm-17.0.2-${arch}/bin:\${PATH}" >> /etc/profile
echo 'export CCACHE_DIR=/ccache' >> /etc/profile
echo 'export CCACHE_MAXSIZE="50G"' >> /etc/profile

git config --global --add safe.directory '*'

