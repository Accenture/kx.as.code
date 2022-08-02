#!/bin/bash
set -euo pipefail

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-s3 --output=name --field-selector metadata.name=minio-accesskey-secret) ]; then
    # Create MinIO Access Key secret
    export minioAccessKey=$(managedApiKey "minio-s3-access-key")
    export minioSecretKey=$(managedApiKey "minio-s3-secret-key")
    kubectl create secret generic minio-accesskey-secret \
        --from-literal=accesskey=${minioAccessKey} \
        --from-literal=secretkey=${minioSecretKey} \
        --from-literal=rootUser=${minioAccessKey} \
        --from-literal=rootPassword=${minioSecretKey} \
        --namespace minio-s3
fi
