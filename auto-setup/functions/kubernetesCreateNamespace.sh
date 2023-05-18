createKubernetesNamespace() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  if [[ -n $(which kubectl || true) ]]; then
    if [[ -z ${namespace} ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default"   ]]; then
        log_info "System namespace or namespace defined for \"${componentName}\" in metadata.json. Not creating namespace. Most likely intentional and not an issue"
    fi
    if [[ -n ${namespace} ]]; then
        if [[ "$(kubectl get namespace ${namespace} --template={{.status.phase}})" != "Active" ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default" ]]; then
            log_info "Namespace \"${namespace}\" does not exist. Creating"
            kubectl create namespace ${namespace}
            # Create secret to internal private registry
            log_debug "Creating regcred for internal private registry in \"${namespace}\""
            kubernetesCreateNamespacePrivatePullSecret
            # Install Secret if Credentials Exist
            if [[ -z $(kubectl get secret regcred -n ${namespace} -o name || true) ]]; then
            log_debug "Creating regcred for DockerHub in \"${namespace}\""
              dockerhubCreateDefaultRegcred "${namespace}"
              log_debug "Patching default namespace service account to automatically use \"regcred\" imagePullSecret"
              log_debug "This is important to avoid running into the Dockerhub rate limit"
              kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}' -n ${namespace}
            fi
        else
            log_info "Namespace \"${namespace}\" already exists. Moving on"
        fi
    fi
  else
    log_debug "Kubectl not yet installed. Skipping namespace creation"
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
