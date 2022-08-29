#!/bin/bash -x
set -euo pipefail

# Install Docker to Debian
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

# Determine CPU architecture
if [[ -n $( uname -a | grep "aarch64") ]]; then
  ARCH="arm64"
else
  ARCH="amd64"
fi

sudo add-apt-repository \
    "deb [arch=${ARCH}] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Install Docker
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Add user to Docker group
sudo usermod -aG docker $VM_USER

# Setup daemon. With experimental features to enable --squash
sudo mkdir -p /etc/docker
sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "experimental": true
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install Docker Compose
mkdir ${INSTALLATION_WORKSPACE}/docker
cd ${INSTALLATION_WORKSPACE}/docker
if [[ -n $( uname -a | grep "aarch64") ]]; then
  # Download URL for ARM64 CPU architecture
  DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-aarch64"
  DOCKER_COMPOSE_CHECKSUM="bcc79aff65b35581246feca30d53261eddcfc79285868061b31f3ff86d102563"
else
  # Download URL for X86_64 CPU architecture
  DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-x86_64"
  DOCKER_COMPOSE_CHECKSUM="184df811a70366fa339e99df38fc6ff24fc9e51b3388335efe51c1941377d4ce"
fi
wget  ${DOCKER_COMPOSE_URL}
DOCKER_COMPOSE_FILE=$(basename ${DOCKER_COMPOSE_URL})
echo "${DOCKER_COMPOSE_CHECKSUM} ${DOCKER_COMPOSE_FILE}" | sha256sum --check
sudo chmod +x ${DOCKER_COMPOSE_FILE}
sudo mv ${DOCKER_COMPOSE_FILE} /usr/local/bin/docker-compose

# For ElasticSearch in ELK stack
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
