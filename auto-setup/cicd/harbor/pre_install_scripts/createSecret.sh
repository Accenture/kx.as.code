#!/bin/bash -x
set -euo pipefail

# Add KX.AS.CODE CA cert to Harbor namespace
kubectl get secret kx.as.code-wildcard-cert --namespace=${namespace} ||
        kubectl create secret generic kx.as.code-wildcard-cert \
        --from-file=/home/${vmUser}/Kubernetes/kx-certs \
        --namespace=${namespace}
