#!/bin/bash -eux

# Install Kubernetes Metrics server
curl -L -o ${installationWorkspace}/metric-server-components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
sed -i '/^          - --secure-port=4443*/a \          - --kubelet-preferred-address-types=InternalIP\n          - --kubelet-insecure-tls' ${installationWorkspace}/metric-server-components.yaml
kubectl apply -f ${installationWorkspace}/metric-server-components.yaml --namespace=kube-system
