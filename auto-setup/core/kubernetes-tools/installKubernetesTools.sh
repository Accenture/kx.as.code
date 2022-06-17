#!/bin/bash -x
set -euo pipefail

# Ensure time is accurate
/usr/bin/sudo apt-get install -y ntpdate

/usr/bin/sudo mkdir -p ${certificatesWorkspace}
/usr/bin/sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) ${certificatesWorkspace}
cd ${certificatesWorkspace}

# Download and install latest Kubectl and kubeadm binaries
apt-get update && /usr/bin/sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | /usr/bin/sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | /usr/bin/sudo tee -a /etc/apt/sources.list.d/kubernetes.list

# Read Kubernetes version to be installed
kubeVersion=$(cat ${installationWorkspace}/versions.json | jq -r '.kubernetes')
for i in {1..5}
do
  log_info "Installing Kubernetes tools (Attempt ${i} of 5)."
  /usr/bin/sudo apt-get update
  /usr/bin/sudo apt-get install -y kubelet=${kubeVersion} kubeadm=${kubeVersion} kubectl=${kubeVersion}
  /usr/bin/sudo apt-mark hold kubelet kubeadm kubectl
  if [[ -n $(kubectl version) ]]; then
    log_info "Kubectl accessible after install. Looks good. Continuing."
    break
  else
    log_warn "Kubectl not accessible after install. Trying again."
  fi
done

# Install Kubernetes YAML validation tool
downloadFile "https://github.com/instrumenta/kubeval/releases/download/${kubevalVersion}/kubeval-linux-amd64.tar.gz" \
  "${kubevalChecksum}" \
  "${installationWorkspace}/kubeval-linux-amd64.tar.gz"

tar xf ${installationWorkspace}/kubeval-linux-amd64.tar.gz -C ${installationWorkspace}
/usr/bin/sudo cp -f ${installationWorkspace}/kubeval /usr/local/bin

# Install Helm 3
for i in {1..5}
do
    log_info "Installing Helm (Attempt ${i} of 5)."
    curl -fsSL --output ${certificatesWorkspace}/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 ${certificatesWorkspace}/get_helm.sh
    ${certificatesWorkspace}/get_helm.sh
    if [[ -n $(helm version) ]]; then
      log_info "Helm accessible after install. Looks good. Continuing."
      break
    else
      log_warn "Helm not accessible after install. Trying again."
    fi
done

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
