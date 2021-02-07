#!/bin/bash -eux

# install fluxctl
# curl -sL https://fluxcd.io/install | sh

# Create namesace if it does not already exist
if [ "$(kubectl get namespace flux --template={{.status.phase}})" = "Active" ]; then
  # Create Kubernetes Objects for flux
  kubectl delete -f .
fi

# Apply the Flux configuration files
kubectl apply -f .
