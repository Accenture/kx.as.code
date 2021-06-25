#!/bin/bash -x
set -euo pipefail

# Uninstall Prometheus with Helm
helm uninstall prometheus --namespace prometheus

# Remove the Prometheus configurations
kubectl delete --namespace prometheus \
    -f persistentVolumeClaims.yaml \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete Kubernetes Namespace for Prometheus
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/prometheus

# Delete desktop shortcut for Prometheus
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Prometheus"

# Delete desktop shortcut for Alert Manager
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Alert Manager"
