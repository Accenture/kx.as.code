#!/bin/bash
set -euox pipefail

# Initialize Minio-S3 Operator
kubectl minio init --namespace {{namespace}}

# Create MinIO-S3 servie account
minioS3CreateServiceAccount "kxascode-sa"