#!/bin/bash

initialRootToken=$(echo -e $(kubectl get secret vault-initial-root-token -n ${namespace} -o json | jq -r '.data."initial-root-token"' | base64 --decode))
kubectl exec -n ${namespace} vault-0 -- vault login "${initialRootToken}"
userPassAuthEnabled=$(kubectl exec -n ${namespace} vault-0 -- vault auth list -format=json | jq -r '."userpass/" | select(.type=="userpass") | .type')
if [[ -z ${userPassAuthEnabled} ]]; then
    kubectl exec -n ${namespace} vault-0 -- vault auth enable userpass
fi
