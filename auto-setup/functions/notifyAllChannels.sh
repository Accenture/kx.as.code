notifyAllChannels() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local message=${1}
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
    message=$(echo "${1}" | sed "s/Installation of/Execution of task \"${task}\" for/g" | sed "s/installed/task  \"${task} \" executed/g")
  fi

  log_debug "notify \"${message}\" \"${dialogType}\""

  sendSlackNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"
  sendMsTeamsNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"
  sendEmailNotification "${message}" "${logLevel}" "${actionStatus}" "${componentName:-}" "${action}" "${category:-}" "${retries:-}" "${task:-}" "${actionDuration}"

  notify "${message}" "${dialogType}" "${notificationTimeout}"
  log_debug addToNotificationQueue "${message}" "${logLevel}" "${actionStatus}"
  addToNotificationQueue "${message}" "${logLevel}" "${actionStatus}"

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}