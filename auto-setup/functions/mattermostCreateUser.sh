mattermostCreateUser() {

    if checkApplicationInstalled "mattermost" "collaboration"; then

        mattermostUser=${1}

        # Get login token for API call
        mattermostLoginToken=$(mattermostGetLoginToken "admin")

        # Create Notifications User
        userExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://mattermost.${baseDomain}/api/v4/users | jq -r '.[] | select(.username=="'${mattermostUser}'") | .username')
        if [[ -z ${userExists} ]]; then
            export generateUserPassword=$(managedPassword "mattermost-${mattermostUser}-password" "mattermost")
            curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
                -X POST https://mattermost.${baseDomain}/api/v4/users -d '{
            "email": "'${mattermostUser}'@'${baseDomain}'",
            "username": "'${mattermostUser}'",
            "first_name": "'${mattermostUser}'",
            "password": "'${generateUserPassword}'"
        }'
        else
            log_info "Mattermost user \"'${mattermostUser}'\" already exists. Skipping creation"
        fi

    fi

}
