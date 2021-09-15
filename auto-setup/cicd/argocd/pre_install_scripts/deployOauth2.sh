#!/bin/bash -x

export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')
export kcContainer="keycloak"

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

## Create client
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=${componentName} \
    -s 'redirectUris=["https://'${componentName}'.'${baseDomain}'/auth/callback"]' \
    -s publicClient="false" -s enabled=true -s rootUrl="https://${componentName}.${baseDomain}" -s baseUrl="/applications" -i

## export clientId
export clientId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients --fields id,clientId | jq -r '.[] | select(.clientId=="argocd") | .id')

# Get client secret
clientSecret=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# If secret not available, generate a new one
if [[ "${clientSecret}" == "null" ]]; then
  kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} create clients/${clientId}/client-secret | jq -r '.value'
  clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')
fi

## create client scopes
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} create -x client-scopes -s name=groups -s protocol=openid-connect

## export the client scope id
export clientscopeId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get -x client-scopes | jq -r '.[] | select(.name=="groups") | .id')

## client scope protocol mapper
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} create client-scopes/$clientscopeId/protocol-mappers/models \
    -s name=groups \
    -s protocol=openid-connect \
    -s protocolMapper=oidc-group-membership-mapper \
    -s 'config."claim.name"=groups' \
    -s 'config."access.token.claim"=true' \
    -s 'config."id.token.claim"=true' \
    -s 'config."userinfo.token.claim"=true' \
    -s 'config."full.path"=true' \
    -s 'config."jsonType.label"=String'

## map the above client scope id to the client
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} update clients/$clientId/default-client-scopes/$clientscopeId

## create a new group with name ArgoCDAdmins
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} create groups -r ${kcRealm} -b '{ "name": "ArgoCDAdmins" }'

## export user Id
export userId=$(kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} get users -r ${kcRealm} -q username=admin | jq -r '.[] |  .id')

## export group Id
export groupId=$(kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="ArgoCDAdmins") | .id')

## Add user admin to the ArgoCDAdmins group. If any new users are created then they should be added to ArgoCDAdmins group
kubectl -n keycloak exec ${kcPod} -- \
     ${kcAdmCli} update users/${userId}/groups/${groupId} -r ${kcRealm} -s realm=${kcRealm} \
     -s userId=${userId} -s groupId=${groupId} -n