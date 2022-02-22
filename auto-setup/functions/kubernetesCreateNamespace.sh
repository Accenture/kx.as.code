createKubernetesNamespace() {

    if [[ -z ${namespace} ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default"   ]]; then
        log_warn "Namespace name could not be established. Subsequent actions may fail if they have a dependency on this. Please validate the namespace entry is correct for \"${componentName}\" in metadata.json"
    fi
    if [[ -n ${namespace} ]]; then
        if [[ "$(kubectl get namespace ${namespace} --template={{.status.phase}})" != "Active" ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default" ]]; then
            log_info "Namespace \"${namespace}\" does not exist. Creating"
            kubectl create namespace ${namespace}
        else
            log_info "Namespace \"${namespace}\" already exists. Moving on"
        fi
    fi
}
