kubernetesCreateNamespacePrivatePullSecret() {

    # Check Docker Registry has running pods, not just an empty namespace
    local dockerRegistryPods=$(kubectl get pods -n docker-registry -o json | jq -r '.items[].status | select(.phase=="Running") | .phase | select(.!=null)')
    if [[ -n  ${dockerRegistryPods} ]]; then
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
  else
    log_info "Not adding pull secret to namespace for core local docker-registry, as docker-registry not yet running"
  fi
  
}
