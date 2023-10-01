#!/bin/bash

# Set/Get Mino-S3 access and secret keys
minioS3GetAccessAndSecretKeys "gitlab"

# Get NGINX controller IP
export nginxIngressIp=$(getNginxControllerIp)