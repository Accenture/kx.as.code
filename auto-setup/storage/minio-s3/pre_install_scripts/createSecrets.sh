#!/bin/bash -eux

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-s3 --output=name --field-selector metadata.name=minio-accesskey-secret) ]
then
  # Create MinIO Access Key secret
  export MINIOS3_ACCESS_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
  export MINIOS3_SECRET_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
  kubectl create secret generic minio-accesskey-secret \
      --from-literal=accesskey=${MINIOS3_ACCESS_KEY} \
      --from-literal=secretkey=${MINIOS3_SECRET_KEY} \
      --namespace minio-s3
fi
