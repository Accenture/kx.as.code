#!/bin/bash -x

# Create Keycloak Client
redirectUris="https://gitlab.${baseDomain}/users/auth/openid_connect/callback"
rootUrl="https://gitlab.${baseDomain}"
baseUrl="/"
export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")

# Get Keycloak Client Secret
export clientSecret=$(getKeycloakClientSecret "${clientId}")

################### Kubernetes manifests CRUD operations #####################################

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

# Check if SSO provider already exists, else create it
kubectl get secret sso-provider --namespace=${namespace} || \
  kubectl create secret generic sso-provider --namespace=${namespace} --from-file=provider=${installationWorkspace}/gitlab-sso-providers.yaml
