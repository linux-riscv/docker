# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0
FROM ubuntu:noble
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

FROM ubuntu:noble
ARG DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "--login", "-e", "-o", "pipefail", "-c" ]
WORKDIR /tmp

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
    bsdextrautils \
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
    guestfish \
    keyutils \
    kmod \
    less \
    libdw-dev \
    libelf-dev \
    libgmp-dev \
    libguestfs-tools \
    libmpc-dev \
    libpython3-dev \
    libssl-dev \
    liburing-dev \
    libuuid1 \
    linux-image-generic \
    lsb-release \
    mmdebstrap \
    ninja-build \
    parallel \
    patchutils \
    perl \
    pipx \
    pkg-config \
    psmisc \
    python-is-python3 \
    python3-docutils \
    python3-git \
    python3-ply \
    python3-ruamel.yaml \
    python3-venv \
    qemu-kvm \
    qemu-system-misc \
    qemu-user-static \
    qemu-utils \
    rsync \
    ruby \
    socat \
    software-properties-common \
    ssh \
    strace \
    swig \
    texinfo \
    time \
    traceroute \
    unzip \
    uuid-dev \
    vim \
    wget \
    xz-utils \
    yamllint \
    zlib1g-dev \
    zstd

RUN echo 'deb [arch=amd64] http://apt.llvm.org/noble/ llvm-toolchain-noble main' >> /etc/apt/sources.list.d/llvm.list
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

RUN apt update
RUN apt-get install --yes clang llvm lld

RUN cd $(mktemp -d) && git clone https://git.kernel.org/pub/scm/devel/pahole/pahole.git && \
    cd pahole && mkdir build && cd build && cmake -D__LIB=lib .. && make install

RUN dpkg --add-architecture riscv64
RUN sed -i 's/^deb/deb [arch=amd64]/' /etc/apt/sources.list
RUN echo -e '\n\
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports noble main restricted multiverse universe\n\
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports noble-updates main\n\
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports noble-security main\n'\
>> /etc/apt/sources.list

RUN sed -i -E "s/(URIs.*)/\1\nArchitectures: amd64/" /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update

RUN apt-get install --yes --no-install-recommends \
    libasound2-dev:riscv64 \
    libc6-dev:riscv64 \
    libcap-dev:riscv64 \
    libcap-ng-dev:riscv64 \
    libelf-dev:riscv64 \
    libfuse-dev:riscv64 \
    libhugetlbfs-dev:riscv64 \
    libmnl-dev:riscv64 \
    libnuma-dev:riscv64 \
    libpopt-dev:riscv64 \
    libssl-dev:riscv64 \
    liburing-dev:riscv64

COPY setup-kernel-toolchain.sh /usr/local/bin/setup-kernel-toolchain.sh
RUN /usr/local/bin/setup-kernel-toolchain.sh

COPY patches /usr/local/bin/patches
COPY mkrootfs_tweak.sh /usr/local/bin/mkrootfs_tweak.sh
COPY mkqemu.sh /usr/local/bin/mkqemu.sh
COPY systemd-debian-customize-hook.sh /usr/local/bin/systemd-debian-customize-hook.sh

RUN mkdir -p /firmware
RUN mkdir -p /rootfs

COPY mkrootfs_rv32_buildroot_glibc.sh /usr/local/bin/mkrootfs_rv32_buildroot_glibc.sh
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv32_buildroot_glibc.sh

COPY mkrootfs_rv32_buildroot_musl.sh /usr/local/bin/mkrootfs_rv32_buildroot_musl.sh
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv32_buildroot_musl.sh

COPY mkfirmware_rv64_edk2.sh /usr/local/bin/mkfirmware_rv64_edk2.sh
RUN cd /firmware && /usr/local/bin/mkfirmware_rv64_edk2.sh

COPY mkfirmware_rv32_opensbi.sh /usr/local/bin/mkfirmware_rv32_opensbi.sh
RUN cd /firmware && /usr/local/bin/mkfirmware_rv32_opensbi.sh

COPY mkfirmware_rv64_opensbi.sh /usr/local/bin/mkfirmware_rv64_opensbi.sh
RUN cd /firmware && /usr/local/bin/mkfirmware_rv64_opensbi.sh

COPY mkfirmware_rv64_uboot.sh /usr/local/bin/mkfirmware_rv64_uboot.sh
RUN cd /firmware && /usr/local/bin/mkfirmware_rv64_uboot.sh

COPY mkrootfs_rv64_alpine.sh /usr/local/bin/mkrootfs_rv64_alpine.sh
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv64_alpine.sh

COPY mkrootfs_rv64_ubuntu.sh /usr/local/bin/mkrootfs_rv64_ubuntu.sh
RUN cd /rootfs && /usr/local/bin/mkrootfs_rv64_ubuntu.sh

COPY --from=0 /usr/local /usr/local

RUN apt-get clean && rm -rf /var/lib/apt/lists/
