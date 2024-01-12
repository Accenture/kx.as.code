#!/bin/bash -x
set -euo pipefail

# Enable SSH
sudo systemctl enable ssh

# Add retry config for apt
echo 'APT::Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries

# Basic tools for all nodes - main and workers
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
    software-properties-common \
    xfsprogs \
    net-tools \
    dnsutils \
    network-manager \
    python3-pip \
    zsh \
    git \
    jq \
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
    lvm2 \
    netcat-openbsd \
    psmisc \
    grc

# Install open-vm-tools if target is not a baremetal Raspberry Pi
if [[ -z $( uname -a | grep "aarch64") ]] && [[ -z $(which raspinfo) ]]; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y install open-vm-tools
fi

# Install Powerline Status
# TODO - Restore pipx when upgrading to Debian 12
sudo apt-get install -y python3-setuptools pipx
sudo pipx ensurepath
sudo pipx install powerline-status
#sudo pip3 install powerline-status

# Install Netplan for later NIC configuration on first start
sudo apt-get install -y netplan.io

# Install BTOP
mkdir ${INSTALLATION_WORKSPACE}/btop
cd ${INSTALLATION_WORKSPACE}/btop
if [[ -n $( uname -a | grep "aarch64") ]]; then
  # Download URL for ARM64 CPU architecture
  BTOP_URL="https://github.com/aristocratos/btop/releases/download/v1.2.8/btop-aarch64-linux-musl.tbz"
  BTOP_CHECKSUM="5c8642bd9d8e38eee38980b5c39b8ee9c830f99470622cd137800899a905dd3f"
else
  # Download URL for X86_64 CPU architecture
  BTOP_URL="https://github.com/aristocratos/btop/releases/download/v1.2.8/btop-x86_64-linux-musl.tbz"
  BTOP_CHECKSUM="fd860e6d30e01fd6f30e161017cefceec799c5a617f9a5debc0947754b4d251c"
fi

wget ${BTOP_URL}
BTOP_FILE=$(basename ${BTOP_URL})
echo "${BTOP_CHECKSUM} ${BTOP_FILE}" | sha256sum --check

bunzip2 ${INSTALLATION_WORKSPACE}/btop/${BTOP_FILE}
BTOP_TAR=$(echo "${BTOP_FILE%.*}.tar")
tar xvf ${INSTALLATION_WORKSPACE}/btop/${BTOP_TAR}
sudo cp -f ${INSTALLATION_WORKSPACE}/btop/bin/btop /usr/local/bin
rm -rf ${INSTALLATION_WORKSPACE}/btop

# Set kernel parameters
/usr/bin/sudo sysctl -w fs.inotify.max_user_watches=524288
echo "fs.inotify.max_user_watches=524288" | /usr/bin/sudo tee -a /etc/sysctl.conf
/usr/bin/sudo sysctl -w fs.inotify.max_user_instances=8192
echo "fs.inotify.max_user_instances=8192" | /usr/bin/sudo tee -a /etc/sysctl.conf
