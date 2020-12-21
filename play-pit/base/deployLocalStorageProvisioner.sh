#!/bin/bash

. /etc/environment
export VM_USER=$VM_USER
export KUBEDIR=/home/$VM_USER/Kubernetes

# Deploy local volume provisioner. To be used for databases etc
wget https://raw.githubusercontent.com/kubernetes-sigs/sig-storage-local-static-provisioner/master/deployment/kubernetes/example/default_example_provisioner_generated.yaml -O ${KUBEDIR}/local_storage_provisioner_install.yaml
sed -i 's/\/mnt\/fast-disks/\/mnt\/k8s_local_volumes/g' ${KUBEDIR}/local_storage_provisioner_install.yaml
sed -i 's/ext4/xfs/g' ${KUBEDIR}/local_storage_provisioner_install.yaml
sed -i 's/fast-disks/local-storage/g' ${KUBEDIR}/local_storage_provisioner_install.yaml
sed -i 's/namespace: default/namespace: kube-system/g' ${KUBEDIR}/local_storage_provisioner_install.yaml
kubectl create -f ${KUBEDIR}/local_storage_provisioner_install.yaml -n kube-system

# Provision Storage Class
echo '''
# Only create this for K8s 1.9+
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
# Supported policies: Delete, Retain
reclaimPolicy: Delete
''' | kubectl apply -f -
