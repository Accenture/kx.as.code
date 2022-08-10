notifyAllChannels() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  message=${1}

  # Set log_level
  if [[ -n ${2} ]]; then
    log_level=${2}
  else
    log_level="info"
  fi

  # Set action_status
  if [[ -n ${3} ]]; then
    action_status=${3}
  else
    action_status="unknown"
  fi

    if [[ "${log_level}" == "error" ]]; then
      dialog_type="dialog-error"
      log_error "${message}"
    elif [[ "${log_level}" == "warn" ]]; then
      dialog_type="dialog-warning"
      log_warn "${message}"
    else
      dialog_type="dialog-information"
      log_info "${message}"
    fi

  log_debug notify "${message}" "${dialog_type}"
  notify "${message}" "${dialog_type}"
  log_debug addToNotificationQueue "${message}" "${log_level}" "${action_status}"
  addToNotificationQueue "${message}" "${log_level}" "${action_status}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}