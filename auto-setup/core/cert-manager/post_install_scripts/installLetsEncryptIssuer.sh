#!/bin/bash -x
set -euo pipefail

if [[ "${sslProvider}" == "letsencrypt" ]]; then

  if [[ "${letsEncryptEnvironment}" == "staging" ]]; then
    log_info "Property value \"${letsEncryptEnvironment}\" set for \"letsEncryptEnvironment\". Setting up Letsencrypt environment"
  elif [[ "${letsEncryptEnvironment}" == "prod" ]]; then
    log_info "Property value \"${letsEncryptEnvironment}\" set for \"letsEncryptEnvironment\". Setting up Letsencrypt environment"
  else
    log_warn "Property value \"${letsEncryptEnvironment}\" for \"letsEncryptEnvironment\" not recognized. Values must be \"prod\" or \"staging\" Please correct your profile-config.json properties file and try again"
    log_info "Will proceed without setting up the letsEncrypt cluster issuer"
    exit 0
  fi

  if [[ -n "${sslDomainAdminEmail}" ]]; then

  # Install Staging LetsEncrypt SSL issuer
  echo '''
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
   name: letsencrypt-staging
  spec:
   acme:
     # The ACME server URL
     server: https://acme-staging-v02.api.letsencrypt.org/directory
     # Email address used for ACME registration
     email: '${sslDomainAdminEmail}'
     # Name of a secret used to store the ACME account private key
     privateKeySecretRef:
       name: letsencrypt-staging
     # Enable the HTTP-01 challenge provider
     solvers:
     - http01:
         ingress:
           class:  nginx
  ''' | sudo tee ${installationWorkspace}/letsencrypt-staging-issuer.yaml
  kubectl apply -f ${installationWorkspace}/letsencrypt-staging-issuer.yaml

  # Install Production LetsEncrypt SSL issuer
  echo '''
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
   name: letsencrypt-prod
  spec:
   acme:
     # The ACME server URL
     server: https://acme-v02.api.letsencrypt.org/directory
     # Email address used for ACME registration
     email: '${sslDomainAdminEmail}'
     # Name of a secret used to store the ACME account private key
     privateKeySecretRef:
       name: letsencrypt-prod
     # Enable the HTTP-01 challenge provider
     solvers:
     - http01:
         ingress:
           class:  nginx
  ''' | sudo tee ${installationWorkspace}/letsencrypt-prod-issuer.yaml
  kubectl apply -f ${installationWorkspace}/letsencrypt-prod-issuer.yaml

  else
    log_warn "sslDomainAdminEmail property not set in profile-config.json. Skipping setting up LetsEncrypt issuer for Cert-Manager"
  fi
fi