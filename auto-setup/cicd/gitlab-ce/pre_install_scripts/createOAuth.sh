#!/bin/bash -x

# Create client - $1 = redirectUris, $2 = rootUrl
export clientId=$(createKeycloakClient "https://gitlab.${baseDomain}/users/auth/openid_connect/callback" \
  "https://gitlab.${baseDomain}")

# Get client secret
export clientSecret=$(getKeycloakClientSecret "${clientId}")


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
