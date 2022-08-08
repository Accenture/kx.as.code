#!/bin/bash
set -euo pipefail

# Only execute the next step if Mattermost is installed
if [[ $(checkApplicationInstalled "mattermost" "collaboration") ]]; then
    export mattermostLoginToken=$(curl -i -d '{"login_id":"admin@'${baseDomain}'","password":"'${vmPassword}'"}' ${chatopsUrl}/api/v4/users/login | grep 'token' | sed 's/token: //g')
    export monitoringWebhookId=$(curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET ${chatopsUrl}/api/v4/hooks/incoming | jq -r '.[] | select(.display_name=="Monitoring") | .id')
fi