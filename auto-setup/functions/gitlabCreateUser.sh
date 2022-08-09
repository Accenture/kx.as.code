gitlabCreateUser() {

    if checkApplicationInstalled "gitlab" "cicd"; then

        gitlabUserName=${1}
        skipConfirmation=${2-true}
        state=${3-active}
        canCreateProject=${4-true}
        gitlabUserPassword=$(managedPassword "gitlab-${gitlabUserName}-user-password" "gitlab")

        # Get Gitlab personal access token
        export personalAccessToken=$(getPassword "gitlab-personal-access-token" "gitlab")

        # Create kx.hero user in Gitlab
        export gitlabUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/users | jq '.[] | select(.username=="'${gitlabUserName}'") | .id')
        if [[ -z ${gitlabUserId} ]]; then
            for i in {1..5}; do
                curl -s --header "Private-Token: ${personalAccessToken}" \
                    --data 'name='${gitlabUserName}'' \
                    --data 'username='${gitlabUserName}'' \
                    --data 'password='${gitlabUserPassword}'' \
                    --data 'state='${state}'' \
                    --data 'skip_confirmation='${skipConfirmation}'' \
                    --data 'email='${gitlabUserName}'@'${baseDomain}'' \
                    --data 'can_create_project='${canCreateProject}'' \
                    -XPOST https://gitlab.${baseDomain}/api/v4/users
                export gitlabUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/users | jq '.[] | select(.username=="'${gitlabUserName}'") | .id')
                if [[ -n ${gitlabUserId} ]]; then break; else
                    echo "${gitlabUserName} user was not created. Trying again ($i of 5)"
                    sleep 5
                fi
            done
        else
            log_info "User ${gitlabUserName} already exists in Gitlab. Skipping creation"
        fi

    fi
}