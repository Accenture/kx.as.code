#!/bin/bash -eux

. ${autoSetupHome}/cicd/gitlab-ce/helper_scripts/getGroupIds.sh

# Create Confluence project in Gitlab
export confluenceProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="confluence") | .id')
if [[ -z ${confluenceProjectId} ]]; then
  for i in {1..5}
  do
    curl -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Confluence Kubernetes deployment files' \
      --data 'name=confluence' \
      --data 'namespace_id='${devopsGroupId}'' \
      --data 'path=confluence' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      ${gitUrl}/api/v4/projects | jq '.id'
      export confluenceProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="confluence") | .id')
      if [[ ! -z ${confluenceProjectId} ]]; then break; else log_warn "Confluence Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Confluence Project already exists in Gitlab. Skipping creation"
fi