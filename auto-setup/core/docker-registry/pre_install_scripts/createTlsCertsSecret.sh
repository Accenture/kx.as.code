#!/bin/bash
set -euox pipefail

# Add KX.AS.CODE CA cert to Docker Registry namespace
kubectl get secret kx.as.code-wildcard-cert --namespace=${namespace} ||
    kubectl create secret generic kx.as.code-wildcard-cert \
        --from-file=${installationWorkspace}/kx-certs \
        --namespace=${namespace}