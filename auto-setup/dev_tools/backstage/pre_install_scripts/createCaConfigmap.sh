#!/bin/bash

# Create CA configmap
kubectl create configmap {{componentName}}-backstage-postgres-ca --from-file=${installationWorkspace}/kx-certs/ca.crt -n {{namespace}}
