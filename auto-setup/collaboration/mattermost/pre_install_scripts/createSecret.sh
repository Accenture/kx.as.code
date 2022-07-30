#!/bin/bash
set -euo pipefail

# Copy Minio secret to Gitlab namespace for Mattermost to use
minioAccessKey=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
minioSecretKey=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)
gitlabPostgresqlPassword=$(kubectl get secret gitlab-postgresql-password -n gitlab -o json | jq -r '.data."postgresql-password"' | base64 --decode)

# Create secret for MinIO if it does not exist
kubectl get secret minio-accesskey-secret --namespace ${namespace} ||
    kubectl create secret generic minio-accesskey-secret \
        --from-literal=accesskey=${minioAccessKey} \
        --from-literal=secretkey=${minioSecretKey} \
        --namespace ${namespace}

# Create secret for Gitlab Postgresql if it does not exist
kubectl get secret gitlab-postgresql-password --namespace ${namespace} ||
    kubectl create secret generic gitlab-postgresql-password \
        --from-literal=postgresql-password=${gitlabPostgresqlPassword} \
        --namespace ${namespace}