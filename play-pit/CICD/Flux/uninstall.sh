#!/bin/bash -x
set -euo pipefail

# Delete flux  deployments for K8s
kubectl delete -f .
