#!/bin/bash
set -euox pipefail

# Download the Hipster Store manifest from Google
curl -o ${installationWorkspace}/kubernetes-manifests.yaml https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml

# Deploy the Hipster Store Manifest
kubernetesApplyYamlFile "${installationWorkspace}/kubernetes-manifests.yaml" "${namespace}"#

# Deploy additional Kubernetes resources in "deployment_yaml" folder, eg. ingress.yaml
deployYamlFilesToKubernetes
