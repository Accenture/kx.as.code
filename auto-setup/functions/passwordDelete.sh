deletePassword() {

  passwordName=${1}
  passwordGroup=${2:-}

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

  # Conditional statement in case this is being re-run for an already deployed solution
  # Delete password from GoPass
  if [[ -n "${passwordGroup}" ]]; then 
    /usr/bin/sudo -H -i -u ${gopassUser} bash -c "gopass delete --force \"${baseDomain}/${passwordGroup}/${passwordName}\""
  else
    /usr/bin/sudo -H -i -u ${gopassUser} bash -c "gopass delete --force \"${baseDomain}/${passwordName}\""
  fi
  
}
