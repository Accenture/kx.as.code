#!/bin/bash -x

# Create CA config map for connecting to LDAPS from Keycloak for User Federation
echo """
kind: ConfigMap
apiVersion: v1
metadata:
  name: openldap-ca-certificate
  namespace: ${namespace}
data:
  ca.crt: |-
    $(sudo cat /etc/ldap/sasl2/ca.crt | sed '2,30s/^/    /')
""" | sudo tee ${installationWorkspace}/keycload-ca-configmap.yaml

sudo kubectl apply -f ${installationWorkspace}/keycload-ca-configmap.yaml