####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
sendMsTeamsNotification() {
  set +x
  local message=''${1:-}''
  local logLevel=${2:-"info"}
  local actionStatus=${3:-"unknown"}
  local componentName=${4:-"not applicable"}
  local action=${5:-}
  local category=${6:-}
  local retries=${7:-}
  local task=${8:-}
  local actionDuration=${9:-}
  local msTeamsNotificationWebhook="$(cat ${profileConfigJsonPath} | jq -r '.notification_endpoints.ms_teams_webhook | select(.!=null)')"
  local notificationTitle="$(cat ${profileConfigJsonPath} | jq -r '.notification_title | select(.!=null)')"

  if [[ -n ${msTeamsNotificationWebhook} ]]; then

    if [[ -z ${notificationTitle} ]]; then
      notificationTitle="KX.AS.CODE"
    fi

    parsedMessage=$(echo ''${message}'' | sed 's/"/\\"/g' | sed 's/\\$//g')

    if [[ "${logLevel}" == "error" ]] || [[ "${actionStatus}" == "failed" ]]; then
      local lastExecutingScript="$(cat ${installationWorkspace}/.retryDataStore.json | tr -d "[:cntrl:]" | jq -r '.script')"
      local lastExecutingFunction="$(cat ${installationWorkspace}/.currentFunctionExecuting)"
    else
      local lastExecutingScript="~"
      local lastExecutingFunction="~"
    fi

    if [[ -z "${actionDuration}" ]]; then
      actionDuration="~"
    fi

    #logLevel --> info, error, warn
    #actionStatus --> success, failed, warning

    # Send message if necessary variables are populated
    if [[ -n "${msTeamsNotificationWebhook}" ]] && [[ "${msTeamsNotificationWebhook}" != "null" ]] && [[ -n "${message}" ]]; then

      # Determine colour of message card
      if [[ "${logLevel}" == "error" ]] || [[ "${actionStatus}" == "failed" ]]; then
        statusColour="${colourRed}"
        statusEmoticon="&#128997;"
      elif [[ "${logLevel}" == "warn" ]] || [[ "${actionStatus}" == "warning" ]]; then
        statusColour="${colourAmber}"
        statusEmoticon="&#128999;"
      elif [[ "${actionStatus}" == "success" ]]; then
        statusColour="${colourGreen}"
        statusEmoticon="&#129001;"
      elif [[ "${logLevel}" == "info" ]]; then
        statusColour="${colourBlue}"
        statusEmoticon="&#128998;"
      else
        statusColour="${colourGrey}"
        statusEmoticon="&#11035;"
      fi

      echo '''{
                "@type": "MessageCard",
                "@context": "http://schema.org/extensions",
                "themeColor": "'${statusColour}'",
                "summary": "['${logLevel^^}'] '${action^}' for '${componentName^}' '${actionStatus}'",
                "sections": [{
                    "activityTitle": "'${notificationTitle}' - '${baseDomain}'",
                    "activitySubtitle": "'${statusEmoticon}' ['${logLevel^^}'] '${parsedMessage}'",
                    "activityImage": "",
                    "facts": [{
                        "name": "Component",
                        "value": "'${componentName^}'"
                    },{
                        "name": "Category",
                        "value": "'${category^}'"
                    },{
                        "name": "Action",
                        "value": "'${action^}'"
                    },{
                        "name": "Task",
                        "value": "'${task^}'"
                    },{
                        "name": "Status",
                        "value": "'${actionStatus^}'"
                    },{
                        "name": "Duration",
                        "value": "'${actionDuration^}'"
                    },{
                        "name": "Last Executing Script",
                        "value": "'${lastExecutingScript^}'"
                    },{
                        "name": "Last Executing Function",
                        "value": "'${lastExecutingFunction^}'"
                    }],
                    "markdown": true
                }]
                }''' | /usr/bin/sudo tee ${installationWorkspace}/msTeamsNotification.json

      curl -H 'Content-Type: application/json' -d @${installationWorkspace}/msTeamsNotification.json ${msTeamsNotificationWebhook}

    fi
  fi
}
