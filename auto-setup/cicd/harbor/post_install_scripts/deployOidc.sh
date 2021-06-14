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
-s 'redirectUris=["https://'${componentName}'.'${kcRealm}'/c/oidc/callback"]' \
-s publicClient="false" -s enabled=true -s rootUrl="https://'${componentName}'.'${kcRealm}'" -s baseUrl="/applications" -i 

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

###################################################OIDC Configuration Harbor#########################################################

# Wait until API is available before continuing
 timeout -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' https://'${componentName}'.'${baseDomain}'/api/v2.0/projects)" != "200" ]]; do \
                             echo "Waiting for https://'${componentName}'.'${baseDomain}'/api/v2.0/projects"; sleep 5; done'

# get the configuration
export harborAuthMode=$(curl -u 'admin:'${vmPassword}'' -H "Content-Type: application/json" -X GET "https://${componentName}.${baseDomain}/api/v2.0/configurations" | jq -r '.auth_mode.value')
if [[ ${harborAuthMode} != "oidc_auth" ]];
then
# set the oidc configuration
   export harborAuthModeResp=$(curl -u 'admin:'${vmPassword}'' -X PUT "https://${componentName}.${baseDomain}/api/v2.0/configurations" -H "accept: application/json" -H "Content-Type: application/json" -d '{
   "auth_mode":"oidc_auth",
   "oidc_name":"Keycloak Auth",
   "oidc_endpoint":"https://keycloak.'${baseDomain}'/auth/realms/'${kcRealm}'",
   "oidc_client_id":"'${componentName}'",
   "oidc_client_secret":"'${clientSecret}'",
   "oidc_scope":"openid,profile,email,offline_access",
   "oidc_groups_claim":"groups",
   "oidc_verify_cert": "false",
   "oidc_auto_onboard":"true",
   "oidc_user_claim":"preferred_username"
   }')
   if [[ ${harborAuthModeResp} -eq 200 ]] || [[ ${harborOidcPingRes} = '' ]];
   then
      echo "Successfully created oidc configuration"
   else echo  "Unable to create configuration"
   fi
 else echo "Harbor oidc configuration already exists. Skipping creation"
fi

# Test the oidc configuration
export harborOidcPingRes=$(curl -u 'admin:'${vmPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/system/oidc/ping" -H "accept: application/json" -H "Content-Type: application/json" -d '
{ "url":"https://keycloak.'${baseDomain}'/auth/realms/'${kcRealm}'",
  "verify_cert":false
}' )
if [[ ${harborOidcPingRes} -eq 200 ]] ||  [[ ${harborOidcPingRes} = '' ]];
then
    echo  "OIDC Test Connection Successful"
else echo  "Fail to Connect"
fi
