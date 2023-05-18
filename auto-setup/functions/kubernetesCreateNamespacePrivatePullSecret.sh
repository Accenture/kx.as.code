kubernetesCreateNamespacePrivatePullSecret() {

    # Create docker pull secret for private registry
    log_info "Adding user ${namespace} user to docker-registry htpasswd file"
    dockerRegistryAddUser "${namespace}"
    passwordForAddedUser=$(managedApiKey "docker-registry-${namespace}-password" "docker-registry")
    kubectl get secret ${namespace}-image-pull-secret --namespace=${namespace} || \
        kubectl create secret docker-registry ${namespace}-image-pull-secret \
        --namespace ${namespace} \
        --docker-server="https://docker-registry.${baseDomain}" \
        --docker-username="${namespace}" \
        --docker-password="${passwordForAddedUser}"

}