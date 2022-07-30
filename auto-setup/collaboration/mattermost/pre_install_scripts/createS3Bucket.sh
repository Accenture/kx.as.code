#!/bin/bash
set -euox pipefail

# Call bash funtion to create bucket in Minio-S3
minioS3CreateBucket "mattermost-file-storage"

