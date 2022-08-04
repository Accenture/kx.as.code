#!/bin/bash
set -euo pipefail

# Only install separately if target orchestrator is K8s, because K3s already installs the metric server as standard
if [[ "${kubeOrchestrator}" == "k8s" ]]; then
    # Install Kubernetes Metrics server
    curl -L -o ${installationWorkspace}/metric-server-components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/${metricsServerVersion}/components.yaml
    sed -i '/^        - --secure-port=443/a \        - --kubelet-insecure-tls' ${installationWorkspace}/metric-server-components.yaml
    kubectl apply -f ${installationWorkspace}/metric-server-components.yaml --namespace=kube-system
fi