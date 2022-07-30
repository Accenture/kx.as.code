#!/bin/bash
set -euo pipefail

# Get Grafana username and password
export grafanaUser=$(kubectl get secret grafana-admin-credentials -n monitoring -o jsonpath='{.data.admin-user}' | base64 --decode)
export grafanaPassword=$(kubectl get secret grafana-admin-credentials -n monitoring -o jsonpath='{.data.admin-password}' | base64 --decode)
