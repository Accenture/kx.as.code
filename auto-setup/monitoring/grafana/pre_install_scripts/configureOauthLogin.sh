#! /bin/bash -x

# Integrate solution with Keycloak
redirectUris="https://${componentName}.${baseDomain}/login/generic_oauth"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/login/generic_oauth"
protocol="openid-connect"
fullPath="true"
enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}"

