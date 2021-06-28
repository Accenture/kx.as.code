#!/bin/bash -x
set -euo pipefail

. ${autoSetupHome}/cicd/gitlab-ce/helper_scripts/getGroupIds.sh

# Create Grafana Image Renderer project in Gitlab
export grafanaImageRendererProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="grafana_image_renderer") | .id')
if [[ -z ${grafanaImageRendererProjectId} ]]; then
    for i in {1..5}; do
        curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'description=Grafana image renderer Kubernetes deployment files' \
            --data 'name=grafana_image_renderer' \
            --data 'namespace_id='${devopsGroupId}'' \
            --data 'path=grafana_image_renderer' \
            --data 'default_branch=master' \
            --data 'visibility=private' \
            --data 'container_registry_enabled=false' \
            ${gitUrl}/api/v4/projects
        export grafanaImageRendererProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="grafana_image_renderer") | .id')
        if [[ -n ${grafanaImageRendererProjectId} ]]; then break; else
            log_warn "grafana_image_renderer Gitlab project not created. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "Grafana Image Renderer Project already exists in Gitlab. Skipping creation"
fi
