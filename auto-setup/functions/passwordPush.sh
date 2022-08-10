pushPassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  passwordName=${1}
  password=${2}
  passwordGroup=${3-}

  # Push received password to GoPass (only if it does not already exist)
  if [[ -n "${passwordGroup}" ]]; then 
    /usr/bin/sudo -H -i -u ${baseUser} bash -c "echo \"${password}\" | gopass insert \"${baseDomain}/${passwordGroup}/${passwordName}\""
  else
    /usr/bin/sudo -H -i -u ${baseUser} bash -c "echo \"${password}\" | gopass insert \"${baseDomain}/${passwordName}\""
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
