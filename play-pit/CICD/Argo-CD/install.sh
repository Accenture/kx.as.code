#!/bin/bash -eux

# Create namespace if it does not already exist
if [ "$(kubectl get namespace argocd --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for argocd
  kubectl create -f argocd-namespace.yaml
fi
 
# Apply the ArgoCD  configuration files
kubectl apply -n argocd  \
  -f argocd-install.yaml \
  -f argocd-ingress.yaml 

# Install the desktop shortcut
./createDesktopShortcut.sh
