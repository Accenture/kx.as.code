#!/bin/bash -eux

# Uninstall Vault with Helm
helm uninstall vault --namespace vault

# Remove the Vault configurations
kubectl delete --namespace vault \
  -f persistentVolumes.yaml \
  -f ingress.yaml \
  --ignore-not-found

# Delete Kubernetes Namespace for Vault
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/vault

# Delete desktop shortcut for Vault
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Vault"

