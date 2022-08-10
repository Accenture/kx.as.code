gitlabGetGroupId() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "gitlab" "cicd"; then

        groupName=${1}

        # Get Gitlab personal access token
        export personalAccessToken=$(getPassword "gitlab-personal-access-token" "gitlab")

        # Get Gitlab Group Id
        curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="'${groupName}'") | .id'

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}
