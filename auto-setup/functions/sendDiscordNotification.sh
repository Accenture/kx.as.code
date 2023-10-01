sendDiscordNotification() {

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
    local discordNotificationWebhook="$(cat ${profileConfigJsonPath} | jq -r '.notification_endpoints.discord_webhook')"

    if [[ "${logLevel}" == "error" ]] || [[ "${actionStatus}" == "failed" ]]; then
        local lastExecutingScript="$(cat ${installationWorkspace}/.retryDataStore.json | tr -d "[:cntrl:]" | jq -r '.script')"
        local lastExecutingFunction="${currentFunctionExecuting:-}"
    else
        local lastExecutingScript="-"
        local lastExecutingFunction="-"
    fi

    # logLevel --> info, error, warn
    # actionStatus --> success, failed, warning

    # Send message if necessary variables are populated
    if [[ -n ${discordNotificationWebhook} ]] && [[ "${discordNotificationWebhook}" != "null" ]] && [[ -n ${message} ]]; then

        # Determine colour of message card
        if [[ "${logLevel}" == "error" ]] || [[ "${actionStatus}" == "failed" ]]; then
            statusColour="${colourRed}"
            statusEmoticon=":red_square:"
        elif [[ "${logLevel}" == "warn" ]] || [[ "${actionStatus}" == "warning" ]]; then
            statusColour="${colourAmber}"
            statusEmoticon=":orange_square:"
        elif [[ "${actionStatus}" == "success" ]]; then
            statusColour="${colourGreen}"
            statusEmoticon=":green_square:"
        elif [[ "${logLevel}" == "info" ]]; then
            statusColour="${colourBlue}"
            statusEmoticon=":blue_square:"
        else
            statusColour="${colourGrey}"
            statusEmoticon=":black_square:"
        fi

# Post message to Discord
message=$(echo ${message} | sed 's/"/\\\\\\"/g') # Ensure quotes are escaped
curl -X POST -H "Content-Type: application/json" --data-binary @- ${discordNotificationWebhook} <<EOF
{
    "username": "KX.AS.CODE Notification",
    "content": "${statusEmoticon} ${message}",
    "embeds": [
      {
        "description": "- Component: \`${componentName^}\` \n- Category: \`${category^}\`\n- Action: \`${action^}\`\n- Task: \`${task^}\`\n- Status: \`${actionStatus^}\`\n- Duration: \`${actionDuration^}\`\n- Last Executing Script: \`${lastExecutingScript^}\`\n- Last Executing Function: \`${lastExecutingFunction^}\`"
      }
    ]
  }
EOF

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}