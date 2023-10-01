#!/bin/bash

# Add regcred secret to Confluence namespace
createK8sCredentialSecretForCoreRegistry

# Deploy Confluence YMAL files
deployYamlFilesToKubernetes
