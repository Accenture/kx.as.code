#!/bin/bash -eux

# Create namesace if it does not already exist
if [ "$(kubectl get namespace jira --template={{.status.phase}})" = "Active" ]; then
  # Create Kubernetes Namespace for jira
  kubectl create namespace jira
fi

# Apply the Jira configuration files
kubectl apply -f .

# Install the desktop shortcut
./createDesktopShortcut.sh
