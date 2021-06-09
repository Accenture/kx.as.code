#!/bin/bash -x
set -euo pipefail

. ${autoSetupHome}/cicd/gitlab-ce/helper_scripts/getGroupIds.sh

# Create teamcity project in Gitlab
export teamcityProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="teamcity") | .id')
if [[ -z ${teamcityProjectId} ]]; then
    for i in {1..5}; do
        curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'description=Teamcity Kubernetes deployment files' \
            --data 'name=teamcity' \
            --data 'namespace_id='$devopsGroupId'' \
            --data 'path=teamcity' \
            --data 'default_branch=master' \
            --data 'visibility=private' \
            --data 'container_registry_enabled=false' \
            --data 'auto_devops_enabled=false' \
            ${gitUrl}/api/v4/projects
        export teamcityProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="teamcity") | .id')
        if [[ -n ${teamcityProjectId} ]]; then break; else
            log_warn "Teamcity Gitlab project not created. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "Teamcity Project already exists in Gitlab. Skipping creation"
fi
