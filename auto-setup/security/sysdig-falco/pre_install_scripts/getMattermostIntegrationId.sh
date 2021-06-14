#!/bin/bash -x
set -euo pipefail

export mattermostLoginToken=$(curl -i -d '{"login_id":"admin@'${baseDomain}'","password":"'${vmPassword}'"}' ${chatopsUrl}/api/v4/users/login | grep 'token' | sed 's/token: //g')
export securityWebhookId=$(curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET ${chatopsUrl}/api/v4/hooks/incoming | jq -r '.[] | select(.display_name=="Security") | .id')
