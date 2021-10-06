#!/bin/bash -x
set -euo pipefail

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-s3 --output=name --field-selector metadata.name=minio-accesskey-secret) ]; then
    # Create MinIO Access Key secret
    export MINIOS3_ACCESS_KEY=$(managedApiKey "minio-s3-access-key")
    export MINIOS3_SECRET_KEY=$(managedApiKey "minio-s3-secret-key")
    kubectl create secret generic minio-accesskey-secret \
        --from-literal=accesskey=${MINIOS3_ACCESS_KEY} \
        --from-literal=secretkey=${MINIOS3_SECRET_KEY} \
        --namespace minio-s3
fi
