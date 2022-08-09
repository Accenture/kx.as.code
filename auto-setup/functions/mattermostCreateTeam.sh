mattermostCreateTeam() {

    if checkApplicationInstalled "mattermost" "collaboration"; then

        mattermostTeam=${1}
        mattermostTeamDisplayName=${2-${mattermostTeam^^}}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        # Create KX.AS.CODE team
        teamExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/teams | jq -r '.[] | select(.name=="'${mattermostTeam}'") | .name')
        if [[ -z ${teamExists} ]]; then
            curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -d "{
                \"name\": \"${mattermostTeam}\",
                \"display_name\": \"${mattermostTeamDisplayName}\",
                \"type\": \"I\"
            }" -X POST https://mattermost.${baseDomain}/api/v4/teams
        else
            log_info 'Mattermost Team "'${mattermostTeam}'" already exists. Skipping creation'
        fi

    fi

}