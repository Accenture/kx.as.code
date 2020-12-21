#!/bin/bash -eux

# Uninstall SonarQube with Helm
helm uninstall sonarqube --namespace sonarqube

# Remove the SonarQube configurations
kubectl delete --namespace rocketchat \
  -f persistentVolumeClaims.yaml \
  -f persistentVolumes.yaml \
  -f ingress.yaml \
  --ignore-not-found

# Delete Kubernetes Namespace for SonarQube
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/sonarqube

# Delete desktop shortcut
rm -f $HOME/Desktop/SonarQube.desktop
