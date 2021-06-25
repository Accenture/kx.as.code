#!/bin/bash -x
set -euo pipefail

# Output K8s cluster health
kubectl cluster-info
kubectl get cs
