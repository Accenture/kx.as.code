#!/bin/bash -x
set -euo pipefail

# Add retry config for apt
echo 'APT::Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries

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
    lvm2 \
    netcat \
    psmisc

# Install Powerline Status
sudo apt-get install -y python3-setuptools
sudo pip3 install powerline-status

# Install Netplan for later NIC configuration on first start
sudo apt-get install -y netplan.io