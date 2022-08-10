mattermostGetChannelId() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "mattermost" "collaboration"; then

        mattermostTeamName=${1}
        mattermostChannelName=${2}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        # Get Mattermost Team Id
        mattermostTeamId=$(mattermostGetTeamId "${mattermostTeamName}")
        
        # Get Mattermost Channel Id
        curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/teams/${mattermostTeamId}/channels/name/${mattermostChannelName} | jq -r '.id'

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}