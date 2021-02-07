#!/bin/bash -eux

. ${autoSetupHome}/cicd/gitlab-ce/helper_scripts/getGroupIds.sh

# Create Jira project in Gitlab
export jiraProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="jira") | .id')
if [[ -z ${jiraProjectId} ]]; then
  for i in {1..5}
  do
    curl -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Jira Kubernetes deployment files' \
      --data 'name=jira' \
      --data 'namespace_id='${devopsGroupId}'' \
      --data 'path=jira' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      ${gitUrl}/api/v4/projects | jq '.id'
      export jiraProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="jira") | .id')
      if [[ ! -z ${jiraProjectId} ]]; then break; else log_warn "Jira Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Jira Project already exists in Gitlab. Skipping creation"
fi
