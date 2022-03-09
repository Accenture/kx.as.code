addToNotificationQueue() {

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

  export payload='{ "message": "'${message}'", "application": "'${componentName}'", "installation_folder": "'${componentInstallationFolder}'", "message_type": "action_status", "action": "'${action}'", "action_status": "'${action_status}'", "level": "'${log_level}'", "timestamp": "'$(date +%s)'"}'
  rabbitmqadmin publish exchange=action_workflow routing_key=notification_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
}
