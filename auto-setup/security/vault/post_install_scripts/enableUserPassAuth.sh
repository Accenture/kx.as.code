#!/bin/bash -x
set -euo pipefail

initialRootToken=$(kubectl get secret vault-intial-root-token -n ${namespace} -o json | jq -r '.data."initial-root-token"' | base64 --decode)
kubectl exec -ti -n ${namespace} vault-0 -- vault login ${initialRootToken}
userPassAuthEnabled=$(kubectl exec -ti -n ${namespace} vault-0 -- vault auth list -format=json | jq -r '."userpass/" | select(.type=="userpass") | .type')
if [[ -z ${userPassAuthEnabled} ]]; then
    kubectl exec -ti -n ${namespace} vault-0 -- vault auth enable userpass
fi
