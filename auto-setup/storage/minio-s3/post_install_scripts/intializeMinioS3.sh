#!/bin/bash
set -euo pipefail

# Call function to initialize MinIO-S3
minioS3Initialize

# Create MinIO-S3 servie account
minioS3CreateServiceAccount "kxascode-sa"