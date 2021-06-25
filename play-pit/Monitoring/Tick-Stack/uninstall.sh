#!/bin/bash -x
set -euo pipefail

# Uninstall Tick-Stack with Helm
helm uninstall influxdb --namespace tick-stack
helm uninstall chronograf --namespace tick-stack
helm uninstall kapacitor --namespace tick-stack
helm uninstall telegraf-ds --namespace tick-stack

# Delete Secrets
kubectl delete secret influxdb-auth --namespace tick-stack
rm -f ./username.txt
rm -f ./password.txt

# Remove the Tick-Stack configurations
kubectl delete --namespace tick-stack \
    -f persistentVolumeClaims.yaml \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete Kubernetes Namespace for Tick-Stack
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/tick-stack/influxdb
sudo rm -rf $HOME/KX_Data/tick-stack/chronograf
sudo rm -rf $HOME/KX_Data/tick-stack/kapacitor
sudo rm -rf $HOME/KX_Data/tick-stack/telegraf

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Chronograf"
