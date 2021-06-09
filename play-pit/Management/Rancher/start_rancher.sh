#!/bin/bash -x
set -euo pipefail
# Add rancher-stable repo in helm
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# Create namespace cattle-system for rancher
kubectl create namespace cattle-system
# Install rancher with single replica in previously created namespace
# Setting hostname helps rancher detect right url to access it
helm install rancher rancher-stable/rancher --namespace cattle-system  --set replicas=1 --set hostname="z2h-kx-as-code"
