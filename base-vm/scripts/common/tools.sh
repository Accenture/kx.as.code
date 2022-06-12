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

# Install BTOP
mkdir ${INSTALLATION_WORKSPACE}/btop
cd ${INSTALLATION_WORKSPACE}/btop
wget https://github.com/aristocratos/btop/releases/download/v1.2.7/btop-x86_64-linux-musl.tbz
echo "b3b7cd2a8ef6ebbbadab3ca7689096efa3e4b1e4e11b9a68ed6dedb1e3475fb5 btop-x86_64-linux-musl.tbz" | sha256sum --check
bunzip2 ${INSTALLATION_WORKSPACE}/btop/btop-x86_64-linux-musl.tbz
tar xvf ${INSTALLATION_WORKSPACE}/btop/btop-x86_64-linux-musl.tar
sudo cp -f ${INSTALLATION_WORKSPACE}/btop/bin/btop /usr/local/bin
rm -rf ${INSTALLATION_WORKSPACE}/btop