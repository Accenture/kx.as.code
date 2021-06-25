#!/bin/bash -x
set -euo pipefail

# Create KX.AS.CODE "Docs" project in Gitlab
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/groups | jq -r '.[] | select(.name=="kx.as.code") | .id')
export kxDocsProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq -r '.[] | select(.name=="kx.as.code_docs") | .id')
if [[ -z ${kxDocsProjectId} ]]; then
    for i in {1..5}; do
        curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'description=KX.AS.CODE Documentation Engine' \
            --data 'name=kx.as.code_docs' \
            --data 'namespace_id='${kxascodeGroupId}'' \
            --data 'path=kx.as.code_docs' \
            --data 'default_branch=master' \
            --data 'visibility=private' \
            --data 'container_registry_enabled=false' \
            ${gitUrl}/api/v4/projects
        export kxDocsProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_docs") | .id')
        if [[ -n ${kxDocsProjectId}   ]]; then break; else
            log_warn "KX.AS.CODE_DOCS Gitlab project not created. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info 'KX.AS.CODE "Docs" Project already exists in Gitlab. Skipping creation'
fi
