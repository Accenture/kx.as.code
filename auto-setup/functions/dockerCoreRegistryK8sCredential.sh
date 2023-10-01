createK8sCredentialSecretForCoreRegistry() {

  # Check core docker-registry is installed and accessible before creating secret to login and access it
  if checkApplicationInstalled "docker-registry" "core"; then
  
    # Login to ensure credential file present
    loginToCoreRegistry
    
    # Create regred in namespace
    if [[ -f /root/.docker/config.json ]]; then
    kubectl get secret regcred -n ${namespace} ||
      kubectl create secret generic regcred \
          --from-file=.dockerconfigjson=/root/.docker/config.json \
          --type=kubernetes.io/dockerconfigjson \
          -n ${namespace} \
      && log_info "Added regcred to ${namespace} namespace"   
    else
      log_error "/root/.docker/config.json not found. Cannot create regred secret in ${namespace} namespace"
      return 1
    fi

  fi

}
