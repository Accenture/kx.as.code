#!/bin/bash -x
set -euo pipefail

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Get Gitlab Group IDs
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')
export devopsGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="devops") | .id')

createGitlabProject() {

  gitlabProjectName=$1
  gitlabGroupId=$2
  # Create project in Gitlab
  export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="'${gitlabProjectName}'") | .id')
  if [[ -z ${kxascodeProjectId} ]]; then
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
              https://gitlab.${baseDomain}/api/v4/projects
          export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="'${gitlabProjectName}'") | .id')
          if [[ -n ${kxascodeProjectId} ]]; then break; else
              log_warn "Gitlab project \"${gitlabProjectName}\" not created. Trying again ($i of 5)"
              sleep 5
          fi
      done
  else
      log_info "Gitlab Project \"${gitlabProjectName}\" already exists in Gitlab. Skipping creation"
  fi

}

createGitlabProject "kx.as.code" "${kxascodeGroupId}"
createGitlabProject "grafana-image-renderer" "${devopsGroupId}"
createGitlabProject "nexus3" "${devopsGroupId}"
createGitlabProject "jira" "${devopsGroupId}"
createGitlabProject "confluence" "${devopsGroupId}"
