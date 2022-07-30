mattermostCreateWebhook() {

    # Create Mattermost Webhook
    mattermostWebhookName=${1}
    mattermostTeamName=${2}
    mattermostChannelName=${3}
    mattermostWebhookAvatarUrl=${4}

    # Get login token for API call
    mattermostLoginToken=$(mattermostGetLoginToken "admin")

    # Get associated channel ID to post to
    channelId=$(mattermostGetChannelId "${mattermostTeamName}" "${mattermostChannelName}")

    # Create Mattermost Webhook
    webhookExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/hooks/incoming | jq -r '.[] | select(.display_name=="'${mattermostWebhookName}'") | .display_name')
    if [[ -z ${webhookExists} ]]; then
        curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
            -X POST https://mattermost.${baseDomain}/api/v4/hooks/incoming -d '{
        "channel_id": "'${channelId}'",
        "display_name": "'${mattermostWebhookName}'",
        "description": "Post '${mattermostWebhookName}' Notifications",
        "username": "'${mattermostWebhookName,,}'",
        "icon_url": "'${mattermostWebhookAvatarUrl}'"
    }'
    else
        log_info "Mattermost webhook \"${mattermostWebhookName}\" already exists. Skipping creation"
    fi

    # Test Mattermost Webhook exists after creation
    curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/hooks/incoming

}