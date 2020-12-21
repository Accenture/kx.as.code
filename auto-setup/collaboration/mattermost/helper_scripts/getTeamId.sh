#!/bin/bash -eux

# Get Mattermost Team id
export kxTeamId=$(curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/teams/name/kxascode | jq -r '.id')