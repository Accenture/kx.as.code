#!/bin/bash -eux

# Integrate solution with Keycloak
redirectUris="https://${componentName}.${baseDomain}/signup/gitlab/complete"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/applications"
protocol="openid-connect"
fullPath="false"
scopes="${componentName}" # space separated if multiple scopes need to be created/associated with the client
enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"