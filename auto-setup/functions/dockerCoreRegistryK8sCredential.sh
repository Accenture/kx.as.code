createK8sCredentialSecretForCoreRegistry() {

    # Login to ensure credential file present
    loginToCoreRegistry
    
    # Create regred in namespace
    if [[ -f /root/.docker/config.json ]]
    kubectl get secret generic regcred -n ${namespace} ||
      kubectl create secret generic regcred \
          --from-file=.dockerconfigjson=/root/.docker/config.json \
          --type=kubernetes.io/dockerconfigjson \
          -n ${namespace} \
      && log_info "Added regcred to ${namespace} namespace"   
    else
      log_error "/root/.docker/config.json not found. Cannot create regred secret in ${namespace} namespace"
      return 1
    fi

}
