getPassword() {

  passwordName=$(echo ${1} | sed 's/ /-/g')
  passwordGroup=${2:-}
  local rc=0

  if [[ "${passwordGroup}" == "base-technical-credentials" ]] || [[ -n "$(echo ${coreGopassGroups} | grep -Eo '(^|[[:space:]])'${passwordGroup}'([[:space:]]|$)')" ]]; then
    # If technical admin password, push to root GoPass repository, instead of the base user's
    local gopassUser="root"
  elif [[ -n $(echo "${passwordName}" | grep -E "user-.*-password") ]] && [[ "${passwordGroup}" == "users" ]]; then
    # if pushing user password, push directly to user's own GoPass repository
    local gopassUser=$(echo "${passwordName}" | grep -E "user-.*-password" | awk -F- '{print $2}')
  else
    # Push to VM owner's GoPass Repository
    local gopassUser="${baseUser}"
  fi

  # Retrieve the password from GoPass
  if [[ -n "${passwordGroup}" ]]; then 
    /usr/bin/sudo -H -i -u ${gopassUser} bash -c "gopass show --yes --password \"${baseDomain}/${passwordGroup}/${passwordName}\"" || local rc=$?
  else
    /usr/bin/sudo -H -i -u ${gopassUser} bash -c "gopass show --yes --password \"${baseDomain}/${passwordName}\"" || local rc=$?
  fi
  
  if [[ ${rc} -eq 11 ]]; then
    if [[ -n "${passwordGroup}" ]]; then 
      >&2 log_debug "Password for \"${baseDomain}/${passwordGroup}/${passwordName}\" not found. This may not be an issue if the calling script was just testing for it's existence, before deciding what to do next"
    else
      >&2 log_debug "Password for \"${baseDomain}/${passwordName}\" not found. This may not be an issue if the calling script was just testing for it's existence, before deciding what to do next"
    fi
  fi

}
