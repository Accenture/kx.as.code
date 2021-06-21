#!/bin/bash -x
set -euo pipefail

# Install Self-Signing TLS Certificate Manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.yaml

# Check whether cert-manager-webhook is ready
kubectl rollout status deployment cert-manager-webhook -n ${namespace} --timeout=30m
