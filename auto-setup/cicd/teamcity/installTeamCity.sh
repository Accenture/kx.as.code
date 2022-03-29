#!/bin/bash
set -euox pipefail

# Add regcred secret to TeamCity namespace
createK8sCredentialSecretForCoreRegistry

# Deploy TeamCity YMAL files
deployYamlFilesToKubernetes
