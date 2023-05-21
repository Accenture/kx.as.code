checkAndUpdateBaseUsername() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Check if owner details defined in users.json
  firstname=$(jq -r '.config.owner.firstname' ${installationWorkspace}/users.json)
  surname=$(jq -r '.config.owner.surname' ${installationWorkspace}/users.json)
  email=$(jq -r '.config.owner.email' ${installationWorkspace}/users.json)
  defaultUserKeyboardLanguage=$(jq -r '.config.owner.keyboard_language' ${installationWorkspace}/users.json)
  userRole=$(jq -r '.config.owner.role' ${installationWorkspace}/users.json)

  if [[ -n ${firstname} ]] && [[ "${firstname}" != "null" ]]; then
   export baseUser=$(getOwnerId)
  else
   export baseUser="kx.hero"
  fi

  if [[ "${vmUser}" != "${baseUser}" ]]; then

    # Create new base user
    createUsers "${firstname}" \
                "${surname}" \
                "${email}" \
                "${defaultUserKeyboardLanguage}" \
                "${userRole}"

    # Hide old base user kx.hero
    /usr/bin/sudo sed -i '/^HideUsers=vagrant/ s/$/,'${vmUser}'/' /etc/sddm.conf

    # Update permission on Git repository
    /usr/bin/sudo chown -R ${baseUser}:${baseUser} ${sharedGitHome}

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
      
}