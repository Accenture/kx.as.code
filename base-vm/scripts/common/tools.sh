#!/bin/bash -x
set -euo pipefail

# Basic tools for all nodes - main and workers
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
    xfsprogs \
    net-tools \
    dnsutils \
    network-manager \
    python3-pip \
    zsh \
    git \
    jq \
    htop \
    sshpass \
    fontconfig \
    fontconfig-config \
    vim-nox \
    sudo \
    bzip2 \
    acpid \
    cryptsetup \
    zlib1g-dev \
    wget \
    curl \
    dkms \
    fuse \
    make \
    nfs-common \
    cifs-utils \
    rsync \
    open-vm-tools \
    lvm2

# Install Powerline Status
sudo apt-get install -y python3-setuptools
sudo pip3 install powerline-status
