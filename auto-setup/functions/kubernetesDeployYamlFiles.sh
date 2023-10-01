deployYamlFilesToKubernetes() {

    # Create regcred for pulling images from private registry
    createK8sCredentialSecretForCoreRegistry

    if [[ -d ${installComponentDirectory}/deployment_yaml ]]; then

        shopt -s globstar nullglob
        local yamlFiles=$( ( grep -i -L -E "kind:.*deployment" ${installComponentDirectory}/deployment_yaml/*.yaml && grep -i -l -E "kind:.*deployment" ${installComponentDirectory}/deployment_yaml/*.yaml ) )
        log_info "Found following YAML files to process for ${componentName}:\n${yamlFiles[@]}"

        if [[ -n ${yamlFiles} ]]; then
            for yamlFile in ${yamlFiles}; do
                log_info "Procssing yaml file ${yamlFile}"
		        kubernetesApplyYamlFile "${yamlFile}" "${namespace}"
            done
        else
            log_warn "No YAML files found in ${installComponentDirectory}/deployment_yaml. Nothing to apply"
        fi
        shopt -u globstar nullglob
    else
        log_warn "${installComponentDirectory}/deployment_yaml not found. Nothing to deploy."
    fi
    
}
