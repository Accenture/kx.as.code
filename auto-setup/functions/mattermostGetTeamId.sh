mattermostGetTeamId() {

    if checkApplicationInstalled "mattermost" "collaboration"; then

        teamName=${1}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        # Get Mattermost Team id
        curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/teams/name/${teamName} | jq -r '.id'

    fi

}