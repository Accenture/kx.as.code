#!/bin/bash -eux

# Get Personal Access Token
export personalAccessToken=$(cat /usr/share/kx.as.code/.config/.admin.gitlab.pat)

# Get Group Id
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')

# Get Registry Robot Credentials for KX.AS.CODE project
export kxRobotUser=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.name' | sed 's/\$/\$\$/g')
export kxRobotToken=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.token')

# Create variable "REGISTRY_ROBOT_PASSWORD" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/REGISTRY_ROBOT_PASSWORD" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=REGISTRY_ROBOT_PASSWORD" --form "value=${kxRobotToken}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/REGISTRY_ROBOT_PASSWORD" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"REGISTRY_ROBOT_PASSWORD\" not created. Trying again"; sleep 5; fi
    done
else
  log_info "KX.AS.CODE group variable \"REGISTRY_ROBOT_PASSWORD\" already exists in Gitlab. Skipping creation"
fi

# Create variable "REGISTRY_ROBOT_USER" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/REGISTRY_ROBOT_USER" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=REGISTRY_ROBOT_USER" --form "value=${kxRobotUser}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/REGISTRY_ROBOT_USER" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"REGISTRY_ROBOT_USER\" not created. Trying again"; sleep 5; fi
    done
else
  log_info "KX.AS.CODE group variable \"REGISTRY_ROBOT_USER\" already exists in Gitlab. Skipping creation"
fi
