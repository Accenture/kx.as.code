#!/bin/bash -x
set -euo pipefail

# Uninstall Mattermost with Helm
helm uninstall mattermost --namespace mattermost

# Remove the Mattermost configurations
kubectl delete --namespace rocketchat \
    -f persistentVolumeClaims.yaml \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete Kubernetes Namespace for Mattermost
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/mattermost

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Mattermost"
