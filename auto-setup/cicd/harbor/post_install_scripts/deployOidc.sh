#!/bin/bash -eux

# Settings on Keycloak for SSO 
export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

## create a clients
kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli} create clients --realm ${kcRealm} -s clientId=${componentName} \
-s 'redirectUris=["https://'${componentName}'.'${baseDomain}'/auth/callback"]' \
-s publicClient="false" -s enabled=true -s rootUrl="https://'${componentName}'.'${baseDomain}'" -s baseUrl="/applications" -i 

## export clientId
export clientID=$(kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  get clients --fields id,clientId | jq -r '.[] | select(.clientId=="harbor") | .id')

# export client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} get clients/$clientID/client-secret | jq -r '.value')

## create client scopes
kubectl -n keycloak exec keycloak-0 --container keycloak -- \
${kcAdmCli}  create -x client-scopes -s name=${componentName} -s protocol=openid-connect

## export the client scope id
export clientscopeID=$(kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  get -x client-scopes | jq -r '.[] | select(.name=="harbor") | .id')

## client scope protocol mapper 
kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  create client-scopes/$clientscopeID/protocol-mappers/models \
-s name=groups \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-group-membership-mapper \
  -s 'config."claim.name"=groups' \
  -s 'config."access.token.claim"=true' \
  -s 'config."jsonType.label"=String'

## map the above client scope id to the client 
kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  update clients/$clientID/default-client-scopes/$clientscopeID