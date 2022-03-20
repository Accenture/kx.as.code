#!/bin/bash -x
set -euo pipefail

# Create the S3 Buckets needed for Gitlab in MinIO
mc config host add minio ${s3ObjectStoreUrl} ${minioAccessKey} ${minioSecretKey} --api S3v4
log_debug "mc config host add minio ${s3ObjectStoreUrl} ${minioAccessKey} ${minioSecretKey} --api S3v4"
# The variable "s3BucketsToCreate" is defined in Gitlab's metadata.json
export s3BucketsToCreate=$(echo ${s3BucketsToCreate} | sed 's/;/ /g')
for bucket in ${s3BucketsToCreate}; do
    bucketExists=$(mc ls minio --insecure --json | jq '. | select(.key=="'${bucket}'/")')
    if [[ -z ${bucketExists} ]]; then
        mc mb minio/${bucket} --insecure
    fi
done

# List created S3 buckets
mc ls minio --insecure
