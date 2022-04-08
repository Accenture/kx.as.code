#!/bin/bash
set -euox pipefail

vaultSealStatus=$(kubectl exec -n ${namespace} vault-0 -- vault status -format=json | jq -r '.sealed')
if [[ "${vaultSealStatus}" == "true"   ]]; then
    unsealKeys=$(echo -e $(kubectl get secret vault-unseal-keys -n ${namespace} -o json | jq -r '.data."unseal-keys"' | base64 --decode))
    for unsealKey in ${unsealKeys}; do
        vaultSealStatus=$(kubectl exec -n ${namespace} vault-0 -- vault status -format=json | jq -r '.sealed')
        if [[ "${vaultSealStatus}" == "false" ]]; then
            break
        else
            kubectl exec -n ${namespace} vault-0 -- vault operator unseal "${unsealKey}" || true
            sleep 5
        fi
    done
fi
