notify() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  openDisplays=$(w -oush | grep -Eo ' :[0-9]+' | sort -u -t\  -k1,1 | cut -d \  -f 2 || true)
  log_debug "Detected unique displays: ${openDisplays}"
  messageTimeout=${3-300000}
  messageTitle="KX.AS.CODE Notification"
  message=${1}
  messageType=${2}
  if [[ -f /home/${baseUser}/.dbus/Xdbus ]]; then
      /usr/bin/sudo -H -i -u ${baseUser} bash -c " \
          source /home/${baseUser}/.dbus/Xdbus && \
          notify-send -t \"${messageTimeout}\" \"${messageTitle}\" \"${message}\" --icon=\"${messageType}\""
          log_debug "Notification sent"
  else
    for display in ${openDisplays}; do
      displayUser=$(w -oush | grep -sw "${display}" | awk {'print $1'} | uniq)
      log_debug "Sending notification to display ${display} for user ${displayUser}"
      if [[ -S "/run/user/$(id -u ${displayUser})/bus" ]]; then
          /usr/bin/sudo -H -i -u ${displayUser} bash -c "DISPLAY=\"${display}\" \
          DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u ${displayUser})/bus \
          notify-send -t \"${messageTimeout}\" \"${messageTitle}\" \"${message}\" --icon=\"${messageType}\""
          log_debug "Notification sent"
      fi
    done
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
