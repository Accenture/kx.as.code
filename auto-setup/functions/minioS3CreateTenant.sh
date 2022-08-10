minioS3CreateTenant() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "minio-operator" "storage"; then

        tenant=${1}
        servers=${2-1}
        volumes=${3-1}
        capacity=${4-10Gi}
        storageClass=${5-local-storage-sc }
        minioNamespace="minio-${tenant}"

        # Create Kubernetes Namespace
        kubectl get namespace ${minioNamespace} || kubectl create namespace ${minioNamespace} 

        # Create MinIO Tenantif not already existing
        if [[ -z "$(kubectl minio tenant status ${namespace} --json | jq -r '.currentState')" ]]; then
            kubectl minio tenant create "minio-${tenant}"    \
                --servers                 ${servers}         \
                --volumes                 ${volumes}         \
                --capacity                ${capacity}        \
                --storage-class           ${storageClass}    \
                --namespace               ${minioNamespace}
        fi

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}