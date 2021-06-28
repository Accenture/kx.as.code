#!/bin/bash -x
set -euo pipefail

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh

# Create KX.AS.CODE team
teamExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/teams | jq -r '.[] | select(.name=="kxascode") | .name')
if [[ -z ${teamExists} ]]; then
    curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
        -X POST https://${componentName}.${baseDomain}/api/v4/teams -d '{
        "name": "kxascode",
        "display_name": "Team KX.AS.CODE",
        "type": "I"
    }'
else
    log_info 'Mattermost Team "kxascode" already exists. Skipping creation'
fi
