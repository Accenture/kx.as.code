#!/bin/bash -x
set -euo pipefail

# Create namespace if it does not already exist
if [ "$(kubectl get namespace jenkins --template={{.status.phase}})" = "Active" ]; then
    # Create Kubernetes Objects for Jenkins
    kubectl delete -f .
fi

# Apply Configuration file for Jenkins
  kubectl apply -f .

# Install the desktop shortcut
./createDesktopShortcut.sh
