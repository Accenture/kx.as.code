#!/bin/bash -x
set -euo pipefail

vaultInitializedStatus=$(kubectl exec -ti -n ${namespace} vault-0 -- vault status -format=json | jq -r '.initialized')
if [[ ${vaultInitializedStatus} != "true"   ]]; then
    kubectl exec -ti -n ${namespace} vault-0 -- vault operator init | tee ${installationWorkspace}/vaultTmp.txt
    cat -v ${installationWorkspace}/vaultTmp.txt | sed 's/\^\[\[0m//g' | sed 's/\^M//g' | tee ${installationWorkspace}/vaultInit.txt

    # Save initial root token as secret
    initialRootToken=$(cat -v ${installationWorkspace}/vaultInit.txt | grep "Initial Root Token: " | cut -f2 -d':' | sed 's/ //g')
    kubectl get secret vault-intial-root-token -n ${namespace} ||
        kubectl create secret generic vault-intial-root-token --from-literal=initial-root-token=${initialRootToken} -n ${namespace}

    # Save unseal keys as secret
    unsealKeys=$(cat -v ${installationWorkspace}/vaultInit.txt | grep Unseal | cut -f2 -d':' | sed 's/ //g')
    kubectl get secret vault-unseal-keys -n ${namespace} ||
        kubectl create secret generic vault-unseal-keys --from-literal=unseal-keys="${unsealKeys}" -n ${namespace}
fi
