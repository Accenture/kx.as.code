mattermostGetLoginToken() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "mattermost" "collaboration"; then

        mattermostUser=${1}

        # Get Password
        mattermostPassword=$(managedPassword "mattermost-${mattermostUser}-password" "mattermost")

        # Get Login Token
        curl -s -i -d '{"login_id":"'${mattermostUser}'@'${baseDomain}'","password":"'${mattermostPassword}'"}' https://mattermost.${baseDomain}/api/v4/users/login | grep 'token' | sed 's/token: //g' | sed "s/[^[:alnum:]-]//g"

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}