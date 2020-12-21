#!/bin/bash -eux

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namespace if it does not already exist
if [ "$(kubectl get namespace influxdata --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for InfluxDb2
  kubectl create -f namespace.yaml
fi

# Apply the InfluxDb2 configuration files
kubectl create --dry-run=client -o yaml --namespace influxdata \
  -f persistentVolumes.yaml \
  -f persistentVolumeClaims.yaml \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo add influxdata https://influxdata.github.io/helm-charts
helm repo update

# Install InfluxDB2 with Helm
helm upgrade --install influxdb2 influxdata/influxdb2 -f values_influxdb2.yaml --namespace influxdata

# Install the desktop shortcut
./createDesktopShortcut.sh
