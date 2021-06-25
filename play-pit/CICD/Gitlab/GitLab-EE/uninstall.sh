#!/bin/bash -x
set -euo pipefail

# Apply the Gitlab configuration files
kubectl delete --namespace gitlab \
    -f persistentVolumeClaims.yaml \
    -f persistentVolumes.yaml \
    -f ingress.yaml \
    --ignore-not-found

# Delete S3 Secrets
kubectl delete secret registry-storage -n gitlab --ignore-not-found
kubectl delete secret object-storage -n gitlab --ignore-not-found
kubectl delete secret s3cmd-config -n gitlab --ignore-not-found

# Uninstall Gitlab with Helm
helm uninstall gitlab --namespace gitlab

# Delete Kubernetes Namespace for Gitlab
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/gitlab-ee/gitaly
sudo rm -rf $HOME/KX_Data/gitlab-ee/postgres
sudo rm -rf $HOME/KX_Data/gitlab-ee/redis

# Delete desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Gitlab EE"
