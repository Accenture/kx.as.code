#!/bin/bash -x
set -euo pipefail

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh
. ${installComponentDirectory}/helper_scripts/getTeamId.sh

# Add Channels
channelsToCreate="Security CICD Monitoring"
for channel in ${channelsToCreate}; do
    channelLowerCase=$(echo ${channel} | tr '[:upper:]' '[:lower:]')
    channelExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/channels | jq -r '.[] | select(.name=="'${channelLowerCase}'") | .name')
    if [[ -z ${channelExists} ]]; then
        curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
            -X POST https://${componentName}.${baseDomain}/api/v4/channels -d '{
            "team_id": "'${kxTeamId}'",
            "name": "'${channelLowerCase}'",
            "display_name": "'${channel}'",
            "purpose": "View notifications related to '${channel}'",
            "header": "'${channel}' Notifictions",
            "type": "O"
        }'
    else
        log_info "Mattermost channel \"${channel}\" already exists. Skipping creation"
    fi
done
