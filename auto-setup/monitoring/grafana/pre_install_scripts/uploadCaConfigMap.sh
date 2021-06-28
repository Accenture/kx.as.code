#!/bin/bash -eux

# Add KX-CA to monitoring namespace
kubectl -n ${namespace} create configmap certs-configmap \
  --from-file=${installationWorkspace}/certificates/kx_root_ca.pem \
  --from-file=${installationWorkspace}/certificates/kx_intermediate_ca.pem
