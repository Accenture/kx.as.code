#!/bin/bash -eux

# Create secret for CA certificates. This ensures the ALM integration with Gitlab works
kubectl get secret kx-ca-certs -n ${namespace} ||
    kubectl create secret generic kx-ca-certs --from-file=/home/${vmUser}/Kubernetes/kx-certs/ca.crt --from-file=/home/${vmUser}/Kubernetes/kx-certs/tls.crt -n ${namespace}
