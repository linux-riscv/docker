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

apt-get update && apt-get install --yes --no-install-recommends \
    apt-transport-https \
    bash-completion \
    bc \
    bison \
    bsdextrautils \
    build-essential \
    ca-certificates \
    ccache \
    cpio \
    curl \
    diffstat \
    flex \
    gawk \
    gettext \
    git \
    gnupg \
    groff \
    kmod \
    less \
    libpython3-dev \
    libssl-dev \
    lsb-release \
    ninja-build \
    patchutils \
    perl \
    pipx \
    pkg-config \
    python-is-python3 \
    python3-docutils \
    python3-git \
    python3-ply \
    python3-ruamel.yaml \
    python3-venv \
    rsync \
    ruby \
    socat \
    strace \
    swig \
    unzip \
    xz-utils \
    yamllint

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

git config --global --add safe.directory '*'

