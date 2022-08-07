#!/bin/bash
set -euox pipefail

# Get MinIO Kubernetes Operator
/usr/bin/sudo wget https://github.com/minio/operator/releases/download/v${operatorVersion}/kubectl-minio_${operatorVersion}_linux_amd64 -O kubectl-minio
/usr/bin/sudo chmod +x kubectl-minio
/usr/bin/sudo mv kubectl-minio /usr/local/bin/

# Check version
kubectl minio version

