#!/bin/bash -x
set -euo pipefail

if [[ "${sslProvider}" == "letsencrypt" ]]; then

  if [[ "${letsEncryptEnvironment}" == "staging" ]]; then
    letsEncryptUrl="https://acme-staging-v02.api.letsencrypt.org/directory"
  elif [[ "${letsEncryptEnvironment}" == "prod" ]]; then
    letsEncryptUrl="https://acme-v02.api.letsencrypt.org/directory"
  else
    log_warn "Property value \"${letsEncryptEnvironment}\" for \"letsEncryptEnvironment\" not recognized. Values must be \"prod\" or \"staging\" Please correct your profile-config.json properties file and try again"
    log_info "Will proceed without setting up the letsEncrypt cluster issuer"
    exit 0
  fi

  # Install LetsEncrypt SSL issuer
  if [[ -n "${sslDomainAdminEmail}" ]]; then
  echo '''
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
   name: letsencrypt-'${letsEncryptEnvironment}'
  spec:
   acme:
     # The ACME server URL
     server: '${letsEncryptUrl}'
     # Email address used for ACME registration
     email: '${sslDomainAdminEmail}'
     # Name of a secret used to store the ACME account private key
     privateKeySecretRef:
       name: letsencrypt-'${letsEncryptEnvironment}'
     # Enable the HTTP-01 challenge provider
     solvers:
     - http01:
         ingress:
           class:  nginx
  ''' | sudo tee ${installationWorkspace}/letsencrypt-issuer.yaml
  kubectl apply -f ${installationWorkspace}/letsencrypt-issuer.yaml
  else
    log_warn "sslDomainAdminEmail property not set in profile-config.json. Skipping setting up LetsEncrypt issuer for Cert-Manager"
  fi
fi