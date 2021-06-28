#! /bin/bash -eux

export componentName=grafana
export baseDomain=demo1.kx-as-code.local
#export namespace=keycloak
#defining env variables
export rediectUri="https://${componentName}.${baseDomain}/login/generic_oauth"
export rootUri="https://${componentName}.${baseDomain}" 
export baseUrl="/login/generic_oauth"
export solution=grafana
export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')
export vmPassword=L3arnandshare
export kcContainer=keycloak
 
#Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}


# Create Client
clientId=$(kubectl -n keycloak exec ${kcPod}  -- \
  ${kcAdmCli} create clients --realm ${kcRealm} \
  -s "clientId=${solution}" \
  -s 'redirectUris=["https://grafana.demo1.kx-as-code.local/login/generic_oauth"]' \
  -s "baseUrl=${baseUrl}" \
  -s "rootUrl=${rootUri}" \
  -s "publicClient=false" \
  -s "protocol=openid-connect" \
  -s "enabled=true" -i)

## export clientId
export clientID=$(kubectl -n keycloak exec ${kcPod} -- \
${kcAdmCli}  get clients --fields id,clientId | jq -r '.[] | select(.clientId=="grafana") | .id')

# export client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} get clients/$clientID/client-secret | jq -r '.value')


# Create protocol mapper
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
