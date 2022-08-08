#!/bin/bash
set -euo pipefail

# Create S3 Tenant for Gitlab
minioS3CreateTenant "gitlab"

# The variable "s3BucketsToCreate" is defined in Gitlab's metadata.json
export s3BucketsToCreate=$(echo ${s3BucketsToCreate} | sed 's/;/ /g')
for bucket in ${s3BucketsToCreate}; do
    # Call bash funtion to create bucket in Minio-S3
    minioS3CreateBucket "${bucket}" "gitlab" "eu-central-1"
done

# List created S3 buckets
mc ls gitlab --insecure
