notifyAllChannels() {

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

  notify "${message}" "${dialog_type}"
  addToNotificationQueue "${message}" "${log_level}" "${action_status}"

}