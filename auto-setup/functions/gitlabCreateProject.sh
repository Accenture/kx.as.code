createGitlabProject() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  if checkApplicationInstalled "gitlab" "cicd"; then

    # Get Gitlab personal access token
    export personalAccessToken=$(getPassword "gitlab-personal-access-token" "gitlab")

    gitlabProjectName=$1
    gitlabGroupName=$2
    gitlabGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupName} | jq '.id')

    log_debug "Extracted Gitlab \"${gitlabGroupName}\" Group Id: ${gitlabGroupId}"

    # Create project in Gitlab
    export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects/${gitlabGroupName}%2F${gitlabProjectName} | jq '.id')
    log_debug "Extracted Gitlab \"${gitlabProjectName}\" Project Id: ${kxascodeProjectId}"
    if [[ "${kxascodeProjectId}" == "null" ]] || [[ -z "${kxascodeProjectId}" ]]; then
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
            export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects/${gitlabGroupName}%2F${gitlabProjectName} | jq '.id')
            if [[ -n ${kxascodeProjectId} ]]; then break; else
                log_warn "Gitlab project \"${gitlabProjectName}\" not created. Trying again ($i of 5)"
                sleep 5
            fi
        done
    else
        log_info "Gitlab Project \"${gitlabProjectName}\" already exists in Gitlab. Skipping creation"
    fi

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
