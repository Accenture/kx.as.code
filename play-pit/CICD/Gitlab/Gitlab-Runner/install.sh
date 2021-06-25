#!/bin/bash -x
set -euo pipefail

# Create Concatenated Cert File
cat /home/$VM_USER/Kubernetes/z2h-certs/tls.crt /home/$VM_USER/Kubernetes/z2h-certs/ca.crt > /home/$VM_USER/Kubernetes/z2h-certs/gitlab.kx-as-code.local.crt

# Create Secret Containing Wildcard Cert for gitlab.kx-as-code.local
kubectl --namespace gitlab create secret generic gitlab-z2h-kx-as-code-cert --from-file=/home/$VM_USER/Kubernetes/z2h-certs/gitlab.kx-as-code.local.crt

# The Gitlab Runner Token needs to be updated in the values.yaml file before executing thebelow line
helm install --namespace gitlab gitlab-runner -f values.yaml gitlab/gitlab-runner
