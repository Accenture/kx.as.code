#!/bin/bash
set -euo pipefail

# Replace variables
envhandlebars < ${installComponentDirectory}/deployment_yaml/install.yaml > ${installationWorkspace}/${componentName}_install.yaml

# Install Elastic Heartbeat
kubectl apply -f ${installationWorkspace}/${componentName}_install.yaml -n ${namespace}
