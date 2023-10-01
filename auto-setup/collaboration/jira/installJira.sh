#!/bin/bash

# Add regcred secret to Jio Jira namespace
createK8sCredentialSecretForCoreRegistry

# Deploy Jira YMAL files
deployYamlFilesToKubernetes
