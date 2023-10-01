#!/bin/bash

# Get MinIO Access Access and Secret Keys
if [[ $(checkApplicationInstalled "minio-operator" "storage") ]]; then
    export minioAccessKey=$(kubectl get secret minio-accesskey-secret -n minio-operator -o json | jq -r '.data.accesskey' | base64 --decode)
    export minioSecretKey=$(kubectl get secret minio-accesskey-secret -n minio-operator -o json | jq -r '.data.secretkey' | base64 --decode)
fi
