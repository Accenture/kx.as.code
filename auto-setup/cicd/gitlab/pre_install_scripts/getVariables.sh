#!/bin/bash
set -euo pipefail

# Get Mino-S3 access and secret keys
minioS3GetAccessAndSecretKeys

# Get NGINX controller IP
export nginxIngressIp=$(getNginxControllerIp)