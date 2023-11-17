####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
sendEmailNotification() {
  set +x
  local message="${1:-}"
  local alertType=${2:-"info"}
  local actionStatus=${3:-"unknown"}
  local componentName=${4:-"not applicable"}
  local action=${5:-}
  local category=${6:-}
  local retries=${7:-}
  local task=${8:-}
  local actionDuration=${9:-}
  local notificationTitle="$(cat ${profileConfigJsonPath} | jq -r '.notification_title | select(.!=null)')"

  if [[ -z ${notificationTitle} ]]; then
    notificationTitle="KX.AS.CODE"
  fi
  
  local emailAddress="$(cat ${profileConfigJsonPath} | jq -r '.notification_endpoints.email_address | select(.!=null)')"

  # If no MTA installed, skip email notifications
  if which exim4; then
    # If no notification email address defined, skip email notifications
    if [[ -n ${emailAddress} ]] && [[ "${emailAddress}" != "null" ]] && [[ -n ${message} ]]; then
        log_trace 'echo "<html><body>'${message}'</body></html>" | mailx -a "From: Dev VM Notification <noreply@'${baseDomain}'>" -a "Content-type: text/html;" -s "['${alertType^^}'] Testing Notifications" '${emailAddress}''
        echo "<html><body>${message}</body></html>" | mailx -a "From: Dev VM Notification <noreply@${baseDomain}>" -a "Content-type: text/html;" -s "[${alertType^^}] Testing Notifications" ${emailAddress}
    else
        log_trace "No email address for notifications defined. Skipping"
    fi
    log_trace "No MTA (Exim4) installed. Skipping email notifications"
  fi

}