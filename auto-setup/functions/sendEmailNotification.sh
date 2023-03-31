sendEmailNotification() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart "true"

  local message=${1:-}
  local alertType=${2:-info}
  local actionStatus=${3:-unkown}
  local componentName=${4:-not applicable}
  local action=${5:-}
  local category=${6:-}
  local retries=${7:-}
  local task=${8:-}
  local actionDuration=${9:-}

  local emailAddress="$(cat ${profileConfigJsonPath} | jq -r '.notification_endpoints.email_address')"

  if [[ -n ${emailAddress} ]] && [[ "${emailAddress}" != "null" ]] && [[ -n ${message} ]]; then

      log_debug 'echo "<html><body>'${message}'</body></html>" | mailx -a "From: Dev VM Notification <noreply@'${baseDomain}'>" -a "Content-type: text/html;" -s "['${alertType^^}'] Testing Notifications" '${emailAddress}''

      echo "<html><body>${message}</body></html>" | mailx -a "From: Dev VM Notification <noreply@${baseDomain}>" -a "Content-type: text/html;" -s "[${alertType^^}] Testing Notifications" ${emailAddress}

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}