#!/bin/bash -x
set -euo pipefail

# Create Grafana Admin Password
export grafanaAdminPassword=$(managedPassword "grafana-admin-password")

# Create Grafana admin user secret
kubectl get secret  grafana-admin-credentials -n ${namespace} ||
    kubectl create secret generic grafana-admin-credentials --from-literal=admin-user=admin --from-literal=admin-password="${grafanaAdminPassword}" -n ${namespace}
