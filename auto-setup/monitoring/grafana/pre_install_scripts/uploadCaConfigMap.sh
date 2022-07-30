#!/bin/bash
set -euo pipefail

# Add KX-CA to monitoring namespace
kubectl -n ${namespace} get configmap certs-configmap || kubectl -n ${namespace} create configmap certs-configmap \
    --from-file=${installationWorkspace}/certificates/kx_root_ca.pem \
    --from-file=${installationWorkspace}/certificates/kx_intermediate_ca.pem
