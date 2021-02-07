#!/bin/bash -eux

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namesace if it does not already exist
if [ "$(kubectl get namespace vault --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for Vault
  kubectl create -f namespace.yaml
fi

# Apply the Vault configuration files
kubectl create --dry-run=client -o yaml --namespace vault \
  -f persistentVolumes.yaml \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Install Vault with Helm
helm upgrade --install vault hashicorp/vault --namespace vault

# Install the desktop shortcut for Vault
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="vault" \
  --url=https://vault.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/05_DevSecOps/05_Vault/vault.png
