#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

### Install Key Cloak IAM

# Create namespace
kubectl create namespace keycloak

# Add Keycloak Helm Chart
helm repo add codecentric https://codecentric.github.io/helm-charts
helm install keycloak codecentric/keycloak

# Define Postgresql Password
POSTGRESQL_PASSWORD=$(pwgen -1s 32)

# Create Helm values file
echo """
ingress:
  enabled: true
  servicePort: http
  rules:
    -
      host: 'keycloak.kx-as-code.local'
      paths:
        - /

  tls:
    - hosts:
        - keycloak.kx-as-code.local
postgresql:
  enabled: true
  postgresqlUsername: keycloak
  postgresqlPassword: ${POSTGRESQL_PASSWORD}
  postgresqlDatabase: keycloak
  global:
    persistence:
        enabled: true
        storageClass: local-storage
        size: 1Gi

extraEnv: |
   - name: PROXY_ADDRESS_FORWARDING
     value: \"true\"
   - name: KEYCLOAK_LOGLEVEL
     value: \"DEBUG\"
   - name: KEYCLOAK_USER
     value: \"admin\"
   - name: KEYCLOAK_PASSWORD
     value: \"${VM_PASSWORD}\"
""" | tee $KUBEDIR/kloak-values.yaml

# Install Keycloack
helm upgrade --install keycloak \
    codecentric/keycloak \
    -f $KUBEDIR/kloak-values.yaml \
    -n keycloak
