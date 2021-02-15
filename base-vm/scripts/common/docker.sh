#!/bin/bash -eux
set -o pipefail

# Install Docker to Debian
sudo apt-get -y install \
   apt-transport-https \
   ca-certificates \
   curl \
   gnupg-agent \
   software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

# Install Debian Docker Repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Install Docker
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Add user to Docker group
sudo usermod -aG docker "$VM_USER"

# Setup daemon.
sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Docker Credential Helper
#DOCKER_CREDENTIAL_HELPER_TAR_URL=$(curl -s -L https://github.com/docker/docker-credential-helpers/releases/latest | grep -e "a href.*pass.*.amd64" | sed -r 's/.*href="([^"]+).*/\1/g')
#DOCKER_CREDENTIAL_HELPER_TAR=$(basename $DOCKER_CREDENTIAL_HELPER_TAR_URL)
#wget https://github.com$DOCKER_CREDENTIAL_HELPER_TAR_URL
#tar xvzf $DOCKER_CREDENTIAL_HELPER_TAR
#sudo mv docker-credential-pass /usr/bin
#chmod +x /usr/bin/docker-credential-pass
#sudo apt install -y gpg pass pinentry-tty gnupg-agent

# For ElasticSearch in ELK stack
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
