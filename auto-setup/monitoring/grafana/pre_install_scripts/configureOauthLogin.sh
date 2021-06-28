#! /bin/bash

# set env. variables
export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# set credential token in new Realm
kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

# create client
clientID=$(kubectl -n keycloak exec ${kcPod}  -- \
  ${kcAdmCli} create clients --realm ${kcRealm} \
  -s clientId=${componentName} \
  -s 'redirectUris=["https://'${componentName}'.'${baseDomain}'/login/generic_oauth"]' \
  -s baseUrl="/login/generic_oauth" \
  -s rootUrl="https://'${componentName}'.'${baseDomain}'" \
  -s publicClient="false" \
  -s protocol="openid-connect" \
  -s enabled=true -i)

# export clientID
export clientID=$(kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  get clients --fields id,clientId | jq -r '.[] | select(.clientId=="grafana") | .id')

# export client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} get clients/$clientID/client-secret | jq -r '.value')

# create user group protocol mapper
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
  ${kcAdmCli} create clients/${clientId}/protocol-mappers/models \
  --realm ${kcRealm} \
  -s "name=groups" \
  -s "protocol=openid-connect" \
  -s "protocolMapper=oidc-group-membership-mapper" \
  -s 'config."claim.name"=groups' \
  -s 'config."access.token.claim"=true' \
  -s 'config."userinfo.token.claim"=true' \
  -s 'config."id.token.claim"=true' \
  -s 'config."full.path"=true' \
  -s 'config."jsonType.label"=String'