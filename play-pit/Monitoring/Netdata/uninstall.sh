#!/bin/bash -x
set -euo pipefail

# Uninstall Netdata with Helm
helm uninstall netdata --namespace netdata

# Remove the Tick-Stack configurations
kubectl delete --namespace netdata \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete Kubernetes Namespace for Netdata
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/netdata

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Netdata"

# Remove downloaded Chart
rm -rf ./netdata-chart
