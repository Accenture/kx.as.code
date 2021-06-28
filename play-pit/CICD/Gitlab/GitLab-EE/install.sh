#!/bin/bash -x
set -euo pipefail

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namesace if it does not already exist
if [ "$(kubectl get namespace gitlab --template={{.status.phase}})" != "Active" ]; then
    # Create Kubernetes Namespace for Gitlab
    kubectl create -f namespace.yaml
fi

# Apply the Gitlab configuration files
kubectl create --dry-run=client -o yaml --namespace gitlab \
    -f persistentVolumes.yaml \
    -f persistentVolumeClaims.yaml \
    -f ingress.yaml | kubectl apply -f -

# Install S3 Secrets
kubectl create secret generic registry-storage --dry-run=client -o yaml --from-file=config=registry.minio.yaml -n gitlab | kubectl apply -f -
kubectl create secret generic object-storage --dry-run=client -o yaml --from-file=connection=rails.minio.yaml -n gitlab | kubectl apply -f -
kubectl create secret generic s3cmd-config --dry-run=client -o yaml --from-file=config=rails.minio.yaml -n gitlab | kubectl apply -f -
# Get NGINX Ingress Controller IP
NGINX_INGRESS_IP=$(sudo -H -i -u $(id -u -n) sh -c "kubectl get svc nginx-ingress-controller -n kube-system -o jsonpath={.spec.clusterIP}")

# Setup Gitlab Helm Repository
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Install Gitlab with Helm
helm upgrade --install gitlab gitlab/gitlab \
    --set global.hosts.domain=kx-as-code.local \
    --set global.hosts.externalIP=$NGINX_INGRESS_IP \
    --set global.edition=ee \
    --set global.prometheus.install=false \
    --set global.ingress.enabled=false \
    --set global.certmanager.install=false \
    --set global.ingress.configureCertmanager=false \
    --set global.minio.enabled=false \
    --set global.hosts.https=false \
    --set registry.storage.secret=registry-storage \
    --set registry.storage.key=config \
    --set global.registry.bucket=gitlab-registry-storage \
    --set global.appConfig.lfs.bucket=gitlab-lfs-storage \
    --set global.appConfig.lfs.connection.secret=object-storage \
    --set global.appConfig.lfs.connection.key=connection \
    --set global.appConfig.artifacts.bucket=gitlab-artifacts-storage \
    --set global.appConfig.artifacts.connection.secret=object-storage \
    --set global.appConfig.artifacts.connection.key=connection \
    --set global.appConfig.uploads.connection.secret=object-storage \
    --set global.appConfig.uploads.bucket=gitlab-uploads-storage \
    --set global.appConfig.uploads.connection.key=connection \
    --set global.appConfig.packages.bucket=gitlab-packages-storage \
    --set global.appConfig.packages.connection.secret=object-storage \
    --set global.appConfig.packages.connection.key=connection \
    --set global.appConfig.externalDiffs.bucket=gitlab-externaldiffs-storage \
    --set global.appConfig.externalDiffs.connection.secret=object-storage \
    --set global.appConfig.externalDiffs.connection.key=connection \
    --set global.appConfig.pseudonymizer.bucket=gitlab-pseudonymizer-storage \
    --set global.appConfig.pseudonymizer.connection.secret=object-storage \
    --set global.appConfig.pseudonymizer.connection.key=connection \
    --namespace gitlab \
    -f values.yaml

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Gitlab EE" \
    --url=https://gitlab.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/02_Gitlab/GitLab-EE/gitlab.png
