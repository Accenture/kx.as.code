#!/bin/bash -x
set -euo pipefail

# Ensure time is accurate
/usr/bin/sudo apt-get install -y ntpdate

certificatesWorkspace=/usr/share/kx.as.code/Kubernetes
/usr/bin/sudo mkdir -p ${certificatesWorkspace}
/usr/bin/sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) ${certificatesWorkspace}
cd ${certificatesWorkspace}

# Download and install latest Kubectl and kubeadm binaries
apt-get update && /usr/bin/sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | /usr/bin/sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | /usr/bin/sudo tee -a /etc/apt/sources.list.d/kubernetes.list
# Read Kubernetes version to be installed
kubeVersion=$(cat ${installationWorkspace}/versions.json | jq -r '.kubernetes')
/usr/bin/sudo apt-get update
/usr/bin/sudo apt-get install -y kubelet=${kubeVersion} kubeadm=${kubeVersion} kubectl=${kubeVersion}
/usr/bin/sudo apt-mark hold kubelet kubeadm kubectl

# Install Helm 3
curl -fsSL --output ${certificatesWorkspace}/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 ${certificatesWorkspace}/get_helm.sh
${certificatesWorkspace}/get_helm.sh

# Correct permissions before next step
/usr/bin/sudo chown -hR ${vmUser}:${vmUser} /home/${vmUser}

# Add stable helm repo if it does not already exist
helmRepoExists=$(helm repo list --output json | jq -r '.[] | select(.name=="stable") | .name' || true)
if [[ -z ${helmRepoExists} ]]; then
    helm repo add stable https://charts.helm.sh/stable
fi
helm repo update

# Switch off swap
swapoff -a
sed -i '/swap/d' /etc/fstab
