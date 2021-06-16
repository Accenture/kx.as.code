#!/bin/bash -x
set -euo pipefail

# Create memberlist secret if it does not already exist
kubectl get secret -n ${namespace} memberlist -o json | jq -r '.metadata.name' || \
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
