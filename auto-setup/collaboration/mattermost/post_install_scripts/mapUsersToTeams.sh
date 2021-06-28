#!/bin/bash -x
set -euo pipefail

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh
. ${installComponentDirectory}/helper_scripts/getTeamId.sh

# Add users to KX.AS.CODE Team
usersToMapToKxTeam="admin securty cicd monitoring"

for user in ${usersToMapToKxTeam}; do
    # Get user id
    userId=$(curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/users/username/${user} | jq -r '.id')
    # Check if user already member of team
    memberMappingExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/teams/${kxTeamId}/members | jq -r '.[] | select(.user_id=="'${userId}'") | .user_id')
    if [[ -z ${memberMappingExists} ]]; then
        # Add user to KX.AS.CODE Team
        curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
            -X POST https://${componentName}.${baseDomain}/api/v4/teams/${kxTeamId}/members -d '{
            "team_id": "'${kxTeamId}'",
            "user_id": "'${userId}'"
        }'
    else
        log_info "Mattermost user \"${userId}\" is already a member of team \"kxascode\". Nothing to do"
    fi
done
