#!/bin/bash
set -euo pipefail

# Get Personal Access Token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Get Registry Robot Credentials for KX.AS.CODE project
#export kxRobotUser=$(cat /home/${baseUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.name' | sed 's/\$/\$\$/g')
#export kxRobotToken=$(cat /home/${baseUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.token')

# Create variable in KX.AS.Code group
createGitlabVariable() {

  gitlabVariableKey=$1
  gitlabVariableValue=$2
  gitlabGroupName=$3

  groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://${componentName}.${baseDomain}/api/v4/groups/${gitlabGroupName}/variables/${gitlabVariableKey}" | jq -r '.key')
  if [[ ${groupVariableExists} == "null"   ]]; then
      for i in {1..5}; do
          curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://${componentName}.${baseDomain}/api/v4/groups/${gitlabGroupName}/variables" --form "key=${gitlabVariableKey}" --form "value=${gitlabVariableValue}"
          groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://${componentName}.${baseDomain}/api/v4/groups/${gitlabGroupName}/variables/${gitlabVariableKey}" | jq -r '.key')
          if [[ ${groupVariableExists} != "null"   ]]; then break; else
              log_warn "Gitlab Group Variable \"${gitlabVariableKey}\" not created. Trying again"
              sleep 5
          fi

      done
  else
      log_info "KX.AS.CODE group variable \"${gitlabVariableKey}\" already exists in Gitlab. Skipping creation"
  fi
}

createGitlabVariable "GIT_USER" "${baseUser}" "kx.as.code"
createGitlabVariable "PERSONAL_ACCESS_TOKEN" "${personalAccessToken}" "kx.as.code"
createGitlabVariable "DOCKER_REGISTRY_DOMAIN" "${dockerRegistryDomain}" "kx.as.code"
createGitlabVariable "BASE_DOMAIN" "${baseDomain}" "kx.as.code"
createGitlabVariable "GIT_DOMAIN" "${gitDomain}" "kx.as.code"
