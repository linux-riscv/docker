# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

FROM ubuntu:mantic

ENV DEBIAN_FRONTEND=noninteractive

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
    kmod \
    less \
    libpython3-dev \
    libssl-dev \
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

RUN apt-get clean && rm -rf /var/lib/apt/lists/
