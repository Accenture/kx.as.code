kubernetesExportResource() {

    local resourceName=${1}
    local resourceType=${2}
    local namespace=${3}

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Export clean YAML for Kubernetes resource
    kubectl get ${resourceType} ${resourceName} -n ${namespace} -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | yq eval . --prettyPrint | tee -a ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.yaml

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}