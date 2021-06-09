#!/bin/bash -eux

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
   "oidc_endpoint":"https://keycloak.demo1.kx-as-code.local/auth/realms/demo1.kx-as-code.local",
   "oidc_client_id":"Harbor", 
   "oidc_client_secret":"eceaf2b6-5e5c-46d9-b322-2bcb23a107ab", 
   "oidc_scope":"openid,profile,email,offline_access", 
   "oidc_groups_claim":"groups", 
   "oidc_verify_cert": "false"
   "oidc_auto_onboard":"true", 
   "oidc_user_claim":"preferred_username"
   }')
   if [[ ${harborAuthModeResp} -eq 200 ]] ;
   then
      echo "Successfully created oidc configuration"
   else echo  "Unable to create configuration"
   fi
 else echo "Harbor oidc configuration already exists. Skipping creation"
fi

# Test the oidc configuration 
export harborOidcPingRes=$(curl -u 'admin:'${vmPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/system/oidc/ping" -H "accept: application/json" -H "Content-Type: application/json" -d '
{ "url":"https://keycloak.demo1.kx-as-code.local/auth/realms/demo1.kx-as-code.local", 
  "verify_cert":false
}' )
if [[ ${harborOidcPingRes} -eq 200 ]] ||  [[ ${harborOidcPingRes} = '' ]] ; 
then
    echo  "OIDC Test Connection Successful"
else echo  "Fail to Connect"
fi