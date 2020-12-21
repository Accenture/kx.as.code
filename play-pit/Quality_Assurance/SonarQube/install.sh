#!/bin/bash -eux

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namespace if it does not already exist
if [ "$(kubectl get namespace sonarqube --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for SonarQube
  kubectl create -f namespace.yaml
fi

# Apply the SonarQube configuration files
kubectl create --dry-run=client -o yaml --namespace sonarqube \
  -f persistentVolumes.yaml \
  -f persistentVolumeClaims.yaml \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo add oteemocharts https://oteemo.github.io/charts
helm repo update

# Install SonarQube with Helm
helm install sonarqube oteemocharts/sonarqube -f values.yaml --namespace sonarqube

# Install the desktop shortcut
./createDesktopShortcut.sh
