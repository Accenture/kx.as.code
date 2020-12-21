#!/bin/bash -eux

# Get Personal Access Token
export personalAccessToken=$(cat /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat)

# Get Group Id
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')

# Get Registry Robot Credentials for KX.AS.CODE project
export kxRobotUser=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.name' | sed 's/\$/\$\$/g')
export kxRobotToken=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.token')

# Create variable "GIT_USER" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/GIT_USER" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=GIT_USER" --form "value=${vmUser}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/GIT_USER" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"GIT_USER\" not created. Trying again"; sleep 5; fi

    done
else
  log_info "KX.AS.CODE group variable \"GIT_USER\" already exists in Gitlab. Skipping creation"
fi

# Create variable "PERSONAL_ACCESS_TOKEN" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/PERSONAL_ACCESS_TOKEN" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=PERSONAL_ACCESS_TOKEN" --form "value=${personalAccessToken}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/PERSONAL_ACCESS_TOKEN" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"PERSONAL_ACCESS_TOKEN\" not created. Trying again"; sleep 5; fi
    done
else
  log_info "KX.AS.CODE group variable \"PERSONAL_ACCESS_TOKEN\" already exists in Gitlab. Skipping creation"
fi

# Create variable "DOCKER_REGISTRY_DOMAIN" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/DOCKER_REGISTRY_DOMAIN" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=DOCKER_REGISTRY_DOMAIN" --form "value=${dockerRegistryDomain}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/DOCKER_REGISTRY_DOMAIN" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"DOCKER_REGISTRY_DOMAIN\" not created. Trying again"; sleep 5; fi
    done
else
  log_info "KX.AS.CODE group variable \"DOCKER_REGISTRY_DOMAIN\" already exists in Gitlab. Skipping creation"
fi

# Create variable "BASE_DOMAIN" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/BASE_DOMAIN" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=BASE_DOMAIN" --form "value=${baseDomain}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/BASE_DOMAIN" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"BASE_DOMAIN\" not created. Trying again"; sleep 5; fi
    done
else
  log_info "KX.AS.CODE group variable \"BASE_DOMAIN\" already exists in Gitlab. Skipping creation"
fi

# Create variable "GIT_DOMAIN" in KX.AS.Code group
groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/GIT_DOMAIN" | jq -r '.key')
if [[ "${groupVariableExists}" == "null" ]]; then
    for i in {1..5}
    do
        curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables" --form "key=GIT_DOMAIN" --form "value=${gitDomain}"
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${kxascodeGroupId}/variables/GIT_DOMAIN" | jq -r '.key')
        if [[ "${groupVariableExists}" != "null" ]]; then break; else echo "KX.AS.CODE Group Variable \"GIT_DOMAIN\" not created. Trying again"; sleep 5; fi
    done
else
  log_info "KX.AS.CODE group variable \"GIT_DOMAIN\" already exists in Gitlab. Skipping creation"
fi
