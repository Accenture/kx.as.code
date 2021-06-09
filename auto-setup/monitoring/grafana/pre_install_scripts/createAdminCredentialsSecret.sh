#!/bin/bash -x
set -euo pipefail

# Create Grafana admin user secret
kubectl get secret  grafana-admin-credentials -n ${namespace} ||
    kubectl create secret generic grafana-admin-credentials --from-literal=admin-user=admin --from-literal=admin-password="${vmPassword}" -n ${namespace}
