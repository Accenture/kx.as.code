#!/bin/bash -x
set -euo pipefail

# Install Cilium
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/1.7.3/install/kubernetes/quick-install.yaml

# Test Connectivity
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/1.7.3/examples/kubernetes/connectivity-check/connectivity-check.yaml

git clone https://github.com/cilium/hubble.git
cd hubble/install/kubernetes

# Install Hubble UI
helm template hubble \
    --namespace kube-system \
    --set metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
    --set ui.enabled=true \
    > hubble.yaml

kubectl apply -f hubble.yaml
