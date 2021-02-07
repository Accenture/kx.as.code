#!/bin/bash -eux

# Create secret for CA certificates. This ensures the ALM integration with Gitlab works
kubectl get secret kx-ca-certs -n ${namespace} ||
    kubectl create secret generic kx-ca-certs --from-file=${installationWorkspace}/kx-certs/ca.crt --from-file=${installationWorkspace}/kx-certs/tls.crt -n ${namespace}