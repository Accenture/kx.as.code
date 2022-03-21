createKubernetesNamespace() {

  if [[ -n $(which kubectl || true) ]]; then
    if [[ -z ${namespace} ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default"   ]]; then
        log_info "System namespace or namespace defined for \"${componentName}\" in metadata.json. Not creating namespace. Most likely intentional and not an issue"
    fi
    if [[ -n ${namespace} ]]; then
        if [[ "$(kubectl get namespace ${namespace} --template={{.status.phase}})" != "Active" ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default" ]]; then
            log_info "Namespace \"${namespace}\" does not exist. Creating"
            kubectl create namespace ${namespace}
        else
            log_info "Namespace \"${namespace}\" already exists. Moving on"
        fi
    fi
  else
    log_debug "Kubectl not yet installed. Skipping namespace creation"
  fi
}
