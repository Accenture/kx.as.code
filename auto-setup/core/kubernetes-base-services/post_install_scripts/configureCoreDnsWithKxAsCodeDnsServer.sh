#!/bin/bash
set -euo pipefail

# Enable DNS resolution in Kubernetes for *.${baseDomain} domain

# Wait for Config Map to become available
waitForKubernetesResource "coredns" "configmap" "kube-system"

# Get existing config-map
kubectl get cm -n kube-system coredns -o yaml >${installationWorkspace}/coredns.yaml

# Update exported YAML file with external DNS server (bind9 instance installed on KX-Main1)
sed -i -e '/^        loadbalance/{:a; N; /\n    }/!ba; a \    '${baseDomain}':53 {\n        errors\n        cache 30\n        forward . '${mainIpAddress}'\n    }' -e '}' ${installationWorkspace}/coredns.yaml

# Apply the updated config-map
kubectl apply -f ${installationWorkspace}/coredns.yaml -n kube-system
