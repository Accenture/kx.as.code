####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
notifyAllChannels() {
  set +x
  local message="$(echo ${1} | tr -d '\n\r' | tr -dc '[:alnum:][:blank:]-/_=+*~#$?[{()}]%&@:;\.,|<>\\' | base64 -w 0)"
  local logLevel=${2:-info}
  local actionStatus=${3:-unknown}
  local action=${4:-}
  local acionQueueJsonPayload=${5:-}
  local actionDuration=${6:-}
  local notificationTimeout=${7:-300000}

  if [[ -n ${acionQueueJsonPayload} ]]; then

    local category=$(echo ${acionQueueJsonPayload} | jq -r '.install_folder')
    local componentName=$(echo ${acionQueueJsonPayload} | jq -r '.name')
    local action=$(echo ${acionQueueJsonPayload} | jq -r '.action')
    local retries=$(echo ${acionQueueJsonPayload} | jq -r '.retries')

    if [[ "${action}" == "executeTask" ]]; then
      local task=$(echo ${acionQueueJsonPayload} | jq -r '.task')
      action="Task Execution"
    elif [[ "${action}" == "install" ]] || [[ "${action}" == "uninstall" ]]; then
      local task="n/a"
      action="Component ${action^}ation"
    fi

  fi

  if [[ "${logLevel}" == "error" ]]; then
    dialogType="dialog-error"
  elif [[ "${logLevel}" == "warn" ]]; then
    dialogType="dialog-warning"
  else
    dialogType="dialog-information"
  fi

  # Change message if task was executed rather than solution installed
  if [[ "${action}" == "Task Execution" ]]; then
    message=$(echo ${1} | tr -d '\n\r' | tr -dc '[:alnum:][:blank:]-/_' | base64 | sed 's/Installation of/Execution of task '${task}' for/g' | sed 's/installed/task '${task}' executed/g' | base64 -w 0)
  fi

  log_trace "Sending following notification: ${message}"

  sendDiscordNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"
  sendSlackNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"
  sendMsTeamsNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"
  #sendEmailNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"

  # Add task duration to end of message if available
  if [[ -n "${actionDuration}" ]]; then
    message="${message} (${actionDuration})"
  fi

  notify "${message}" "${dialogType}" "${notificationTimeout}"
  log_trace addToNotificationQueue "${message}" "${logLevel}" "${actionStatus}"
  addToNotificationQueue "${message}" "${logLevel}" "${actionStatus}"

}
