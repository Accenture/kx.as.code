#!/bin/bash
set -euo pipefail

# Create NeuVector service account in Kubernetes
kubectl get serviceaccount neuvector -n neuvector || \
    kubectl create serviceaccount neuvector -n ${namespace}
