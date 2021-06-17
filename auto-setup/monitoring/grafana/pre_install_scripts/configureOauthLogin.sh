#! /bin/bash -eux
#ToDo
# creat role, Add user to role
export componentName=grafana
export baseDomain=kx-as-code.local
export namespace=keycloak
#defining env variables
export rediectUri="https://'${componentName}'.'${baseDomain}'/login/generic_oauth"
export rootUri="https://'${componentName}'.'${baseDomain}'" 
export baseUrl="/login/generic_oauth"
export solution=grafana-test
export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')
export vmPassword=L3arnandshare

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

# Create Client
clientId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
  ${kcAdmCli} create clients --realm ${kcRealm} \
  -s clientId=${solution} \
  -s redirectUris="${rediectUri}" \
  -s baseUrl=${baseUrl} \
  -s rootUrl=${rootUri} \
  -s publicClient="false" \
  -s protocol=openid-connect \
  -s accessType=confidential \
  -s enabled=true -i)

## export clientId
export clientID=$(kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  get clients --fields id,clientId | jq -r '.[] | select(.clientId=="grafana-test") | .id')

# export client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} get clients/$clientID/client-secret | jq -r '.value')

# Create protocol mapper
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
  ${kcAdmCli} create clients/${clientId}/protocol-mappers/models \
  --realm ${kcRealm} \
  -s name=roles \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-usermodel-client-role-mapper \
  -s 'config."claim.name"=roles' \
  -s clientID=$clientID \
  -s 'config."multivalued"=true' \
  -s 'config."jsonType.label"=String'

# Set credential token in new Realm
# kubectl -n keycloak exec ${kcPod} -- \
#   ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}


# ## create client scopes
# kubectl -n keycloak exec keycloak-0 --container keycloak -- \
# ${kcAdmCli}  create -x client-scopes -s name=${componentName} -s protocol=openid-connect

# ## export the client scope id
# export clientscopeID=$(kubectl -n keycloak exec ${kcPod} -- \
# ${kcAdmCli}  get -x client-scopes | jq -r '.[] | select(.name=="argocd") | .id')

# ## client scope protocol mapper 
# kubectl -n keycloak exec ${kcPod} -- \
# ${kcAdmCli}  create client-scopes/$clientscopeID/protocol-mappers/models \
# -s name=groups \
#   -s protocol=openid-connect \
#   -s protocolMapper=oidc-group-membership-mapper \
#   -s 'config."claim.name"=groups' \
#   -s 'config."access.token.claim"=true' \
#   -s 'config."jsonType.label"=String'

# ## map the above client scope id to the client 
# kubectl -n keycloak exec ${kcPod} -- \
# ${kcAdmCli}  update clients/$clientID/default-client-scopes/$clientscopeID
