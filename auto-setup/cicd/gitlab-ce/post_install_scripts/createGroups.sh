#!/bin/bash -x
set -euo pipefail

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Create kx.as.code group in Gitlab
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')
if [[ -z ${kxascodeGroupId} ]]; then
    for i in {1..5}; do
        curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'name=kx.as.code' \
            --data 'path=kx.as.code' \
            --data 'full_name=kx.as.code' \
            --data 'full_path=kx.as.code' \
            --data 'visibility=internal' \
            --data 'lfs_enabled=true' \
            --data 'subgroup_creation_level=maintainer' \
            --data 'project_creation_level=developer' \
            https://gitlab.${baseDomain}/api/v4/groups
        export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')
        if [[ -n ${kxascodeGroupId} ]]; then break; else
            echo "KX.AS.CODE Group not created. Trying again"
            sleep 5
        fi
    done
else
    log_info "KX-AS-CODE group already exists in Gitlab. Skipping creation"
fi

# Create DevOps group in Gitlab
export devopsGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="devops") | .id')
if [[ -z ${devopsGroupId} ]]; then
    for i in {1..5}; do
        curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'name=devops' \
            --data 'path=devops' \
            --data 'full_name=DevOps' \
            --data 'full_path=devops' \
            --data 'visibility=internal' \
            --data 'lfs_enabled=true' \
            --data 'subgroup_creation_level=maintainer' \
            --data 'project_creation_level=developer' \
            https://gitlab.${baseDomain}/api/v4/groups
        export devopsGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="devops") | .id')
        if [[ -n ${devopsGroupId} ]]; then break; else
            echo "DEVOPS Group not created. Trying again"
            sleep 5
        fi
    done
else
    log_info "DEVOPS group already exists in Gitlab. Skipping creation"
fi
