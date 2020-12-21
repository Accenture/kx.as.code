#!/bin/bash -eux

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namespace if it does not already exist
if [ "$(kubectl get namespace netdata --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for Netdata
  kubectl create -f namespace.yaml
fi

# Apply the Netdata configuration files
kubectl create --dry-run=client -o yaml --namespace netdata \
  -f persistentVolumes.yaml \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo update

# Get Chat
git clone https://github.com/netdata/helmchart.git netdata-chart

# Install Netdata with Helm
helm install netdata ./netdata-chart -f values.yaml --namespace netdata

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Netdata" \
  --url=https://netdata.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/06_Netdata/netdata.png
