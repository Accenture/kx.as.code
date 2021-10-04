#! /bin/bash -x

# Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
export clientId=$(createKeycloakClient "https://${componentName}.${baseDomain}/login/generic_oauth" \
  "https://${componentName}.${baseDomain}")

# Get Keycloak Client Secret
export clientSecret=$(getKeycloakClientSecret "${clientId}")

# Create Keycloak Client Scopes
export clientscopeId=$(createKeyCloakClientScope "openid-connect")

# Create Keycloak Protocol Mapper
createKeycloakProtocolMapper "${clientId}" "${clientScopeId}"
