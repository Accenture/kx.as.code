#!/bin/bash
set -euox pipefail

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

createGitlabProject() {

  gitlabProjectName=$1
  gitlabGroupName=$2
  gitlabGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups/${gitlabGroupName} | jq '.id')

  # Create project in Gitlab
  export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/projects/${gitlabGroupName}%2F${gitlabProjectName} | jq '.id')
  if [[ "${kxascodeProjectId}" == "null" ]]; then
      for i in {1..5}; do
          curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
              --data 'description='${gitlabProjectName}' Source Code' \
              --data 'name='${gitlabProjectName}'' \
              --data 'namespace_id='${gitlabGroupId}'' \
              --data 'path='${gitlabProjectName}'' \
              --data 'default_branch=main' \
              --data 'visibility=internal' \
              --data 'container_registry_enabled=false' \
              --data 'auto_devops_enabled=false' \
              https://${componentName}.${baseDomain}/api/v4/projects
          export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/projects/${gitlabGroupName}%2F${gitlabProjectName} | jq '.id')
          if [[ -n ${kxascodeProjectId} ]]; then break; else
              log_warn "Gitlab project \"${gitlabProjectName}\" not created. Trying again ($i of 5)"
              sleep 5
          fi
      done
  else
      log_info "Gitlab Project \"${gitlabProjectName}\" already exists in Gitlab. Skipping creation"
  fi

}

# function-call projectName groupName
createGitlabProject "kx.as.code" "kx.as.code"
createGitlabProject "grafana-image-renderer" "devops"
createGitlabProject "nexus3" "devops"
createGitlabProject "jira" "devops"
createGitlabProject "confluence" "devops"
