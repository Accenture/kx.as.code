#!/bin/bash
set -euox pipefail

# Create InfluxDB2 admin password
export influxdb2AdminPassword=''$(managedPassword "influxdb2-admin-password" "influxdb2")''

# Create InfluxDB2 admin token
export influxdb2AdminToken=''$(managedPassword "influxdb2-admin-token" "influxdb2")''

# Create credentials secret
kubectl get secret influxdb-auth --namespace ${namespace} ||
    kubectl create secret generic influxdb-auth \
        --from-literal=admin-password="${influxdb2AdminPassword}" \
        --from-literal=admin-token="${influxdb2AdminToken}" \
        --namespace ${namespace}
