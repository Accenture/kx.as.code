getPassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  passwordName=$(echo ${1} | sed 's/ /-/g')
  passwordGroup=${2-}

  # Retrieve the password from GoPass
  if [[ -n "${passwordGroup}" ]]; then 
    /usr/bin/sudo -H -i -u ${baseUser} bash -c "gopass show --yes --password \"${baseDomain}/${passwordGroup}/${passwordName}\"" || rc=$?
  else
    /usr/bin/sudo -H -i -u ${baseUser} bash -c "gopass show --yes --password \"${baseDomain}/${passwordName}\"" || rc=$?
  fi
  
  if [[ ${rc} -eq 11 ]]; then
    if [[ -n "${passwordGroup}" ]]; then 
      >&2 log_debug "Password for \"${baseDomain}/${passwordGroup}/${passwordName}\" not found. This may not be an issue if the calling script was just testing for it's existence, before deciding what to do next"
    else
      >&2 log_debug "Password for \"${baseDomain}/${passwordName}\" not found. This may not be an issue if the calling script was just testing for it's existence, before deciding what to do next"
    fi
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
