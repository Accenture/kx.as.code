deployYamlFilesToKubernetes() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Create regcred for pulling images from private registry
    createK8sCredentialSecretForCoreRegistry

    if [[ -d ${installComponentDirectory}/deployment_yaml ]]; then

        shopt -s globstar nullglob
        local yamlFiles=( ${installComponentDirectory}/deployment_yaml/*.yaml )
        log_info "Found following YAML files to process for ${componentName}:\n${yamlFiles[@]}"

        if [[ -n ${yamlFiles[@]} ]]; then

            for i in "${!yamlFiles[@]}"; do

                log_info "Procssing yaml file #${i} --> ${yamlFiles[$i]}"
                local yamlFilename="${componentName}_$(basename ${yamlFiles[$i]})"
                envhandlebars <${yamlFiles[$i]} >${installationWorkspace}/${yamlFilename}
                updateStorageClassIfNeeded "${installationWorkspace}/${yamlFilename}"
                log_debug "kubeval ${installationWorkspace}/${yamlFilename} --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master --strict --ignore-missing-schemas"
                kubeval ${installationWorkspace}/${yamlFilename} --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master --strict --ignore-missing-schemas || rc=$? && log_info "kubeval returned with rc=$rc"
                if [[ ${rc} -eq 0 ]]; then
                    log_info "YAML validation ok for ${yamlFilename}. Continuing to apply."
                    # Adapt namespace if resource yaml specifies an alternative to the default
                    local alternateNamespace=$(cat  ${installationWorkspace}/${yamlFilename} | yq -r '.metadata.namespace')
                    if [[ -n ${alternateNamespace} ]] && [[ "${alternateNamespace}" != "null" ]] && [[ "${namespace}" != "${alternateNamespace}" ]]; then
                        log_debug "Detected alternate namespace in resource YAML. Will deploy to \"${alternateNamespace}\" namespace, instead of \"${namespace}\""
                        kubectl apply -f ${installationWorkspace}/${yamlFilename} -n ${alternateNamespace}
                    else
                        kubectl apply -f ${installationWorkspace}/${yamlFilename} -n ${namespace}
                    fi
                else
                    log_error "YAML validation failed for ${yamlFiles[$i]}. Exiting"
                    return ${rc}
                fi

            done
        else
            log_warn "No YAML files found in ${installationWorkspace}/deployment_yaml. Nothing to apply"
        fi
        shopt -u globstar nullglob
    else
        log_warn "${installationWorkspace}/deployment_yaml not found. Nothing to deploy."
    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}
