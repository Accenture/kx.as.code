getOwnerId() {

  firstname=$(jq -r '.config.owner.firstname' ${installationWorkspace}/users.json)
  surname=$(jq -r '.config.owner.surname' ${installationWorkspace}/users.json)
  email=$(jq -r '.config.owner.email' ${installationWorkspace}/users.json)
  defaultUserKeyboardLanguage=$(jq -r '.config.owner.keyboard_language' ${installationWorkspace}/users.json)
  userRole=$(jq -r '.config.owner.role' ${installationWorkspace}/users.json)

  if [[ -n ${firstname} ]] && [[ "${firstname}" != "null" ]]; then
    ownerId=$(generateUsername "${firstname}" "${surname}")
    echo "${ownerId}"
  else
    log_debug "Owner not defined in users.json. Using default kx-hero instead"
    echo "kx-hero"
  fi

}