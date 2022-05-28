#!/bin/bash -eux

 if [[ -n "${kcPod}" ]]; then
    # Integrate solution with Keycloak
    redirectUris="https://${componentName}.${baseDomain}/signup/gitlab/complete"
    rootUrl="https://${componentName}.${baseDomain}"
    baseUrl="/applications"
    protocol="openid-connect"
    fullPath="false"
    scopes="${componentName}" # space separated if multiple scopes need to be created/associated with the client
    enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
else
    # Since Keycloak is not installed, remove Keycloak settings before proceeding with Helm install, which
    # would fail otherwise
    log_info "Keycloak not installed. Removing Keycloak configuration from Mattermost, else Helm install will fail"
    /usr/bin/sudo sed -i '/MM_GITLABSETTINGS/d' ${installComponentDirectory}/mattermost_values.yaml
fi