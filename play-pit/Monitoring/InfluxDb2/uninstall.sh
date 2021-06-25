#!/bin/bash -x
set -euo pipefail

# Uninstall Tick-Stack with Helm
helm uninstall influxdb2 --namespace influxdata

# Remove the Tick-Stack configurations
kubectl delete --namespace influxdata \
    -f persistentVolumeClaims.yaml \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete Kubernetes Namespace for Tick-Stack
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/influxdata

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="InfluxDb2"
