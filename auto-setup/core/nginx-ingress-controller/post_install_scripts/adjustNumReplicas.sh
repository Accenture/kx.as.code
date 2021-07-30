#!/bin/bash -x
set -euo pipefail

# Increase number of replicas to match number of KX-Main nodes
numK8sMasterNodes=$(kubectl get nodes -l node-role.kubernetes.io/master= -o json | jq -r '.items | length')
nginxDeploymentName=$(kubectl get deployments -n ${namespace} -o json | jq -r '.items[].metadata.name')
/usr/bin/sudo kubectl -n ${namespace} scale --replicas=${numK8sMasterNodes} deployment/${nginxDeploymentName}
/usr/bin/sudo kubectl -n ${namespace} get pod -o wide