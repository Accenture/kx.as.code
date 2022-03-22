#!/bin/bash
set -euox pipefail

# Create password
export defaultRegistryUserPassword=$(managedApiKey "docker-registry-${vmUser}-password")

# Generate HTPASSWD file
apt-get install -y apache2-utils
htpasswd -Bb -c ${installationWorkspace}/docker-registry-htpasswd ${vmUser} ${defaultRegistryUserPassword}

# Add KX.AS.CODE HTPASSWD secret to Docker Registry namespace
kubectl get secret docker-registry-default-htpasswd --namespace=${namespace} ||
    kubectl create secret generic docker-registry-default-htpasswd \
        --from-file=${installationWorkspace}/docker-registry-htpasswd \
        --namespace=${namespace}