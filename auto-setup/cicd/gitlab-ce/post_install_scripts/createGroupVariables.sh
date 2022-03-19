#!/bin/bash -x
set -euo pipefail

# Get Personal Access Token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Get Group Id
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')

# Get Registry Robot Credentials for KX.AS.CODE project
export kxRobotUser=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.name' | sed 's/\$/\$\$/g')
export kxRobotToken=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.token')

# Create variable in KX.AS.Code group
createGitlabVariable() {

  gitlabVariableKey=$1
  gitlabVariableValue=$2
  gitlabGroupId=$2

  groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/variables/${gitlabVariableKey}" | jq -r '.key')
  if [[ ${groupVariableExists} == "null"   ]]; then
      for i in {1..5}; do
          curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/variables" --form "key=${gitlabVariableKey}" --form "value=${gitlabVariableValue}"
          groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/variables/${gitlabVariableKey}" | jq -r '.key')
          if [[ ${groupVariableExists} != "null"   ]]; then break; else
              log_warn "Gitlab Group Variable \"${gitlabVariableName}\" not created. Trying again"
              sleep 5
          fi

      done
  else
      log_info "KX.AS.CODE group variable \"${gitlabVariableName}\" already exists in Gitlab. Skipping creation"
  fi
}

createGitlabVariable "GIT_USER" "${vmUser}" "${kxascodeGroupId}"
createGitlabVariable "PERSONAL_ACCESS_TOKEN" "${personalAccessToken}" "${kxascodeGroupId}"
createGitlabVariable "DOCKER_REGISTRY_DOMAIN" "${dockerRegistryDomain}" "${kxascodeGroupId}"
createGitlabVariable "BASE_DOMAIN" "${baseDomain}" "${kxascodeGroupId}"
createGitlabVariable "GIT_DOMAIN" "${gitDomain}" "${kxascodeGroupId}"
createGitlabVariable "HARBOR_ROBOT_KX_USER" "${kxRobotUser}" "${kxascodeGroupId}"
createGitlabVariable "HARBOR_ROBOT_KX_TOKEN" "${kxRobotToken}" "${kxascodeGroupId}"