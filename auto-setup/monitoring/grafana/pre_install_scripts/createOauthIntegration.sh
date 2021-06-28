#!/bin/bash -x
set -euo pipefail

# Create application to facilitate Gitlab as OAUTH provider for Grafana
export grafanaApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="Grafana") | .id')
if [[ -z ${grafanaApplicationId} ]]; then
    for i in {1..5}; do
        curl -s --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" \
            --data "name=Grafana&redirect_uri=https://${componentName}.${baseDomain}/login/gitlab&scopes=read_user" \
            "${gitUrl}/api/v4/applications" | /usr/bin/sudo tee ${installationWorkspace}/grafana_gitlab_integration.json
        export grafanaApplicationId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/applications | jq '.[] | select(.application_name=="Grafana") | .id')
        if [[ -n ${grafanaApplicationId} ]]; then break; else
            echo "Grafana application was not created in Gitlab. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "Gitlab OAUTH application for Grafana already exists. Skipping it's creation"
fi
export grafanaGitIntegrationSecret=$(cat ${installationWorkspace}/grafana_gitlab_integration.json | jq -r '.secret')
export grafanaGitIntegrationId=$(cat ${installationWorkspace}/grafana_gitlab_integration.json | jq -r '.application_id')
