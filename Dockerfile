# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0
FROM ubuntu:mantic
ARG DEBIAN_FRONTEND=noninteractive

# Base packages to retrieve the other repositories/packages
RUN apt-get update 
RUN apt-get install --yes --no-install-recommends \
    build-essential \
    git \
    libdw-dev \
    libelf-dev \
    libglib2.0-dev \
    libguestfs-tools \
    libpython3-dev \
    libslirp-dev \
    ninja-build \
    python-is-python3 \
    python3-docutils \
    python3-git \
    python3-ply \
    python3-ruamel.yaml \
    python3-venv \
    zlib1g-dev

COPY mkqemu.sh /usr/local/bin/mkqemu.sh
RUN cd /tmp && /usr/local/bin/mkqemu.sh

FROM ubuntu:mantic
ARG DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "--login", "-e", "-o", "pipefail", "-c" ]
WORKDIR /tmp

RUN apt-get update && apt-get install --yes --no-install-recommends \
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
    guestfish \
    kmod \
    less \
    libguestfs-tools \
    libpython3-dev \
    libssl-dev \
    linux-image-generic \
    lsb-release \
    ninja-build \
    parallel \
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
    qemu-kvm \
    qemu-utils \
    rsync \
    ruby \
    socat \
    strace \
    swig \
    unzip \
    xz-utils \
    yamllint

COPY setup-kernel-toolchain.sh /usr/local/bin/setup-kernel-toolchain.sh
RUN /usr/local/bin/setup-kernel-toolchain.sh

RUN apt-get update && apt-get install --yes --no-install-recommends \
    acpica-tools \
    apt-transport-https \
    arch-test \
    autoconf \
    automake \
    autotools-dev \
    bash-completion \
    bc \
    binfmt-support \
    bison \
    bsdmainutils \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    cpio \
    curl \
    diffstat \
    file \
    flex \
    g++-riscv64-linux-gnu \
    gawk \
    gcc-riscv64-linux-gnu \
    gdb \
    gettext \
    git \
    git-lfs \
    gnupg \
    gperf \
    groff \
    keyutils \
    kmod \
    less \
    libdw-dev \
    libelf-dev \
    libgmp-dev \
    libmpc-dev \
    libssl-dev \
    liburing-dev \
    libuuid1 \
    lsb-release \
    mmdebstrap \
    ninja-build \
    patchutils \
    perl \
    pkg-config \
    psmisc \
    python-is-python3 \
    python3-docutils \
    python3-venv \
    qemu-system-misc \
    qemu-user-static \
    rsync \
    ruby \
    software-properties-common \
    ssh \
    strace \
    texinfo \
    traceroute \
    unzip \
    uuid-dev \
    vim \
    wget \
    zlib1g-dev

COPY mkfirmware_rv32_opensbi.sh /usr/local/bin/mkfirmware_rv32_opensbi.sh
COPY mkfirmware_rv64_opensbi.sh /usr/local/bin/mkfirmware_rv64_opensbi.sh
COPY mkfirmware_rv64_edk2.sh /usr/local/bin/mkfirmware_rv64_edk2.sh
COPY mkfirmware_rv64_uboot.sh /usr/local/bin/mkfirmware_rv64_uboot.sh
COPY mkrootfs_rv32_buildroot_glibc.sh /usr/local/bin/mkrootfs_rv32_buildroot_glibc.sh
COPY mkrootfs_rv32_buildroot_musl.sh /usr/local/bin/mkrootfs_rv32_buildroot_musl.sh
COPY mkrootfs_rv64_alpine.sh /usr/local/bin/mkrootfs_rv64_alpine.sh
COPY mkrootfs_rv64_ubuntu.sh /usr/local/bin/mkrootfs_rv64_ubuntu.sh
COPY mkrootfs_tweak.sh /usr/local/bin/mkrootfs_tweak.sh
COPY mkqemu.sh /usr/local/bin/mkqemu.sh

RUN mkdir -p /firmware
RUN cd /firmware && /usr/local/bin/mkfirmware_rv32_opensbi.sh
RUN cd /firmware && /usr/local/bin/mkfirmware_rv64_opensbi.sh

RUN apt install --yes --no-install-recommends acpica-tools qemu-system-misc file

RUN cd /firmware && /usr/local/bin/mkfirmware_rv64_edk2.sh
RUN cd /firmware && /usr/local/bin/mkfirmware_rv64_uboot.sh

RUN mkdir -p /rootfs
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv32_buildroot_glibc.sh

COPY patches /usr/local/bin/patches
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv32_buildroot_musl.sh
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv64_alpine.sh
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv64_ubuntu.sh

COPY --from=0 /usr/local /usr/local

RUN apt-get clean && rm -rf /var/lib/apt/lists/
