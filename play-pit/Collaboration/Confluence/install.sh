#!/bin/bash -x
set -euo pipefail

# Create namesace if it does not already exist
if [ "$(kubectl get namespace confluence --template={{.status.phase}})" = "Active" ]; then
    # Create Kubernetes Namespace for Confleunce
    kubectl delete -f .
fi

# Apply the Confluence configuration files
kubectl apply -n confluence -f .

# Install the desktop shortcut
./createDesktopShortcut.sh
