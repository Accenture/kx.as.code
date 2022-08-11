#!/bin/bash
set -euox pipefail

# Create MinIO-S3 service account
minioS3CreateServiceAccount "kxascode-sa"