#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER

# Ensure time is accurate
sudo apt-get install -y ntpdate

KUBEDIR=/home/$VM_USER/Kubernetes
sudo mkdir -p $KUBEDIR
sudo chown $(id -u $VM_USER):$(id -g $VM_USER) $KUBEDIR
cd $KUBEDIR

# Download and install latest Kubectl and kubeadm binaries
sudo sudo apt-get update && sudo apt-get install -y apt-transport-https
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Install Helm 3
sudo curl -fsSL --output $KUBEDIR/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo chmod 700 $KUBEDIR/get_helm.sh
sudo $KUBEDIR/get_helm.sh

# Correct permissions before next step
sudo chown -hR $VM_USER:$VM_USER /home/$VM_USER

# Add Helm Chart Repository
sudo -H -i -u $VM_USER sh -c "helm repo add stable https://kubernetes-charts.storage.googleapis.com/"
sudo -H -i -u $VM_USER sh -c "helm repo update"
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Switch off swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
