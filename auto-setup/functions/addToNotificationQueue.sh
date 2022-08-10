addToNotificationQueue() {

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

  export notificationPayload='{ "message": "'${message}'", "application": "'${componentName}'", "installation_folder": "'${componentInstallationFolder}'", "message_type": "action_status", "action": "'${action}'", "action_status": "'${action_status}'", "log_level": "'${log_level}'", "timestamp": "'$(date +%s)'" }'
  log_debug export notificationPayload='{ "message": "'${message}'", "application": "'${componentName}'", "installation_folder": "'${componentInstallationFolder}'", "message_type": "action_status", "action": "'${action}'", "action_status": "'${action_status}'", "log_level": "'${log_level}'", "timestamp": "'$(date +%s)'" }'
  log_debug rabbitmqadmin publish exchange=action_workflow routing_key=notification_queue properties='{"delivery_mode": 2}' notificationPayload="${notificationPayload}"
  rabbitmqadmin publish exchange=action_workflow routing_key=notification_queue properties='{"delivery_mode": 2}' notificationPayload="${notificationPayload}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
