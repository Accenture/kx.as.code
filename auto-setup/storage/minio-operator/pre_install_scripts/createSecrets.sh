#!/bin/bash

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-operator --output=name --field-selector metadata.name=minio-admin-secret) ]; then
    # Create MinIO admin user secret
    export minioAdminPassword=$(managedApiKey "minio-admin-password" "minio-operator")
    kubectl create secret generic minio-admin-secret \
        --from-literal=rootUser="admin" \
        --from-literal=rootPassword="${minioAdminPassword}" \
        --namespace minio-operator
fi

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-operator --output=name --field-selector metadata.name=minio-console-admin-access-secret) ]; then
    # Create MinIO admin user secret
    export minioConsoleAdminAccessKey=$(managedApiKey "minio-console-admin-access-key" "minio-operator")
    export minioConsoleAdminSecretKey=$(managedApiKey "minio-console-admin-secret-key" "minio-operator")
    kubectl create secret generic minio-console-admin-access-secret \
        --from-literal=accessKey="${minioConsoleAdminAccessKey}" \
        --from-literal=secretKey="${minioConsoleAdminSecretKey}" \
        --namespace minio-operator
fi
