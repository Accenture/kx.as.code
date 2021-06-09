#!/bin/bash -x
set -euo pipefail

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namesace if it does not already exist
if [ "$(kubectl get namespace prometheus --template={{.status.phase}})" != "Active" ]; then
    # Create Kubernetes Namespace for Prometheus
    kubectl create -f namespace.yaml
fi

# Apply the Prometheus configuration files
kubectl create --dry-run=client -o yaml --namespace prometheus \
    -f persistentVolumes.yaml \
    -f persistentVolumeClaims.yaml \
    -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo update

# Install Prometheus with Helm
helm upgrade --install prometheus stable/prometheus -f values.yaml --namespace prometheus

# Install the desktop shortcut for Prometheus
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Prometheus" \
    --url=https://prometheus.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/02_Prometheus/prometheus.png

# Install the desktop shortcut for Alert Manager
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Alert Manager" \
    --url=https://alertmanager.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/02_Prometheus/prometheus.png
