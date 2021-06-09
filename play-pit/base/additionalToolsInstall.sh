#!/bin/bash -x
set -euo pipefail

# Install Fluxctl
curl -sL https://fluxcd.io/install | sh
mv /root/.fluxcd/bin/fluxctl /usr/local/bin
rm -rf /root/.fluxcd

# Install ArgoCD CLI tool
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v1.5.1/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Google SDK
curl https://sdk.cloud.google.com > install.sh
bash install.sh --disable-prompts

# Install keepassXC for credential management
apt-get -y install keepassxc

# Install Firefox Browser
apt-get install firefox
