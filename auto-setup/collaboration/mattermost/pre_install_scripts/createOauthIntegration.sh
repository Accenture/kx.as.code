#!/bin/bash -x
set -euo pipefail

### DEPRECATED IN FAVOR OF KEYCLOAK

# TODO - Implement Keycloak integration

# Create application to facilitate Gitlab as OAUTH provider for Mattermost
export mattermostApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="Mattermost") | .id')
if [[ -z ${mattermostApplicationId} ]]; then
    for i in {1..5}; do
        curl -s --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" \
            --data "name=Mattermost&redirect_uri=https://${componentName}.${baseDomain}/login/gitlab/complete,https://${componentName}.${baseDomain}/signup/gitlab/complete&scopes=" \
            "${gitUrl}/api/v4/applications" | /usr/bin/sudo tee ${installationWorkspace}/mattermost_gitlab_integration.json
        export mattermostApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="Mattermost") | .id')
        if [[ -n ${mattermostApplicationId} ]]; then break; else
            echo "Mattermost application was not created in Gitlab. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "Gitlab OAUTH application for Mattermost already exists. Skipping it's creation"
fi
export mattermostGitIntegrationSecret=$(cat ${installationWorkspace}/mattermost_gitlab_integration.json | jq -r '.secret')
export mattermostGitIntegrationId=$(cat ${installationWorkspace}/mattermost_gitlab_integration.json | jq -r '.application_id')
