#!/bin/bash
set -euo pipefail

# Create CA config map for connecting to LDAPS from Keycloak for User Federation
echo """
kind: ConfigMap
apiVersion: v1
metadata:
  name: openldap-ca-certificate
  namespace: ${namespace}
data:
  ca.crt: |-
    $(/usr/bin/sudo cat /etc/ldap/sasl2/ca.crt | sed '2,30s/^/    /')
""" | /usr/bin/sudo tee ${installationWorkspace}/keycloak-ca-configmap.yaml

/usr/bin/sudo kubectl apply -f ${installationWorkspace}/keycloak-ca-configmap.yaml
