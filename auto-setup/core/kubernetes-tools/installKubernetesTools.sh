#!/bin/bash
set -euo pipefail

# Ensure time is accurate
/usr/bin/sudo apt-get install -y ntpdate

/usr/bin/sudo mkdir -p ${certificatesWorkspace}
/usr/bin/sudo chown $(id -u ${baseUser}):$(id -g ${baseUser}) ${certificatesWorkspace}
cd ${certificatesWorkspace}

if [[ "${kubeOrchestrator}" == "k8s" ]]; then

  # Download and install latest Kubectl and kubeadm binaries
  apt-get update
  DEBIAN_FRONTEND=noninteractive /usr/bin/sudo apt-get install -y apt-transport-https
  /usr/bin/sudo curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | apt-key add -
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | /usr/bin/sudo tee /etc/apt/sources.list.d/kubernetes.list
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | /usr/bin/sudo tee /etc/apt/sources.list.d/kubernetes.list
  
  # Read Kubernetes version to be installed
  kubeVersion=$(cat ${installationWorkspace}/versions.json | jq -r '.kubernetes')
  for i in {1..5}
  do
    log_info "Installing Kubernetes tools (Attempt ${i} of 5)."
    /usr/bin/sudo apt-get update
    DEBIAN_FRONTEND=noninteractive /usr/bin/sudo apt-get install -y kubelet=${kubeVersion} kubeadm=${kubeVersion} kubectl=${kubeVersion}
    /usr/bin/sudo apt-mark hold kubelet kubeadm kubectl
    if [[ -n $(kubectl version) ]]; then
      log_info "Kubectl accessible after install. Looks good. Continuing."
      break
    else
      log_warn "Kubectl not accessible after install. Trying again."
      sleep 15
    fi
  done

  # Final check for Kubectl
  if [[ -n $(kubectl version) ]]; then
    log_info "Kubectl accessible after install. Looks good. Continuing."
  else
    log_info "Kubectl not accessible after several tries to install. Exiting with a non-zero status code."
    exit 1
  fi

else
  # Install K3s instead, as K8s not specified in profile
  for i in {1..5}
  do
    curl -sfL https://get.k3s.io -o ${installationWorkspace}/k3s-install.sh
    if [[ -f ${installationWorkspace}/k3s-install.sh ]]; then
      log_info "k3s-install.sh downloaded. Looks good. Continuing."
      break
    else
      log_warn "k3s-install.sh not accessible after download. Trying again."
      sleep 15
    fi
  done
fi

# Install Kubeval for validating Kubernetes YAML files before deploying them
if [[ "${cpuArchitecture}" == "amd64" ]]; then
  # Install Kubernetes YAML validation tool
  downloadFile "https://github.com/instrumenta/kubeval/releases/download/${kubevalVersion}/kubeval-linux-amd64.tar.gz" \
    "${kubevalChecksum}" \
    "${installationWorkspace}/kubeval-linux-amd64.tar.gz"

  tar xf ${installationWorkspace}/kubeval-linux-amd64.tar.gz -C ${installationWorkspace}
  /usr/bin/sudo cp -f ${installationWorkspace}/kubeval /usr/local/bin
else
    # Build binary for ARM64 as not available yet (at time of writing)
    /usr/bin/sudo apt-get install -y golang
    mkdir -p ${installationWorkspace}/kubeval
    git clone --depth 1 --branch ${kubevalVersion} https://github.com/instrumenta/kubeval.git ${installationWorkspace}/kubeval
    cd ${installationWorkspace}/kubeval
    make build
    /usr/bin/sudo ${installationWorkspace}/kubeval/bin/kubeval /usr/local/bin
fi

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
/usr/bin/sudo chown -hR ${baseUser}:${baseUser} /home/${baseUser}

# Add stable helm repo if it does not already exist
helmRepoExists=$(helm repo list --output json | jq -r '.[] | select(.name=="stable") | .name' || true)
if [[ -z ${helmRepoExists} ]]; then
    helm repo add stable https://charts.helm.sh/stable
fi
helm repo update

# Switch off swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Error with rc=1 if kubectl still doesn't exist
if [[ "${kubeOrchestrator}" == "k8s" ]]; then
  which kubectl
fi