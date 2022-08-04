gitlabGetUserId() {

    username=${1}

    # Get Gitlab personal access token
    export personalAccessToken=$(getPassword "gitlab-personal-access-token" "gitlab")

    # Get the id of a user
    curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/users | jq -r '.[] | select (.username=="'${username}'") | .id'

}