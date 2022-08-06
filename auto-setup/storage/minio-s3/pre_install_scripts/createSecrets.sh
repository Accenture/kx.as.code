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
