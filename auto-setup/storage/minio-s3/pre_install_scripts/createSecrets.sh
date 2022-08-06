#!/bin/bash
set -euo pipefail

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-s3 --output=name --field-selector metadata.name=minio-admin-secret) ]; then
    # Create MinIO admin user secret
    export minio-admin-password=$(managedApiKey "minio-admin-password" "minio-s3")
    kubectl create secret generic minio-admin-secret \
        --from-literal=rootUser="admin" \
        --from-literal=rootPassword="${minio-admin-password}" \
        --namespace minio-s3
fi

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-s3 --output=name --field-selector metadata.name=minio-accesskey-secret) ]; then
    # Create MinIO Access Key secret
    export minioAccessKey=$(managedApiKey "minio-s3-access-key" "minio-s3")
    export minioSecretKey=$(managedApiKey "minio-s3-secret-key" "minio-s3")
    kubectl create secret generic minio-accesskey-secret \
        --from-literal=accesskey=${minioAccessKey} \
        --from-literal=secretkey=${minioSecretKey} \
        --namespace minio-s3
fi