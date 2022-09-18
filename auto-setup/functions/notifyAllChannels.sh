notifyAllChannels() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local message=${1}
  local logLevel=${2-info}
  local actionStatus=${3-unknown}
  local action=${4-}
  local notificationTimeout=${5-300000}

  if [[ "${logLevel}" == "error" ]]; then
    dialogType="dialog-error"
    log_error "${message}"
  elif [[ "${logLevel}" == "warn" ]]; then
    dialogType="dialog-warning"
    log_warn "${message}"
  else
    dialogType="dialog-information"
    log_info "${message}"
  fi

  # Change message if task was executed rather than solution installed
  if [[ "${action}" == "executeTask" ]]; then
    message=$(echo "${1}" | sed 's/installation/task execution/g' | sed 's/installed/task executed/g')
  fi

  log_debug notify "${message}" "${dialogType}"
  notify "${message}" "${dialogType}" "${notificationTimeout}"
  log_debug addToNotificationQueue "${message}" "${logLevel}" "${actionStatus}"
  addToNotificationQueue "${message}" "${logLevel}" "${actionStatus}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}