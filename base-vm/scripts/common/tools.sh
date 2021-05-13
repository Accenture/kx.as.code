#!/bin/bash -eux

# Basic tools for all nodes - main and workers
sudo apt-get -y install \
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
    open-vm-tools

# Install Powerline Status
sudo apt-get install -y python3-setuptools
sudo pip3 install powerline-status

# Install yq
sudo wget https://github.com/mikefarah/yq/releases/download/3.3.2/yq_linux_amd64 -O /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq

# Install Netdata to check system health in case there is an issue with Kubernetes
curl -s https://packagecloud.io/install/repositories/netdata/netdata/script.deb.sh | sudo bash
sudo apt-get install -y netdata
sudo sed -i 's/bind to = localhost/bind to = 0.0.0.0/g' /etc/netdata/netdata.conf
sudo systemctl enable netdata
