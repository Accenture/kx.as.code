#!/bin/bash
set -euo pipefail

# Get number of KX-Main nodes
if [[ "${kubeOrchestrator}" == "k8s" ]]; then
    numK8sMasterNodes=$(kubectl get nodes -l node-role.kubernetes.io/master= -o json | jq -r '.items | length')
elif [[ "${kubeOrchestrator}" == "k3s" ]]; then
    numK8sMasterNodes=$(kubectl get nodes -l node-role.kubernetes.io/master -o json | jq -r '.items | length')
fi

# Increase number of replicas to match number of KX-Main nodes
if [[ ${numK8sMasterNodes} -gt 1 ]]; then
    nginxDeploymentName=$(kubectl get deployments -n ${namespace} -o json | jq -r '.items[].metadata.name')
    /usr/bin/sudo kubectl -n ${namespace} scale --replicas=${numK8sMasterNodes} deployment/${nginxDeploymentName}
    /usr/bin/sudo kubectl -n ${namespace} get pod -o wide
fi
