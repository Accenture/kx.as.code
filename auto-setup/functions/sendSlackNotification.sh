sendSlackNotification() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart "true"

    local message=${1:-}
    local logLevel=${2:-info}
    local actionStatus=${3:-unkown}
    local componentName=${4:-not applicable}
    local action=${5:-}
    local category=${6:-}
    local retries=${7:-}
    local task=${8:-}
    local actionDuration=${9:-}
    local slackNotificationWebhook="$(cat ${profileConfigJsonPath} | jq -r '.notification_endpoints.slack_webhook')"

    if [[ "${logLevel}" == "error" ]] || [[ "${actionStatus}" == "failed" ]]; then
        local lastExecutingScript="$(cat ${installationWorkspace}/.retryDataStore.json | tr -d "[:cntrl:]" | jq -r '.script')"
        local lastExecutingFunction="${currentFunctionExecuting:-}"
    else
        local lastExecutingScript=""
        local lastExecutingFunction=""
    fi

    #logLevel --> info, error, warn
    #actionStatus --> success, failed, warning

    # Send message if necessary variables are populated
    if [[ -n ${slackNotificationWebhook} ]] && [[ "${slackNotificationWebhook}" != "null" ]] && [[ -n ${message} ]]; then

        # Determine colour of message card
        if [[ "${logLevel}" == "error" ]] || [[ "${actionStatus}" == "failed" ]]; then
            statusColour="${colourRed}"
            statusEmoticon=":large_red_square:"
        elif [[ "${logLevel}" == "warn" ]] || [[ "${actionStatus}" == "warning" ]]; then
            statusColour="${colourAmber}"
            statusEmoticon=":large_orange_square:"
        elif [[ "${actionStatus}" == "success" ]]; then
            statusColour="${colourGreen}"
            statusEmoticon=":large_green_square:"
        elif [[ "${logLevel}" == "info" ]]; then
            statusColour="${colourBlue}"
            statusEmoticon=":large_blue_square:"
        else
            statusColour="${colourGrey}"
            statusEmoticon=":black_large_square:"
        fi

        # Generate message to post to Slack
        messageCard="{
            \"text\": \"$(echo ${message} | sed 's/"/\\"/g')\",
            \"blocks\": [
                {
                        \"type\": \"section\",
                        \"text\": {
                                \"type\": \"mrkdwn\",
                                \"text\": \"${statusEmoticon} [${logLevel^^}] $(echo ${message} | sed 's/"/\\"/g')\"
                        }
                },
                {
                        \"type\": \"section\",
                        \"fields\": [
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Component:* ${componentName^}\"
                                },
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Category:* ${category^}\"
                                },
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Action:* ${action^}\"
                                },
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Task:* ${task^}\"
                                },      
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Status:* ${actionStatus^}\"
                                },
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Duration:* ${actionDuration^}\"
                                },
                                                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Last Executing Script:* ${lastExecutingScript^}\"
                                },
                                {
                                        \"type\": \"mrkdwn\",
                                        \"text\": \"*Last Executing Function:* ${lastExecutingFunction^}\"
                                },
                        ]
                }
            ]
        }"

        # Post message to Slack
        curl -H "Content-type: application/json" \
            --data "${messageCard}" \
            -X POST ${slackNotificationWebhook}

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}