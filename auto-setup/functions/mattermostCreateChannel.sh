mattermostCreateChannel() {

    if checkApplicationInstalled "mattermost" "collaboration"; then

        channel=${1}
        teamId=${2}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        # Create channel in Mattermost if it does not already exist
        channelLowerCase=$(echo ${channel} | tr '[:upper:]' '[:lower:]')
        channelExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/channels | jq -r '.[] | select(.name=="'${channelLowerCase}'") | .name')
        if [[ -z ${channelExists} ]]; then
            curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
                -X POST https://mattermost.${baseDomain}/api/v4/channels -d '{
                "team_id": "'${teamId}'",
                "name": "'${channelLowerCase}'",
                "display_name": "'${channel}'",
                "purpose": "View notifications related to '${channel}'",
                "header": "'${channel}' Notifictions",
                "type": "O"
            }'
        else
            log_info "Mattermost channel \"${channel}\" already exists. Skipping creation"
        fi

    fi

}