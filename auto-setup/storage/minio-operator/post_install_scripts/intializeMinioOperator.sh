#!/bin/bash
set -euox pipefail

# Create MinIO-S3 servie account
minioS3CreateServiceAccount "kxascode-sa"