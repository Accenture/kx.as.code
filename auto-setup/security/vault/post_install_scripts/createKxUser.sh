#!/bin/bash -x
set -euo pipefail

initialRootToken=$(kubectl get secret vault-intial-root-token -n ${namespace} -o json | jq -r '.data."initial-root-token"' | base64 --decode)
kubectl exec -ti -n ${namespace} vault-0 -- vault login ${initialRootToken}
userExists=$(kubectl exec -ti -n ${namespace} vault-0 -- vault read auth/userpass/users/kx.heros | wc -l)
if [[ $userExists -le 1 ]]; then
    kubectl exec -ti -n ${namespace} vault-0 -- vault write auth/userpass/users/${vmUser} password=${vmPassword} policies=admins
fi
