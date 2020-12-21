#!/bin/bash -eux

# Create namespace if it does not already exist
if [ "$(kubectl get namespace selenium --template={{.status.phase}})" = "Active" ]; then
  # Create Kubernetes Objects for Jenkins
  kubectl delete -f .
fi

# Apply the Selenium configuration files
kubectl apply  -f .

# Install the desktop shortcut
./createDesktopShortcut.sh
