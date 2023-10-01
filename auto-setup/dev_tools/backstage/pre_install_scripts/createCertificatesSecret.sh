#!/bin/bash

# Create combined server and intermediate CA crt file
cat ${installationWorkspace}/kx-certs/tls.crt \
    ${installationWorkspace}/certificates/kx_intermediate_ca.pem \
    | sudo tee ${installationWorkspace}/backstage-tls.crt

# Add KX.AS.CODE CA cert to Docker Registry namespace
kubectl get secret backstage-postgresql-certs --namespace=${namespace} ||
    kubectl create secret generic backstage-postgresql-certs \
        --from-file=${installationWorkspace}/backstage-tls.crt \
        --from-file=${installationWorkspace}/kx-certs/tls.key \
        --namespace=${namespace}
