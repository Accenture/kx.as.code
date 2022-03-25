#!/bin/bash
set -euox pipefail

# Add regcred secret to Nexus3 namespace
createK8sCredentialSecretForCoreRegistry

# Deploy Nexus3 YMAL files
deployYamlFilesToKubernetes
