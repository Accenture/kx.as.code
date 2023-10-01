mattermostGetUserId() {

    if checkApplicationInstalled "mattermost" "collaboration"; then

        mattermostUsername=${1}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/users/username/${mattermostUsername} | jq -r '.id'

    fi

}
