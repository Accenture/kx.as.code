pushPassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  passwordName=${1}
  password=${2}
  passwordGroup=${3-}

  if [[ "${passwordGroup}" == "base-technical-credentials" ]]; then
    # If technical admin password, push to root GoPass repository, instead of the base user's
    local gopassUser="root"
  elif [[ -n $(echo "${passwordName}" | grep -E "user-.*-password") ]] && [[ "${passwordGroup}" == "users" ]]; then
    # if pushing user password, push directly to user's own GoPass repository
    local gopassUser=$(echo "${passwordName}" | grep -E "user-.*-password" | awk -F- '{print $2}')
  else
    # Push to VM owner's GoPass Repository
    local gopassUser="${baseUser}"
  fi

  # Push received password to GoPass (only if it does not already exist)
  if [[ -n "${passwordGroup}" ]]; then 
    /usr/bin/sudo -H -i -u ${gopassUser} bash -c "echo \"${password}\" | gopass insert \"${baseDomain}/${passwordGroup}/${passwordName}\""
  else
    /usr/bin/sudo -H -i -u ${gopassUser} bash -c "echo \"${password}\" | gopass insert \"${baseDomain}/${passwordName}\""
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
