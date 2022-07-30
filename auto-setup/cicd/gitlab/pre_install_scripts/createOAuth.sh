#!/bin/bash

# Create Keycloak Client
redirectUris="https://${componentName}.${baseDomain}/users/auth/openid_connect/callback"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/"
export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")

# Get Keycloak Client Secret
export clientSecret=$(getKeycloakClientSecret "${clientId}")

################### Kubernetes manifests CRUD operations #####################################

if [[ -n ${clientId} ]] && [[ -n ${clientSecret} ]]; then

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
      "identifier": "'${componentName}'",
      "secret": "'${clientSecret}'",
      "redirect_uri": "https://'${componentName}'.'${baseDomain}'/users/auth/openid_connect/callback"
    }
  }
}
''' | /usr/bin/sudo tee ${installationWorkspace}/gitlab-sso-providers.yaml

  # Check if SSO provider already exists, else create it
  kubectl get secret sso-provider --namespace=${namespace} || \
    kubectl create secret generic sso-provider --namespace=${namespace} --from-file=provider=${installationWorkspace}/gitlab-sso-providers.yaml
else
    # Since Keycloak is not installed, remove Keycloak settings before proceeding with Helm install, which
    # would fail otherwise
    log_info "Keycloak not installed. Removing Keycloak SSO configuration from Gitlab, else Helm install will fail"
    /usr/bin/sudo sed -i '/global.appConfig.omniauth/d' ${installComponentDirectory}/metadata.json
    /usr/bin/sudo sed -i 's#\"global\.certificates\.customCAs\[2\]\.secret=server-crt\"\,#"global.certificates.customCAs[2].secret=server-crt"#g' ${installComponentDirectory}/metadata.json
fi