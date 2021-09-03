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
    -s 'redirectUris=["https://gitlab.'${baseDomain}'/users/auth/openid_connect/callback"]' \
    -s publicClient="false" -s enabled=true -s rootUrl="https://gitlab.${baseDomain}" -s baseUrl="/" -i

## export clientId
export clientId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients --fields id,clientId | jq -r '.[] | select(.clientId=="gitlab-ce") | .id')

# Get client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# If secret not available, generate a new one
if [[ "${clientSecret}" == "null" ]]; then
  kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} create clients/${clientId}/client-secret | jq -r '.value'
  clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')
fi

################### kubernetes manifests CRUD operations #####################################

echo '''
{
  "name": "openid_connect",
  "label": "Keycloak",
  "args": {
    "name": "openid_connect",
    "scope": ["openid","profile","email"],
    "response_type": "code",
    "issuer": "https://keycloak.'${baseDomain}'/auth/realms/'${baseDomain}'",
    "discovery": true,
    "client_auth_method": "query",
    "send_scope_to_token_endpoint": false,
    "user_response_structure": {
      "id_path": "preferred_username",
      "attributes": {  "nickname":  "preferred_username"  }
    },
    "client_options": {
      "identifier": "gitlab-ce",
      "secret": "'${clientSecret}'",
      "redirect_uri": "https://gitlab.'${baseDomain}'/users/auth/openid_connect/callback"
    }
  }
}
''' | /usr/bin/sudo tee ${installationWorkspace}/gitlab-sso-providers.yaml
kubectl create secret generic sso-provider --namespace=${componentName} --from-file=provider=${installationWorkspace}/gitlab-sso-providers.yaml
