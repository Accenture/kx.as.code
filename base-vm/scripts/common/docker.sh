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
  DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-aarch64"
  DOCKER_COMPOSE_CHECKSUM="9d6a6396b7604a390977ffff78379090f7c6910160bbd3b9669e2fcc635633c5"
else
  # Download URL for X86_64 CPU architecture
  DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64"
  DOCKER_COMPOSE_CHECKSUM="f45e4cb687df8b48a57f656097ce7175fa8e8bef70be407b011e29ff663f475f"
fi
wget  ${DOCKER_COMPOSE_URL}
DOCKER_COMPOSE_FILE=$(basename ${DOCKER_COMPOSE_URL})
echo "${DOCKER_COMPOSE_CHECKSUM} ${DOCKER_COMPOSE_FILE}" | sha256sum --check
sudo chmod +x ${DOCKER_COMPOSE_FILE}
sudo mv ${DOCKER_COMPOSE_FILE} /usr/local/bin/docker-compose

# For ElasticSearch in ELK stack
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
