#!/bin/bash
set -euox pipefail

export vaultInitializedStatusJson=$(kubectl exec -n ${namespace} vault-0 -- vault status -format=json)
export vaultInitializedStatus=$(echo ${vaultInitializedStatusJson} | jq -r '.initialized')
export vaultInit=""

if [[ "${vaultInitializedStatus}" != "true" ]]; then
    # Extract the initial root password and unseal keys
    for i in {1..15}
    do
        export vaultTmp=$(kubectl exec -n ${namespace} vault-0 -- vault operator init || true)
        if [[ -n $(echo "${vaultTmp}" | grep "Initial Root Token") ]]; then
            export vaultInit=$(echo "${vaultTmp}" | sed 's/\^\[\[0m//g' | sed 's/\^M//g' | sed 's/$/\\\\n/g')
            getPassword "vault-initialization-text" "vault" || pushPassword "vault-initialization-text" "${vaultInit}" "vault"
            break
        else
            log_info "Vault initial root token and unseal keys not yet available, trying again"
            sleep 15
        fi
    done
fi

# Get vault-init text if script rerun and variable empty as a result
if [[ -z ${vaultInit} ]]; then
    vaultInitTemp=$(getPassword "vault-initialization-text" "vault")
    vaultInit=$(echo -e ${vaultInitTemp})
fi

# Save initial root token as secret
initialRootToken=$(echo -e "${vaultInit}" | grep "Initial Root Token: " | cut -f2 -d':' | sed 's/ //g')
for i in {1..15}
do
    kubectl get secret vault-initial-root-token -n ${namespace} ||
        kubectl create secret generic vault-initial-root-token --from-literal=initial-root-token=${initialRootToken} -n ${namespace}
    if [[ -n $(kubectl get secret vault-initial-root-token -n ${namespace} -o json | jq -r '.data."initial-root-token"') ]]; then
        # Populated secret found. Breaking out of loop
        getPassword "vault-initial-root-token" "vault" || pushPassword "vault-initial-root-token" "${initialRootToken}" "vault"
        break
    else
        # Delete empty secret and try again
        kubectl delete secret vault-initial-root-token -n ${namespace}
        sleep 15
    fi
done

# Save unseal keys as secret
unsealKeys=$(echo -e "${vaultInit}" | grep Unseal | cut -f2 -d':' | sed 's/ //g')
for i in {1..15}
do
    kubectl get secret vault-unseal-keys -n ${namespace} ||
        kubectl create secret generic vault-unseal-keys --from-literal=unseal-keys="${unsealKeys}" -n ${namespace}
    if [[ -n $(kubectl get secret vault-unseal-keys -n ${namespace} -o json | jq -r '.data."unseal-keys"') ]]; then
        # Populated secret found. Breaking out of loop
        getPassword "vault-initial-unseal-keys" "vault" || pushPassword "vault-initial-unseal-keys" "${unsealKeys}" "vault"
        break
    else
        # Delete empty secret and try again
        kubectl delete secret vault-unseal-keys -n ${namespace}
        sleep 15
    fi
done
