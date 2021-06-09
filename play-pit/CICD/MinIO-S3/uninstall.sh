#!/bin/bash -x
set -euo pipefail

# Delete diretories
rm -rf $HOME/KX_Data/minio_s3

# Delete MinIO deployments for K8s
kubectl delete \
    -f persistentVolume.yaml \
    -f persistentVolumeClaim.yaml \
    -f deployment.yaml \
    -f service.yaml \
    -f ingress.yaml \
    -f namespace.yaml

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="MinIO S3"
