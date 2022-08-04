gitlabMapUserToGroup() {

    gitlabUserName=${1}
    gitlabGroupName=${2}

    # Get Gitlab personal access token
    personalAccessToken=$(getPassword "gitlab-personal-access-token"  "gitlab")

    # Get Gitlab user and group ids
    gitlabUserId=$(gitlabGetUserId "${gitlabUserName}")
    gitlabGroupId=$(gitlabGetGroupId "${gitlabGroupName}")
    gitlabRootUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/users | jq -r '.[] | select (.username=="root") | .id')


    # Add new user as group admin to new KX.AS.CODE group
    mappedUser=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/members | jq '.[] | select(.username=="'${gitlabUserName}'") | .id')
    if [[ -z ${mappedUser} ]]; then
        for i in {1..5}; do
            curl -XPOST --header "Private-Token: ${personalAccessToken}" \
                --data 'id='${gitlabRootUserId}'' \
                --data 'user_id='${gitlabUserId}'' \
                --data 'access_level=50' \
                https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/members
            mappedUser=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups/${gitlabGroupId}/members | jq '.[] | select(.username=="'${gitlabUserName}'") | .id')
            if [[ -n ${mappedUser}   ]]; then break; else
                log_warn "${gitlabUserName} user was not mapped to KX.AS.CODE group. Trying again ($i of 5)"
                sleep 5
            fi
        done
    else
        log_info "${gitlabUserName} is already included in the Gitlab KX-AS-CODE group. Skipping adding ${gitlabUserName} to group"
    fi

}