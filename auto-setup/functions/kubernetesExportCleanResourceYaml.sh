kubernetesExportCleanResourceYaml() {

    set -x

    kubernetesResourceName=${1}
    kubernetesResourceType=${2}
    kubernetesResourceNamespace=${3}

    kubectl get ${kubernetesResourceType} -n ${kubernetesResourceNamespace} ${kubernetesResourceName} -o yaml | \
        /usr/local/bin/yq 'del(.metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp, .metadata.selfLink, .metadata.managedFields, .metadata.annotations."kubectl.kubernetes.io/last-applied-configuration", .status, .metadata.ownerReferences)' --yaml-output | tee ${installationWorkspace}/${kubernetesResourceName}-${kubernetesResourceType}-${kubernetesResourceNamespace}_export.yaml

}
