#!/bin/bash

# Get MinIO Kubernetes Operator
/usr/bin/sudo wget https://github.com/minio/operator/releases/download/v${operatorVersion}/kubectl-minio_${operatorVersion}_linux_amd64 -O kubectl-minio
/usr/bin/sudo chmod +x kubectl-minio
/usr/bin/sudo mv kubectl-minio /usr/local/bin/

# Check version
kubectl minio version

# Deploy MinIO-S3 ingress YAML file
deployYamlFilesToKubernetes

# Initialize Minio-S3 Operator
kubectl minio init --namespace ${namespace}

# Patch Operator Deployment if single node KX.AS.CODE setup
if [[ -z $(kubectl get nodes | grep "kx-worker") ]]; then

# Create patch file to remove node anti-affinity
echo '''apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio-operator
  namespace: '${namespace}'
spec:
  template:
    spec:
      affinity:
''' | /usr/bin/sudo tee ${installationWorkspace}/minio-operator-deployment-patch.yaml

# Apply patch
kubectl patch deployment minio-operator -n ${namespace} --patch-file ${installationWorkspace}/minio-operator-deployment-patch.yaml

# Re-deploy with anti-affinity removed and reduce number of replicas to 1
kubectl scale deployment minio-operator --replicas=0 -n ${namespace}
sleep 5
kubectl scale deployment minio-operator --replicas=1 -n ${namespace}

fi