#!/bin/bash
set -euo pipefail

export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Create application to facilitate Gitlab as OAUTH provider for SonarQube
export sonarQubeApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="SonarQube") | .id')
if [[ -z ${sonarQubeApplicationId} ]]; then
    for i in {1..5}; do
        curl -s --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" \
            --data "name=SonarQube&redirect_uri=https://${componentName}.${baseDomain}/oauth2/callback/gitlab&scopes=read_user" \
            "${gitUrl}/api/v4/applications" | /usr/bin/sudo tee ${installationWorkspace}/sonarqube_gitlab_integration.json
        export sonarQubeApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="SonarQube") | .id')
        if [[ -n ${sonarQubeApplicationId} ]]; then break; else
            echo "SonarQube application was not created in Gitlab. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "Gitlab OAUTH application for SonarQube already exists. Skipping it's creation"
fi
export gitIntegrationSecret=$(cat ${installationWorkspace}/sonarqube_gitlab_integration.json | jq -r '.secret')
export gitIntegrationId=$(cat ${installationWorkspace}/sonarqube_gitlab_integration.json | jq -r '.application_id')
