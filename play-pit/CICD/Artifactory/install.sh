#!/bin/bash -x
set -euo pipefail

# Create namespace if it does not already exist
if [ "$(kubectl get namespace artifactory --template={{.status.phase}})" = "Active" ]; then
    # Create Kubernetes Objects for Artifactory
    kubectl delete -f .
fi

# Apply Configuration file for Artifactory
  kubectl apply -f .

# Install the desktop shortcut
./createDesktopShortcut.sh
