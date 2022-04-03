deployYamlFilesToKubernetes() {

    log_debug "Entered function deployYamlFilesToKubernetes()"

    # Create regcred for pulling images from private registry
    createK8sCredentialSecretForCoreRegistry

    if [[ -d ${installComponentDirectory}/deployment_yaml ]]; then

        shopt -s globstar nullglob
        export yamlFiles=( ${installComponentDirectory}/deployment_yaml/*.yaml )
        log_info "Found following YMAL files to process for ${componentName}:\n${yamlFiles[@]}"

        if [[ -n ${yamlFiles[@]} ]]; then

            for i in "${!yamlFiles[@]}"; do

                log_info "Procssing yaml file #${i} --> ${yamlFiles[$i]}"
                yamlFilename="${componentName}_$(basename ${yamlFiles[$i]})"
                envhandlebars <${yamlFiles[$i]} >${installationWorkspace}/${yamlFilename}
                kubeval ${installationWorkspace}/${yamlFilename} --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master --strict || rc=$? && log_info "kubeval returned with rc=$rc"
                if [[ ${rc} -eq 0 ]]; then
                    log_info "YAML validation ok for ${yamlFilename}. Continuing to apply."
                    kubectl apply -f ${installationWorkspace}/${yamlFilename} -n ${namespace}
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

}
