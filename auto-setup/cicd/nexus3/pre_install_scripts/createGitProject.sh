#!/bin/bash -eux

. ${autoSetupHome}/cicd/gitlab-ce/helper_scripts/getGroupIds.sh

# Create Nexus3 project in Gitlab
export nexus3ProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="nexus3") | .id')
if [[ -z ${nexus3ProjectId} ]]; then
  for i in {1..5}
  do
    curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Nexus3 Kubernetes deployment files' \
      --data 'name=nexus3' \
      --data 'namespace_id='$devopsGroupId'' \
      --data 'path=nexus3' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      ${gitUrl}/api/v4/projects
      export nexus3ProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="nexus3") | .id')
      if [[ ! -z ${nexus3ProjectId} ]]; then break; else log_warn "Nexus3 Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Nexus3 Project already exists in Gitlab. Skipping creation"
fi
