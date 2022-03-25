#!/bin/bash
set -euox pipefail

# Add regcred secret to Confluence namespace
createK8sCredentialSecretForCoreRegistry

# Deploy Confluence YMAL files
deployYamlFilesToKubernetes
