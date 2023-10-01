#!/bin/bash

# Create application to facilitate Gitlab as OAUTH provider for SonarQube
export sonarqubeApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="SonarQube") | .id')
if [[ -z ${sonarqubeApplicationId} ]]; then
    for i in {1..5}; do
        curl -s --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" \
            --data "name=SonarQube&redirect_uri=${componentName}.${baseDomain}/oauth2/callback/gitlab&scopes=read_user" \
            "${gitUrl}/api/v4/applications" | /usr/bin/sudo tee ${installationWorkspace}/sonarqube_gitlab_integration.json
        export sonarqubeApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="SonarQube") | .id')
        if [[ -n ${sonarqubeApplicationId} ]]; then break; else
            echo "SonarQube application was not created in Gitlab. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "Gitlab OAUTH application for SonarQube already exists. Skipping it's creation"
fi
export sonarqubeGitIntegrationSecret=$(cat ${installationWorkspace}/sonarqube_gitlab_integration.json | jq -r '.secret')
export sonarqubeGitIntegrationId=$(cat ${installationWorkspace}/sonarqube_gitlab_integration.json | jq -r '.application_id')
