notify() {

  openDisplays=$(w -oush | grep -Eo ' :[0-9]+' | sort -u -t\  -k1,1 | cut -d \  -f 2 || true)
  log_info "Detected unique displays: ${openDisplays}"
  messageTimeout=${3-300000}
  messageTitle="KX.AS.CODE Notification"
  message=${1}
  messageType=${2}
  for display in ${openDisplays}; do
    displayUser=$(w -oush | grep -sw "${display}" | awk {'print $1'} | uniq)
    echo "Sending notification to display ${display} for user ${displayUser}"
    if [[ -S "/run/user/$(id -u ${displayUser})/bus" ]]; then
        /usr/bin/sudo -H -i -u ${displayUser} bash -c "DISPLAY=\"${display}\" \
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u ${displayUser})/bus \
        notify-send -t \"${messageTimeout}\" \"${messageTitle}\" \"${message}\" --icon=\"${messageType}\""
    fi
  done

}
