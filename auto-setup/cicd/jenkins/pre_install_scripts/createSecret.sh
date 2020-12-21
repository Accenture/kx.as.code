#!/bin/bash -eux

# Create secret if it does not exist
kubectl get secret jenkins-admin-secret --namespace ${namespace} || \
kubectl create secret generic jenkins-admin-secret \
      --from-literal=jenkins-admin-user=admin \
      --from-literal=jenkins-admin-password=${vmPassword} \
      --namespace ${namespace}
