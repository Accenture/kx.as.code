#!/bin/bash -x
set -euo pipefail

# Create the required diretories for the persistent volumes
#./createVolumeDirectories.sh

# Create namesace if it does not already exist
if [ "$(kubectl get namespace gitlab-ce --template={{.status.phase}})" != "Active" ]; then
    # Create Kubernetes Namespace for Gitlab
    kubectl create namespace gitlab-ce
fi

# Apply the Gitlab configuration files
#kubectl create --dry-run=client -o yaml --namespace gitlab-ce \
#  -f ingress.yaml | kubectl apply -f -

# Get NGINX Ingress Controller IP
NGINX_INGRESS_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n kube-system -o jsonpath={.spec.clusterIP})
MINIO_ACCESS_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)

echo """
provider: AWS
region: eu-central-1
aws_access_key_id: ${MINIO_ACCESS_KEY}
aws_secret_access_key: ${MINIO_SECRET_KEY}
aws_signature_version: 4
host: s3.kx-as-code.local
endpoint: "http://minio-service:9000"
path_style: true
""" | tee rails.minio.yaml

echo """
s3:
  aws_signature_version: 4
  host: s3.kx-as-code.local
  endpoint: "http://minio-service:9000"
  path_style: true
  region: eu-central-1
  regionendpoint: "http://minio-service:9000"
  bucket: gitlab-registry-storage
  accesskey: ${MINIO_ACCESS_KEY}
  secretkey: ${MINIO_SECRET_KEY}
  chunksize: 5242880
""" | tee registry.minio.yaml

# Install S3 Secrets
kubectl create secret generic registry-storage --dry-run=client -o yaml --from-file=config=registry.minio.yaml -n gitlab-ce | kubectl apply -f -
kubectl create secret generic object-storage --dry-run=client -o yaml --from-file=connection=rails.minio.yaml -n gitlab-ce | kubectl apply -f -
kubectl create secret generic s3cmd-config --dry-run=client -o yaml --from-file=config=rails.minio.yaml -n gitlab-ce | kubectl apply -f -

#echo -n 'Z64xynM9hmNWPRuVzfhy' > ./password.txt
#kubectl create secret generic gitlab-email-secret --from-file=password=./password.txt -n gitlab-ce

# Setup Gitlab Helm Repository
helm repo add gitlab https://charts.gitlab.io/
helm repo update

echo '''
gitlab:
  gitaly:
    persistence:
      storageClass: gluster-heketi
      size:   10Gi
postgresql:
  persistence:
    storageClass: gluster-heketi
    size: 5Gi
redis:
  master:
    persistence:
      storageClass: gluster-heketi
      size: 5Gi
''' | tee gitbal-ce-storage.yaml

# Install Gitlab with Helm
helm upgrade --install gitlab-ce gitlab/gitlab \
    --set global.hosts.domain=kx-as-code.local \
    --set global.hosts.externalIP=$NGINX_INGRESS_IP \
    --set global.edition=ce \
    --set global.prometheus.install=false \
    --set global.gitlab-runner.install=true \
    --set global.ingress.enabled=false \
    --set nginx-ingress.enabled=false \
    --set global.certmanager.install=false \
    --set certmanager.install=false \
    --set global.ingress.configureCertmanager=false \
    --set global.hosts.https=false \
    --set global.minio.enabled=false \
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
    --namespace gitlab-ce \
    -f gitbal-ce-storage.yaml
