#! /bin/bash

# Integrate solution with Keycloak
redirectUris="https://${componentName}.${baseDomain}/login/generic_oauth"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/login/generic_oauth"
protocol="openid-connect"
fullPath="true"
scopes="groups" # space separated if multiple scopes need to be created/associated with the client
enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
