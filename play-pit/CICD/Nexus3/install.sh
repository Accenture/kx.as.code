#!/bin/bash -x
set -euo pipefail

# Create namespace if it does not already exist
if [ "$(kubectl get namespace nexus --template={{.status.phase}})" = "Active" ]; then
    # Create Kubernetes Objects for Nexus
    kubectl delete -f .
fi

# Apply Configuration file for Nexus
  kubectl apply -f .

# Install the desktop shortcut
./createDesktopShortcut.sh
