#!/bin/bash -x
set -euo pipefail

# Copy Minio secret to Gitlab namespace for Mattermost to use
minioAccessKey=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
minioSecretKey=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)

# Create secret if it does not exist
kubectl get secret minio-accesskey-secret --namespace ${namespace} ||
    kubectl create secret generic minio-accesskey-secret \
        --from-literal=accesskey=${minioAccessKey} \
        --from-literal=secretkey=${minioSecretKey} \
        --namespace ${namespace}
