#!/bin/bash -eux

# Create namespace if it does not already exist
if [ "$(kubectl get namespace minio-s3 --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for MinIO
  kubectl create namespace minio-s3
fi

# Set variables for both MinIO and Docker Registry
export MINIOS3_ACCESS_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
export MINIOS3_SECRET_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

# Create MinIO secrets
kubectl create secret generic minio-accesskey-secret \
    --from-literal=accesskey=${MINIOS3_ACCESS_KEY} \
    --from-literal=secretkey=${MINIOS3_SECRET_KEY} \
    --namespace minio-s3

# Add and update MinIO helm chart
helm repo add minio https://helm.min.io/
helm repo update

# Install MinIO S3
helm upgrade --install minios3 minio/minio \
    --set 'persistence.enabled=true' \
    --set 'persistence.storageClass=gluster-heketi' \
    --set 'persistence.size=10Gi' \
    --set 'persistence.accessMode=ReadWriteOnce' \
    --set 'existingSecret=minio-accesskey-secret' \
    --set 'ingress.enabled=true' \
    --set 'ingress.hosts[0]=s3.kx-as-code.local' \
    --set 'ingress.tls[0].hosts[0]=s3.kx-as-code.local' \
    --set ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"="1000m" \
    --set 'mode=standalone' \
    --set 'service.type=ClusterIP' \
    --set 'environment.MINIO_REGION=eu-central-1' \
    --namespace minio-s3

# Add the following line(s) to the above if you want to automatically create bucket(S) with the helm install
#     --set 'buckets[0].name='<Bucket Name>',buckets[0].policy=none,buckets[0].purge=false' \

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="MinIO S3" \
  --url=https://s3.kx-as-code.local/minio/health/ready \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/08_Storage/01_MinIO/minio.png
