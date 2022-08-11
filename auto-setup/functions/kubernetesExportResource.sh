kubernetesExportResource() {

    local resourceName=${1}
    local resourceType=${2}
    local namespace=${3}
    local output=${4-yaml} # json or yaml
    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Export clean YAML or JSON  for Kubernetes resource
    if [[ "${output,,}" == "yaml" ]]; then
        kubectl get ${resourceType} ${resourceName} -n ${namespace} -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | yq eval . --prettyPrint | tee ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.yaml
    else
        kubectl get ${resourceType} ${resourceName} -n ${namespace} -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | tee ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.json
    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}