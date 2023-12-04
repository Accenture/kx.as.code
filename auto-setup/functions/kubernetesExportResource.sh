kubernetesExportResource() {

    set -x

    local resourceName=${1}
    local resourceType=${2}
    local namespace=${3}
    local output=${4-yaml} # json or yaml

    # Export clean YAML or JSON  for Kubernetes resource
    if [[ "${output,,}" == "yaml" ]]; then
        kubectl get ${resourceType} ${resourceName} -n ${namespace} -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | /usr/bin/yq eval . --prettyPrint | tee ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.yaml
    else
        kubectl get ${resourceType} ${resourceName} -n ${namespace} -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | tee ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.json
    fi
    
}
