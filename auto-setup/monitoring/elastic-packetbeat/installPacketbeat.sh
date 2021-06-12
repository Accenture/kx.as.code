#!/bin/bash -eux

# Replace variables
envhandlebars < ${installComponentDirectory}/deployment_yaml/install.yaml > ${installationWorkspace}/${componentName}_install.yaml

# Install Elastic Packetbeat
kubectl apply -f ${installationWorkspace}/${componentName}_install.yaml -n ${namespace}