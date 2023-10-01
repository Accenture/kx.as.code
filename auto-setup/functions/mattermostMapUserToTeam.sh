mattermostMapUserToTeam() {

    if checkApplicationInstalled "mattermost" "collaboration"; then

        mattermostUsername=${1}
        mattermostTeamName=${2}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        # Get Mattermost Team Id
        mattermostTeamId=$(mattermostGetTeamId "${mattermostTeamName}")

        # Get Mattermost User Id
        mattermostUserId=$(mattermostGetUserId "${mattermostUsername}")

        # Check if user already member of team
        memberMappingExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/teams/${mattermostTeamId}/members | jq -r '.[] | select(.user_id=="'${mattermostUserId}'") | .user_id')
        if [[ -z ${memberMappingExists} ]]; then
            # Add user to Mattermost Team
            curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
                -X POST https://${componentName}.${baseDomain}/api/v4/teams/${mattermostTeamId}/members -d '{
                "team_id": "'${mattermostTeamId}'",
                "user_id": "'${mattermostUserId}'"
            }'
        else
            log_info "Mattermost user \"${mattermostUserId}\" is already a member of team \"${mattermostTeamName}\". Nothing to do"
        fi

    fi

}