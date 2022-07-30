gitlabGetGroupId() {

    groupName=${1}

    # Get Gitlab personal access token
    export personalAccessToken=$(getPassword "gitlab-personal-access-token")

    # Get Gitlab Group Id
    curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="'${groupName}'") | .id'

}
