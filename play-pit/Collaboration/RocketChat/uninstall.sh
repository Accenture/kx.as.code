#!/bin/bash -eux

# Uninstall RocketChat with Helm
helm uninstall rocketchat --namespace rocketchat

# Remove the RocketChat configurations
kubectl delete --namespace rocketchat \
  -f storageClass.yaml \
  -f persistentVolumes.yaml \
  -f ingress.yaml \
  --ignore-not-found

# Delete Kubernetes Namespace for RocketChat
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/rocketchat

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="RocketChat"
