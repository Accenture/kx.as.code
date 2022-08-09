gitlabCreateGroupVariable() {

    if checkApplicationInstalled "gitlab" "cicd"; then

        gitlabVariableKey=${1}
        gitlabVariableValue=${2}
        gitlabGroupId=${3}

        # Create variable in Gitlab
        groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/variables/${gitlabVariableKey}" | jq -r '.key')
        if [[ ${groupVariableExists} == "null"   ]]; then
            for i in {1..5}; do
                curl --request POST --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/variables" --form "key=${gitlabVariableKey}" --form "value=${gitlabVariableValue}"
                groupVariableExists=$(curl --header "PRIVATE-TOKEN: ${personalAccessToken}" "https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/variables/${gitlabVariableKey}" | jq -r '.key')
                if [[ ${groupVariableExists} != "null"   ]]; then break; else
                    log_warn 'Gitlab Group Variable "'${gitlabVariableKey}'" not created. Trying again'
                    sleep 5
                fi
            done
        else
            log_info 'Gitlab group variable "'${gitlabVariableKey}'" already exists. Skipping creation'
        fi

    fi

}