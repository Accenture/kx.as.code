#!/bin/bash -x
set -euo pipefail

# Uninstall Grafana with Helm
helm uninstall grafana --namespace grafana

# Remove the Tick-Stack configurations
kubectl delete --namespace grafana \
    -f persistentVolumeClaims.yaml \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete Kubernetes Namespace for Grafana
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/grafana

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Grafana"

# Delete credential files
rm -f ./username.txt
rm -f ./password.txt
