#!/bin/bash

# Integrate solution with Keycloak
redirectUris="https://${componentName}.${baseDomain}/*"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/"
protocol="openid-connect"
fullPath="true"
scopes="groups" # space separated if multiple scopes need to be created/associated with the client
enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"

# Set variables for oauth-proxy
export cookieSecret=$(docker run --rm python:3 python -c 'import os,base64; print(base64.b64encode(os.urandom(16)).decode("ascii"))')
#pushPassword "oauth-proxy-cookie-secret" "${cookieSecret}" "${namespace}"
#export cookieSecret=$(managedApiKey "oauth-proxy-cookie-secret" "${namespace}")

# Create Secret for Kubernetes Dashboard Certificates
kubectl delete secret ${componentName}-ca-certificate --ignore-not-found=true  -n ${namespace}
kubectl create secret generic ${componentName}-ca-certificate --from-file=${installationWorkspace}/kx-certs -n ${namespace}

