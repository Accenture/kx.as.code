#! /bin/bash

# Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
enableKeycloakSSOForSolution "https://${componentName}.${baseDomain}/login/generic_oauth" \
  "https://${componentName}.${baseDomain}"
