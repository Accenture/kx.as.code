#!/bin/bash
set -euox pipefail

# Create combined server and intermediate CA crt file
cat ${installationWorkspace}/kx-certs/tls.crt \
    ${installationWorkspace}/certificates/kx_intermediate_ca.pem \
    | sudo tee ${installationWorkspace}/docker-registry-tls.crt

# Add KX.AS.CODE CA cert to Docker Registry namespace
kubectl get secret docker-registry-tls-cert --namespace=${namespace} ||
    kubectl create secret generic docker-registry-tls-cert \
        --from-file=${installationWorkspace}/docker-registry-tls.crt \
        --from-file=${installationWorkspace}/kx-certs/tls.key \
        --from-file=${installationWorkspace}/kx-certs/ca.crt \
        --namespace=${namespace}