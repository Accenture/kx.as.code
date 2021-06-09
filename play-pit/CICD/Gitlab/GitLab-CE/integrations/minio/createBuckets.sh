#!/bin/bash -x
set -euo pipefail

# Install MinIO command line tool (mc) if not yet install
if [ ! -f /usr/local/bin/mc ]; then
    curl --output mc https://dl.min.io/client/mc/release/linux-amd64/mc
    # Give MC execute permissions
    chmod +x mc
    # Move to bin folder on path
    sudo mv mc /usr/local/bin
fi

MINIO_ACCESS_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)

# Cretae the S3 Buckets needed for Gitlab in MinIO
mc config host add minio https://s3.kx-as-code.local ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} --api S3v4
mc mb minio/gitlab-artifacts-storage --insecure
mc mb minio/gitlab-backup-storage --insecure
mc mb minio/gitlab-lfs-storage --insecure
mc mb minio/gitlab-packages-storage --insecure
mc mb minio/gitlab-registry-storage --insecure
mc mb minio/gitlab-uploads-storage --insecure

# List created S3 buckets
mc ls minio --insecure
