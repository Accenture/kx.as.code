#!/bin/bash -x
set -euo pipefail

# Ensure Kubernetes is available before proceeding to the next step
timeout -s TERM 600 bash -c \
    'while [[ "$(curl -s -k https://localhost:6443/livez)" != "ok" ]];\
do sleep 5;\
done'

# Get Keycloak POD name for subsequent Keycloak CLI commands
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n ${namespace} --output=json | jq -r '.items[].metadata.name')

# Login to master realm
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- /opt/jboss/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password ${vmPassword} --client admin-cli

# Activate OTP as default requirements
export realmId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- /opt/jboss/keycloak/bin/kcadm.sh get realms | jq -r '.[] | select(.realm=="'${baseDomain}'") | .id')

# Substitute placeholders
envhandlebars < ${installComponentDirectory}/realmUpdate.json > ${installationWorkspace}/realmUpdate.json

# Import updated realm json
# TODO: Figure out why this docker command no longer works
docker run \
    -e KEYCLOAK_URL=https://${componentName}.${baseDomain}/auth \
    -e KEYCLOAK_USER=admin \
    -e KEYCLOAK_LOGINREALM=${baseDomain} \
    -e KEYCLOAK_PASSWORD=${vmPassword} \
    -e KEYCLOAK_AVAILABILITYCHECK_ENABLED=true \
    -e KEYCLOAK_AVAILABILITYCHECK_TIMEOUT=120s \
    -e IMPORT_PATH=/config/realmUpdate.json \
    -e IMPORT_FORCE=false \
    -e KEYCLOAK_SSLVERIFY=false \
    -v ${installationWorkspace}/realmUpdate.json:/config/realmUpdate.json \
    adorsys/keycloak-config-cli:latest || true
