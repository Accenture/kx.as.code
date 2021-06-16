#!/bin/bash -x
set -euo pipefail

# Ensure time is accurate
sudo apt-get install -y ntpdate

certificatesWorkspace=/usr/share/kx.as.code/Kubernetes
sudo mkdir -p ${certificatesWorkspace}
sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) ${certificatesWorkspace}
cd ${certificatesWorkspace}

# Download and install latest Kubectl and kubeadm binaries
apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Install Helm 3
curl -fsSL --output ${certificatesWorkspace}/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 ${certificatesWorkspace}/get_helm.sh
${certificatesWorkspace}/get_helm.sh

# Correct permissions before next step
sudo chown -hR ${vmUser}:${vmUser} /home/${vmUser}

# Add stable helm repo if it does not already exist
helmRepoExists=$(helm repo list --output json | jq -r '.[] | select(.name=="stable") | .name' || true)
if [[ -z ${helmRepoExists} ]]; then
    helm repo add stable https://charts.helm.sh/stable
fi
helm repo update

# Switch off swap
swapoff -a
sed -i '/swap/d' /etc/fstab
