#!/bin/bash
set -euo pipefail

# Get MinIO Access Access and Secret Keys
export minioAccessKey=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
export minioSecretKey=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)
