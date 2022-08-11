addKxCertsSecretToNamespace() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Add KX.AS.CODE CA cert to namespace
    kubectl get secret kx.as.code-wildcard-cert --namespace=${namespace} ||
        kubectl create secret generic kx.as.code-wildcard-cert \
        --from-file=${installationWorkspace}/kx-certs \
        --namespace=${namespace}

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}