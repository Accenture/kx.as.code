#!/bin/bash

# Add regcred secret to TeamCity namespace
createK8sCredentialSecretForCoreRegistry

# Deploy TeamCity YMAL files
deployYamlFilesToKubernetes
