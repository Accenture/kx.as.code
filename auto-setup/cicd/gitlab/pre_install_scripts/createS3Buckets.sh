#!/bin/bash
set -euo pipefail

# The variable "s3BucketsToCreate" is defined in Gitlab's metadata.json
export s3BucketsToCreate=$(echo ${s3BucketsToCreate} | sed 's/;/ /g')
for bucket in ${s3BucketsToCreate}; do
    # Call bash funtion to create bucket in Minio-S3
    minioS3CreateBucket "${bucket}"
done

# List created S3 buckets
mc ls myminio --insecure
