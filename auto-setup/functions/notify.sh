####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
notify() {
  set +x
  local openDisplays=$(w -oush | grep -Eo ' :[0-9]+' | sort -u -t\  -k1,1 | cut -d \  -f 2 || true)
  log_trace "Detected unique displays: ${openDisplays}"
  local message=''${1:-}''
  local messageType=${2:-"dialog-information"}
  local messageTimeout=${3:-300000}
  local messageTitle=${4:-"KX.AS.CODE Notification"}
  local notificationTitle="$(cat ${profileConfigJsonPath} | jq -r '.notification_title | select(.!=null)')"

  if [[ -z ${notificationTitle} ]]; then
    notificationTitle="KX.AS.CODE"
  fi
  local parsedMessage=$(echo ''${message}'' | sed 's/"/\"/g' | sed 's/\\$//g')

  # Get list of connected displays
  local displayFiles=$(/usr/bin/sudo find /home/*/.dbus -maxdepth 1 -type f -name "Xdbus" || true)

  for displayFile in ${displayFiles}; do
    if [[ -f ${displayFile} ]]; then

      local user=$(echo "${displayFile}" | cut -d'/' -f3)
      if [[ -n ${user} ]] && [[ "${user}" != "admin" ]] && [[ "${user}" != "root" ]]; then

        log_trace "Getting user displays for \"${user}\""
        local userDisplays=$(ps e -u ${user} | grep -Po "DISPLAY=[\.0-9A-Za-z:]* " | sed -e 's/ //' | cut -d'.' -f1 | sort -u | uniq || log_trace "No displays found for \"${user}\"")
        log_trace "User \"${user}\" has \"${userDisplays}\" displays"
        local fullJson="[]"

        if [[ -n ${userDisplays} ]]; then

          for userDisplay in ${userDisplays}; do
            # Final check display is active by comparing two lists
            log_trace "Checking if any of the user displays \"${userDisplays}\" are active"
            log_trace "Displays in /tmp/.X11-unix: $(cd /tmp/.X11-unix && for x in X*; do echo \":${x#X}\"; done)"
            activeDisplay=$(echo "$(echo ${userDisplays} | cut -f2 -d'=')" | grep -Fx "$(cd /tmp/.X11-unix && for x in X*; do echo ":${x#X}"; done)")
            log_trace "Active display(s) found: \"${activeDisplay}\""
            if [[ -n ${activeDisplay} ]]; then
              log_trace "Seems display \"${userDisplay}\" belonging to \"${user}\" is active. Checking idle time"
              local idleTime=$(eval "export ${userDisplay}" && /usr/bin/sudo -u ${user} xprintidle)
              local json="[{ \"display\": \"${userDisplay}\", \"idletime\": \"${idleTime}\" }]"
              local fullJson=$(echo ${fullJson} | jq ". + ${json}")
            else
              log_trace "User display \"${userDisplay}\" no longer valid. Skipping".
            fi
          done

          if [[ "${fullJson}" != "[]" ]]; then
            log_trace "Full json: $(echo ${fullJson} | jq)"
            log_trace "Latest user display: $(echo ${fullJson} | jq '. | sort_by(.idletime) | .[0]')"

            local mostRecentSessionIdletime=$(echo ${fullJson} | jq -r '. | sort_by(.idletime) | .[0] | .idletime')
            local mostRecentSessionDisplay=$(echo ${fullJson} | jq -r '. | sort_by(.idletime) | .[0] | .display')

            log_trace "${user} --> ${user}Display"
            log_trace "${user} idle-time --> ${mostRecentSessionIdletime}"
            log_trace "${user} display--> ${mostRecentSessionDisplay}"

            if [[ -n ${mostRecentSessionIdletime} ]] && [[ "${mostRecentSessionIdletime}" != "null" ]]; then

              idleTimeSeconds=$((${mostRecentSessionIdletime} / 1000))
              idleTimeMinutes=$((${mostRecentSessionIdletime} / 60000))

              log_trace "Idle time in minutes: ${idleTimeSeconds}"
              log_trace "Idle time in seconds: ${idleTimeMinutes}"

              if [[ ${idleTimeMinutes} -le 15 ]]; then
                /usr/bin/sudo -H -i -u ${user} bash -c " \
                    source /home/${user}/.dbus/Xdbus && \
                    notify-send -t \"${messageTimeout}\" \"${notificationTitle}\" \"${parsedMessage}\" --icon=\"${messageType}\""
                log_trace "Notification sent"
              fi
            fi
          fi
        fi
      fi
    fi
  done
}
