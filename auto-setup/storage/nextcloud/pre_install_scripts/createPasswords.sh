#!/bin/bash

# Create and export password variable for later mustache substitution
export nextcloudAdminPassword=$(managedPassword "nextcloud-admin-password" "nextcloud")
export nextcloudPostgresqlPassword=$(managedPassword "nextcloud-postgresql-password" "nextcloud")

# Create DB user secret, else deployment fails
kubectl get secret nextcloud-db -n ${namespace} || \
    kubectl create secret generic nextcloud-db \
        --from-literal=db-username=nextcloud \
        -n ${namespace}
