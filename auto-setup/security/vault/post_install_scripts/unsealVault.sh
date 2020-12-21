#!/bin/bash -eux

vaultUnsealStatus=$(kubectl exec -ti -n ${namespace} vault-0 -- vault status -format=json | jq -r '.sealed')
if [[ "${vaultUnsealStatus}" == "true" ]]; then
    unsealKeys=$(kubectl get secret vault-unseal-keys -n ${namespace} -o json | jq -r '.data."unseal-keys"' | base64 --decode)
    for unsealKey in ${unsealKeys}
    do
        for i in {1..5}
        do
            error="false"
            echo ${unsealKey}>unsealKey
            cat -v unsealKey
            kubectl exec -ti -n ${namespace} vault-0 -- vault operator unseal "${unsealKey}" || error="true"
            if [[ "${error}" == "false" ]]; then 
                break
            else 
                echo "Unsealing failed. Trying again"
                sleep 5
            fi
        done
    done
fi
