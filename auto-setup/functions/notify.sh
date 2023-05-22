notify() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local openDisplays=$(w -oush | grep -Eo ' :[0-9]+' | sort -u -t\  -k1,1 | cut -d \  -f 2 || true)
  log_debug "Detected unique displays: ${openDisplays}"
  local messageTimeout=${3-300000}
  local messageTitle="KX.AS.CODE Notification"
  local message=${1}
  local messageType=${2}

  # Get list of connected displays
  local displayFiles=$(/usr/bin/sudo find /home/*/.dbus -maxdepth 1 -type f -name "Xdbus")

  for displayFile in ${displayFiles}
  do
    if [[ -f /home/${baseUser}/.dbus/Xdbus ]]; then

      local user=$(echo "${displayFile}" | cut -d'/' -f3)
      local userDisplays=$(ps e -u ${user} | grep -Po " DISPLAY=[\.0-9A-Za-z:]* " | sort -u)
      local fullJson="[]"

      for userDisplay in ${userDisplays}
      do
        log_debug "Checking if display ${userDisplay} belonging to ${user} is active"
        local idleTime=$(eval "export ${userDisplay}" && /usr/bin/sudo -u ${user} xprintidle)
        local json="[{ \"display\": \"${userDisplay}\", \"idletime\": \"${idleTime}\" }]"
        local fullJson=$(echo ${fullJson} | jq ". + ${json}")
      done

      log_debug "Full json: $(echo ${fullJson} | jq)"
      log_debug "Latest user display: $(echo ${fullJson} | jq '. | sort_by(.idletime) | .[0]')"

      local mostRecentSessionIdletime=$(echo ${fullJson} | jq -r '. | sort_by(.idletime) | .[0] | .idletime')
      local mostRecentSessionDisplay=$(echo ${fullJson} | jq -r '. | sort_by(.idletime) | .[0] | .display')

      log_debug "${user} --> ${user}Display"
      log_debug "${user} idle-time --> ${mostRecentSessionIdletime}"
      log_debug "${user} display--> ${mostRecentSessionDisplay}"

      if [[ -n ${mostRecentSessionIdletime} ]] && [[ "${mostRecentSessionIdletime}" != "null" ]]; then

        idleTimeSeconds=$(( ${mostRecentSessionIdletime} / 1000 ))
        idleTimeMinutes=$(( ${mostRecentSessionIdletime} / 60000 ))

        log_debug "Idle time in minutes: ${idleTimeSeconds}"
        log_debug "Idle time in seconds: ${idleTimeMinutes}"

        if [[ ${idleTimeMinutes} -le 15 ]]; then
          /usr/bin/sudo -H -i -u ${user} bash -c " \
              source /home/${user}/.dbus/Xdbus && env && \
              env && \
              notify-send -t \"${messageTimeout}\" \"${messageTitle}\" \"${message}\" --icon=\"${messageType}\""
              log_debug "Notification sent"
        fi
      fi
    fi
  done

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
