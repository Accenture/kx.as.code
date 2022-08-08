kubernetesApplyYamlFile() {

    log_debug "Entered function kubernetesApplyYamlFile()"

    kubeYamlFileLocation=${1}
    kubeNamespace=${2}

    if [[ -f ${kubeYamlFileLocation} ]]; then

        # Do moustache variable replacements
        envhandlebars <${kubeYamlFileLocation} >${kubeYamlFileLocation}_processed

        # Check if storage-class needs updating
        updateStorageClassIfNeeded "${kubeYamlFileLocation}"

        # Validate YAML file
        kubeval ${kubeYamlFileLocation} --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master --strict || rc=$? && log_info "kubeval returned with rc=$rc"
        if [[ ${rc} -eq 0 ]]; then
            log_info "YAML validation ok for ${kubeYamlFileLocation}. Continuing to apply."
            log_debug "$(kubectl apply -f ${kubeYamlFileLocation} -n ${kubeNamespace})"
        else
            log_error "YAML validation failed for ${kubeYamlFileLocation}. Exiting"
            return ${rc}
        fi

    else
        log_warn "${kubeYamlFileLocation} not found. Exiting with RC=1"
        exit 1
    fi

}
