#!/bin/bash -x

# Add CA certs secret for the local domain
kubectl -n kube-system create secret generic kx-certificates \
  --from-file=${installationWorkspace}/certificates/kx_root_ca.pem \
  --from-file=${installationWorkspace}/certificates/kx_intermediate_ca.pem