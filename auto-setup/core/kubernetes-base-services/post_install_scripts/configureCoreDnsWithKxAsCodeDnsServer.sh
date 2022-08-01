#!/bin/bash
set -euo pipefail

# Enable DNS resolution in Kubernetes for *.${baseDomain} domain

# Wait for Config Map to become available
waitForKubernetesResource "coredns" "configmap" "kube-system"

# Get existing config-map
kubectl get cm -n kube-system coredns -o yaml | /usr/bin/sudo tee ${installationWorkspace}/coredns.yaml

# Update exported YAML file with external DNS server (bind9 instance installed on KX-Main1)
/usr/bin/sudo sed -i -e '/^        loadbalance/{:a; N; /\n    }/!ba; a \    '${baseDomain}':53 {\n        errors\n        cache 30\n        forward . '${mainIpAddress}'\n    }' -e '}' ${installationWorkspace}/coredns.yaml

# Validate and apply the updated config-map
kubernetesApplyYamlFile "${installationWorkspace}/coredns.yaml" "kube-system"

